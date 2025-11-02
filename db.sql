CREATE TABLE users (
    attuid varchar(10) NOT NULL primary key,
    email varchar(255) NOT NULL unique,
    password varchar(255) NOT NULL,
    first_name varchar(100) NOT NULL,
    last_name varchar(100) NOT NULL,
    mobile varchar(10) NOT NULL,
    manager_attuid varchar(10),
    is_manager tinyint(1) default 0
);

CREATE TABLE otps (
	id INT auto_increment primary key,
    email varchar(255) NOT NULL unique,
    otp varchar(6) not null,
    created_at datetime default current_timestamp
);

CREATE TABLE leave_balances(
	attuid varchar(10) primary key,
    sick int default 15,
	casual int default 12, 
    vacation int default 20
);

CREATE TABLE leave_records(
	id INT auto_increment primary key,
    attuid varchar(10) not null,
    start_date date not null,
    end_date date not null,
    leave_type enum('sick', 'casual', 'vacation') not null,
    reason varchar(100),
    status enum('applied', 'approved', 'rejected') default 'applied'
);

CREATE TABLE public_holidays(
	id INT auto_increment primary key,
    date date not null,
    name varchar(50)
);

SELECT * from public_holidays;



-- INSERT INTO public_holidays(date, name) VALUES ('2025/01/01', 'New Year Eve');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/01/14', 'Makar Sankranti');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/03/14', 'Holi');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/03/31', 'Eid');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/05/01', 'Labour Day');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/08/15', 'Independence Day');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/08/27', 'Ganesh Chaturthi');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/10/02', 'Dussehra');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/10/20', 'Diwali');
-- INSERT INTO public_holidays(date, name) VALUES ('2025/12/25', 'Christmas Eve');

INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('ap031w','ap031w@att.com','$2b$10$sDRuGe1f.IDGAwiZmWNAkup8yq3mNENcBCeM5F3sOM16ppns9Jv3y','Abhay Chandrakant','Pujari','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('ap6858','ap6858@att.com','$2b$10$uuIJ1.FGdmuLMcHm0bQTP.B4LHyAgMuB.8ot/0CMLSOylMsAQPvR2','Ankit','Patiyat','9999999999','mj7868',1);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('aw678u','aw678u@att.com','$2b$10$jRKJ8vRdnwz9N1WJw3oAru3oFcQhuMGGtxnjWV0wD3jk5spBAFlTa','Aryan','Wani','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('dp5104','dp5104@att.com','$2b$10$KXoOZL/OFHtXLYyK1nijX.EwmRst3PDCbz0pqcitoNd4kRRPZwpQ6','Darshan','Patel','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('gm6416','gm6416@att.com','$2b$10$cTU.W.U2.WLvj3vmOobDOuBET/5HcgRl4zLxL7URinDbkRj2ijPsu','Geetika','Mehta','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('mj7868','mj7868@att.com','$2b$10$R7GaQS7KRt.H.FZh4SWsjexTanFazwFmLG2n8kwHqFSpwVnTNjaay','Murali Mohan','Josyula','9999999999','',1);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('pp0770','pp0770@att.com','$2b$10$mhKZOBlpG11hdhCIDd4kP.6yUVcn3ps7f/lFDxComg3dAE/xmgFoS','Pranav','Pawar','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('rb692q','rb692q@att.com','$2b$10$r4s3yeV16rh1HlMLDMLVUuzxDHwYis4/TU2h8QlfKzUhNPFBvkwHC','Raja Shekar','Bollam','9999999999','mj7868',1);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('sl6045','sl6045@att.com','$2b$10$7h9i9X9BrU85dUmjGcjhfepMOp1T3DCUCR0dkqxYPzG4hfSn/EFEW','Sudha','N','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('sm168x','sm168x@att.com','$2b$10$DS32VdWwxf5WaD59vP4pOumxRbomVjuoY4YXEQRC5xptwMomJF8Cy','Suparno','Mojumder','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('sn767m','sn767m@att.com','$2b$10$ZxBCVowdy.hHjoY/mZv/ceQcbOZ1.oDjg356FBia./uqUismHzp9i','Swathi','Nagamahanti','9999999999','mj7868',1);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('sp9816','sp9816@att.com','$2b$10$lLdwD0Jqi7P7tB7l14xUbu4dHpw.gwHH2IPvNGKSyQ58iBcTuvPQe','Shailesh','Prajapati','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('ss863t','ss863t@att.com','$2b$10$JnZLyIvEBAgLllxbc0DSpOVFn4RvnTwhBZW4932RtqrmOmznLZI/6','Sanjay','Sharma','9999999999','mj7868',1);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('sx117g','sx117g@att.com','$2b$10$oToMM/TLOSgbRbG.g.GI9.5s4JEYTa/DLuz2VlMu25paAuYqJGYX6','Shreya','Sanjay','9999999999','ss863t',0);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('uu6343','uu6343@att.com','$2b$10$2NcCNax11tEcaHY9BgNwbezno8xxuT6g.Zd2BiAQD3ZKToJiAvh6C','Utkarsh','Upendra','9999999999','mj7868',1);
INSERT INTO `` (`attuid`,`email`,`password`,`first_name`,`last_name`,`mobile`,`manager_attuid`,`is_manager`) VALUES ('vr7663','vr7663@att.com','$2b$10$HjFhmfXqJNsrZdAaq7Zd0Or.9D5MC0Pn/EUTgdUOIQsLflrkgBf2W','Vipul','Raghuvanshi','9999999999','ss863t',0);

INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('ap031w',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('ap6858',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('aw678u',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('dp5104',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('gm6416',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('mj7868',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('pp0770',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('rb692q',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('sl6045',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('sm168x',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('sn767m',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('sp9816',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('ss863t',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('sx117g',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('uu6343',15,12,20);
INSERT INTO `` (`attuid`,`sick`,`casual`,`vacation`) VALUES ('vr7663',15,12,20);
