SHOW databases;

CREATE DATABASE if not exists Business;
USE Business;
SHOW databases;

CREATE TABLE if not exists customer
(
	customer_id int primary key
    , name varchar(20) not null unique
    , email varchar(20) not null unique
);
CREATE TABLE if not exists item
(
	item_id int primary key
    , name varchar(20) not null unique
    , Price int
);
CREATE TABLE if not exists orders
(
	order_id int primary key
    , customer_id int not null
    , item_id int not null
    , quantity int
    , foreign key customer_id_fk(customer_id)
		references customer(customer_id)
        ON UPDATE cascade
        ON DELETE no action
	, foreign key item_id_fk(item_id)
		references item(item_id)
        ON UPDATE cascade
        ON DELETE no action
);
SHOW tables;
INSERT INTO customer(customer_id, name, email)
	VALUES(1, 'Rosalyn Rivera','rr@adatum.com')
		, (2, 'Jayne Sargen','jayne@test.com')
		, (3, 'Dean Luong','dean@test.com');
INSERT INTO item(item_id, name, Price)
	VALUES(1, 'Chair', 200)
		, (2, 'Table', 100)
        , (3, 'Lamp', 50);
INSERT INTO orders(order_id, customer_id, item_id, quantity)
	VALUES(1,2,1,1)
		, (2,2,2,3)
        , (3,3,3,5);
SHOW databases;
SHOW tables;
SELECT * FROM customer;
SELECT * FROM item;
SELECT * FROM orders;