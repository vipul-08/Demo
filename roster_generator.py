from ortools.sat.python import cp_model
from pymongo import MongoClient
import pandas as pd
from datetime import datetime, timedelta, date
from dateutil.relativedelta import relativedelta
import calendar
from config import MONGO_URI, DB_NAME
import json
from bson import ObjectId


# ------------ Utility Functions ----------------------
def get_last_n_months(n: int, ref_year: int, ref_month: int):
    """Return list of dicts with month name and year for the last n months ending at (ref_year, ref_month) inclusive."""
    out = []
    ref = date(ref_year, ref_month, 1)
    for i in range(n):
        d = ref - relativedelta(months=i)
        out.append({"month": d.strftime("%B"), "year": d.year})
    return out

def pref_coll_name(manager_id: str, month_name: str, year: int) -> str:
    return f"pref_{manager_id}_{month_name}_{year}"

def coll_name(manager_id: str, month_name: str, year: int) -> str:
    return f"{manager_id}_{month_name}_{year}"

# ---------- Step 1: Load historical records ----------
def load_historical_data(manager_id, year, month):
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    months_meta = get_last_n_months(24, year, month)
    records = []
    for m in months_meta:
        name = coll_name(manager_id, m["month"], m["year"])
        if name in db.list_collection_names():
            # logger.info(f"Loading {name}")
            coll = db[name]
            records.extend(list(coll.find()))
    df = pd.DataFrame(records)
    if df.empty:
        raise ValueError("No historical data found.")
    df["date"] = pd.to_datetime(df["date"])
    return df


# ---------- Step 2: Learn history patterns ----------
def learn_patterns(df):
    shift_ratio = (
        df.groupby(["employee_id", "shift"])
        .size()
        .groupby(level=0)
        .apply(lambda x: x / x.sum())
        .unstack(fill_value=0)
    )

    # Average night shifts per month
    monthly_nights = (
        df[df["shift"] == "night"]
        .groupby(["employee_id", pd.Grouper(key="date", freq="M")])
        .size()
        .groupby("employee_id")
        .mean()
        .fillna(0)
    )

    # Typical weekdays worked
    df["weekday"] = df["date"].dt.day_name().str.lower()
    weekday_shift_pref = (
        df.groupby(["employee_id", "weekday", "shift"])
        .size()
        .groupby(level=[0, 1])
        .apply(lambda x: x / x.sum())
        .unstack(fill_value=0)
    )

    return {
        "shift_ratio": shift_ratio,
        "monthly_nights": monthly_nights,
        "weekday_shift_pref": weekday_shift_pref,
    }


