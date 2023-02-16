CREATE DATABASE IF NOT EXISTS flights;
USE flights;

CREATE TABLE IF NOT EXISTS flight(
	flno INT,
    origin VARCHAR(20),
    destination VARCHAR(20),
    distance INT,
    departs TIME,
    arrives TIME,
    price REAL,
    PRIMARY KEY (flno) 
);

CREATE TABLE IF NOT EXISTS aircraft(
	aid INT,
    aname VARCHAR(20),
    cruisingrange INT,
    PRIMARY KEY (aid) 
);

CREATE TABLE IF NOT EXISTS employees(
	eid INT,
    ename VARCHAR(20),
    salary INT,
    PRIMARY KEY (eid) 
);

CREATE TABLE IF NOT EXISTS certified(
	eid INT,
    aid INT,
    PRIMARY KEY (eid,aid),
    FOREIGN KEY (eid) REFERENCES employees (eid),
    FOREIGN KEY (aid) REFERENCES aircraft (aid) 
);

INSERT INTO flight 
	(flno,
	origin,
	destination,
	distance,
	departs,
	arrives,
	price) VALUES 
(1,'Bangalore','Mangalore',360,'10:45:00','12:00:00',10000),
(2,'Bangalore','Delhi',5000,'12:15:00','04:30:00',25000),
(3,'Bangalore','Mumbai',3500,'02:15:00','05:25:00',30000),
(4,'Delhi','Mumbai',4500,'10:15:00','12:05:00',35000),
(5,'Delhi','Frankfurt',18000,'07:15:00','05:30:00',90000),
(6,'Bangalore','Frankfurt',19500,'10:00:00','07:45:00',95000),
(7,'Bangalore','Frankfurt',17000,'12:00:00','06:30:00',99000);

INSERT INTO aircraft (aid,aname,cruisingrange) values 
(123,'Airbus',1000),
(302,'Boeing',5000),
(306,'Jet01',5000),
(378,'Airbus380',8000),
(456,'Aircraft',500),
(789,'Aircraft02',800),
(951,'Aircraft03',1000);

INSERT INTO employees (eid,ename,salary) VALUES
(1,'Ajay',30000),
(2,'Ajith',85000),
(3,'Arnab',50000),
(4,'Harry',45000),
(5,'Ron',90000),
(6,'Josh',95000),
(7,'Ram',100000);

INSERT INTO certified (eid,aid) VALUES
(1,123),
(2,123),
(1,302),
(5,302),
(7,302),
(1,306),
(2,306),
(1,378),
(2,378),
(3,456),
(5,789),
(3,951),
(1,951),
(1,789);