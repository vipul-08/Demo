from flask import Flask, request, jsonify
from roster_generator import generate_next_month_roster, reassign_shifts_for_leave

app = Flask(__name__)

@app.route('/hello')
def hello_world():
    return 'Hello, World!'


@app.route("/generate_roster", methods=["POST"])
def generate_roster():
    try:
        data = request.get_json()
        manager_id = data.get("manager_id")
        year = data.get("year")
        month = data.get("month")

        if not manager_id:
            return jsonify({"status": "error", "message": "manager_id is required"}), 400
        
        if not year:
            return jsonify({"status": "error", "message": "year is required"}), 400

        if not month:
            return jsonify({"status": "error", "message": "month is required"}), 400

        result = generate_next_month_roster(manager_id, int(year), int(month))
        return jsonify(result)
    except Exception as e:
        print("Error:", e)
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/reassign_roster", methods=["POST"])
def reassign_roster():
    try:
        data = request.get_json()
        manager_id = data.get("manager_id")
        leave_date = data.get("leave_date")
        employee_id = data.get("employee_id")

        if not manager_id:
            return jsonify({"status": "error", "message": "manager_id is required"}), 400
        
        if not leave_date:
            return jsonify({"status": "error", "message": "leave_date is required"}), 400

        if not employee_id:
            return jsonify({"status": "error", "message": "employee_id is required"}), 400

        result = reassign_shifts_for_leave(manager_id, leave_date, employee_id)
        return jsonify(result)
    except Exception as e:
        print("Error:", e)
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, port=5050)