# ---------- Step 3: Build CP-SAT model ----------
def generate_next_month_roster(manager_id, year, month):
    preferences = fetch_preference(manager_id, year, month)
    df = load_historical_data(manager_id, year, month)
    patterns = learn_patterns(df)
    employees = df["employee_id"].unique().tolist()
    shifts = ["morning", "day", "night"]

    _, num_days = calendar.monthrange(year, month)
    all_days = [d for d in range(1, num_days + 1)]
    work_days = [d for d in all_days if datetime(year, month, d).weekday() < 5]

    print(work_days)

    model = cp_model.CpModel()

    # Decision vars: x[e, d, s] = 1 if employee e works shift s on day d
    x = {}
    for e in employees:
        for d in work_days:
            for s in shifts:
                x[e, d, s] = model.NewBoolVar(f"x_{e}_{d}_{s}")

    # ---------- Hard Constraints ----------

    # 1. One shift per day per employee
    for e in employees:
        for d in work_days:
            model.Add(sum(x[e, d, s] for s in shifts) <= 1)

    # 2. Equal distribution per shift per day
    per_shift = len(employees) // len(shifts)
    for d in work_days:
        for s in shifts:
            model.Add(sum(x[e, d, s] for e in employees) >= per_shift - 1)
            model.Add(sum(x[e, d, s] for e in employees) <= per_shift + 1)

    # 3. Max 8 night shifts
    for e in employees:
        model.Add(sum(x[e, d, "night"] for d in work_days) <= 8)

    # 4. Max 5 consecutive work days
    for e in employees:
        for start in range(len(work_days) - 5):
            model.Add(
                sum(
                    sum(x[e, work_days[i], s] for s in shifts)
                    for i in range(start, start + 6)
                )
                <= 5
            )

    # 5. Respect unavailable days
    for e, pref in preferences.items():
        for unav_date in pref.get("unavailable_days", []):
            dt = datetime.fromisoformat(unav_date)
            if dt.month == month and dt.year == year and dt.day in work_days:
                for s in shifts:
                    model.Add(x[e, dt.day, s] == 0)

    # ---------- Soft Preferences ----------
    soft_terms = []

    for e in employees:
        # Historical ratio preservation
        ratios = patterns["shift_ratio"].loc[e] if e in patterns["shift_ratio"].index else None
        if ratios is not None:
            total_days = len(work_days)
            for s in shifts:
                target = int(ratios[s] * total_days)
                total = sum(x[e, d, s] for d in work_days)
                diff = model.NewIntVar(-total_days, total_days, f"diff_{e}_{s}")
                abs_diff = model.NewIntVar(0, total_days, f"abs_diff_{e}_{s}")

                # diff = total - target
                model.Add(diff == total - target)
                # abs_diff = |diff|
                model.AddAbsEquality(abs_diff, diff)

                # We minimize abs_diff → equivalently maximize -abs_diff
                soft_terms.append(-abs_diff)

        # Employee-specific preferences
        pref = preferences.get(e, {})
        preferred_shifts = pref.get("preferred_shifts", [])
        weekday_prefs = pref.get("preferred_weekday", {})
        day_prefs = pref.get("preferred_days", {})

        # General preferred shifts
        for d in work_days:
            for s in preferred_shifts:
                soft_terms.append(2 * x[e, d, s])  # reward general preference

        # Weekday-based preference
        for d in work_days:
            dow = calendar.day_name[datetime(year, month, d).weekday()].lower()
            if dow in weekday_prefs:
                for s in weekday_prefs[dow]:
                    soft_terms.append(4 * x[e, d, s])  # higher weight

        # Date-specific preference
        for date_str, pref_shifts in day_prefs.items():
            dt = datetime.fromisoformat(date_str)
            if dt.month == month and dt.year == year and dt.day in work_days:
                for s in pref_shifts:
                    soft_terms.append(6 * x[e, dt.day, s])  # strongest preference

    model.Maximize(sum(soft_terms))

    # ---------- Solve ----------
    solver = cp_model.CpSolver()
    solver.parameters.max_time_in_seconds = 90
    solver.parameters.num_search_workers = 8
    result = solver.Solve(model)

    # ---------- Build Output ----------
    roster = []
    if result in (cp_model.OPTIMAL, cp_model.FEASIBLE):
        for d in work_days:
            date_str = f"{year}-{month:02d}-{d:02d}"
            dt_list = []
            for s in shifts:
                for e in employees:
                    if solver.Value(x[e, d, s]):
                        dt_list.append(e)
                        roster.append({
                            "manager_id": manager_id,
                            "employee_id": e,
                            "date": date_str,
                            "shift": s
                        })
            for e in employees:
                if e not in dt_list:
                    roster.append({
                        "manager_id": manager_id,
                        "employee_id": e,
                        "date": date_str,
                        "shift": "off"
                    })

    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    new_coll = db[coll_name(manager_id, calendar.month_name[month], year)]
    new_coll.drop()
    result = new_coll.insert_many(roster)
    
    inserted_docs = list(new_coll.find())
    json_result = oid_to_str(inserted_docs)

    return json_result

def oid_to_str(doc):
    """Recursively convert ObjectId to str in a dict or list."""
    if isinstance(doc, list):
        return [oid_to_str(item) for item in doc]
    elif isinstance(doc, dict):
        return {k: oid_to_str(v) for k, v in doc.items()}
    elif isinstance(doc, ObjectId):
        return str(doc)
    else:
        return doc

def fetch_preference(manager_id: str, year: int, month: int):
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    preferences = {}
    name = pref_coll_name(manager_id, calendar.month_name[month], year)
    if name in db.list_collection_names():
        coll = db[name]
        for doc in coll.find():
            preferences[doc["employee_id"]] = doc
    return preferences

def reassign_shifts_for_leave(manager_id: str, leave_date: str, employee_id: str):
    """
    Reassign shifts for a specific date when an employee takes leave.
    Ensures the number of employees in each shift for that date remains balanced.
    Only working employees (not 'off') are reassigned.
    """
    leave_dt = datetime.fromisoformat(leave_date)
    month_name = calendar.month_name[leave_dt.month]
    year = leave_dt.year

    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    coll = db[coll_name(manager_id, month_name, year)]

    if coll.name not in db.list_collection_names():
        raise ValueError(f"No roster found for {month_name} {year} for manager {manager_id}")

    # --- Fetch all records for that date ---
    day_records = list(coll.find({"date": leave_date}))
    if not day_records:
        raise ValueError(f"No roster found for {leave_date}")

    # --- Mark employee as off ---
    leave_record = next((r for r in day_records if r["employee_id"] == employee_id), None)
    if not leave_record:
        raise ValueError(f"Employee {employee_id} not found on {leave_date}")
    vacated_shift = leave_record["shift"]

    if vacated_shift == "off":
        print(f"{employee_id} was already off on {leave_date}.")
        return

    coll.update_one({"_id": leave_record["_id"]}, {"$set": {"shift": "off"}})

    # --- Compute current shift distribution ---
    df_day = pd.DataFrame(day_records)
    df_day.loc[df_day["employee_id"] == employee_id, "shift"] = "off"

    shifts = ["morning", "day", "night"]
    working_df = df_day[df_day["shift"] != "off"].copy()
    total_working = len(working_df)
    ideal_per_shift = total_working // len(shifts)
    remainder = total_working % len(shifts)

    # --- Load full month for fairness ---
    month_records = list(coll.find({"employee_id": {"$ne": employee_id}}))
    df_month = pd.DataFrame(month_records)
    shift_counts = (
        df_month.groupby("employee_id")["shift"]
        .value_counts()
        .unstack(fill_value=0)
    )

    # --- Count per shift currently ---
    current_counts = working_df["shift"].value_counts().to_dict()

    print("Before balancing:", current_counts)

    # --- Identify overstaffed and understaffed shifts ---
    overstaffed = [s for s, c in current_counts.items() if c > ideal_per_shift]
    understaffed = [s for s in shifts if current_counts.get(s, 0) < ideal_per_shift or s == vacated_shift]

    # Sort for deterministic assignment
    overstaffed.sort()
    understaffed.sort()

    # --- Step 1: Move employees from overstaffed → understaffed shifts ---
    for target_shift in understaffed:
        while current_counts.get(target_shift, 0) < ideal_per_shift and overstaffed:
            donor_shift = overstaffed[0]
            if current_counts.get(donor_shift, 0) <= ideal_per_shift:
                overstaffed.pop(0)
                continue

            # Pick employee from donor_shift with lowest experience in target_shift
            donor_candidates = working_df[working_df["shift"] == donor_shift]["employee_id"].tolist()
            best_emp = None
            min_exp = float("inf")

            for emp in donor_candidates:
                exp = shift_counts.loc[emp, target_shift] if emp in shift_counts.index else 0
                if exp < min_exp:
                    min_exp = exp
                    best_emp = emp

            if not best_emp:
                overstaffed.pop(0)
                continue

            # Update local tracking
            working_df.loc[working_df["employee_id"] == best_emp, "shift"] = target_shift
            current_counts[donor_shift] -= 1
            current_counts[target_shift] = current_counts.get(target_shift, 0) + 1

            if current_counts[donor_shift] <= ideal_per_shift:
                overstaffed.pop(0)

    # --- Step 2: Update MongoDB with new assignments ---
    for _, row in working_df.iterrows():
        coll.update_one(
            {"employee_id": row["employee_id"], "date": leave_date},
            {"$set": {"shift": row["shift"]}}
        )

    # --- Step 3: Verify and print balance ---
    final_records = list(coll.find({"date": leave_date}))
    final_df = pd.DataFrame(final_records)
    after_counts = final_df["shift"].value_counts().to_dict()

    print("After balancing:", after_counts)
    print(f"Balanced roster maintained for {leave_date} after {employee_id}'s leave.")

    return oid_to_str(final_records)