

cqlsh 172.31.61.2

CREATE KEYSPACE test_data
  WITH REPLICATION = { 
   'class' : 'SimpleStrategy', 
   'replication_factor' : 2
  };

use system;
DESCRIBE keyspaces

use hr;

CREATE TABLE employee (
   id int PRIMARY KEY,
   emp_name text,
   emp_city text
);

DESCRIBE tables

select * from employee;

INSERT INTO hr.employee  (id, emp_name, emp_city) VALUES (1, 'Susantha Bathige', 'Colorado');


--==================================

CREATE TABLE test_data.real_estate ( 
  street varchar,
  city varchar,
  zip varchar,
  state varchar,
  beds int,
  baths int,
  sq__ft int,
  type varchar,
  sale_date varchar,
  price int,
  latitude float PRIMARY KEY,
  longitude float
);



select * from test_data.real_estate;

curl -O http://samplecsvs.s3.amazonaws.com/Sacramentorealestatetransactions.csv 

COPY test_data.real_estate (street,city,zip,state,beds,baths,sq__ft,type,sale_date,price,latitude,longitude) FROM '~/Sacramentorealestatetransactions.csv' WITH HEADER = TRUE AND DELIMITER = ';';

COPY test_data.real_estate FROM '~/Sacramentorealestatetransactions.csv' WITH HEADER = TRUE AND DELIMITER = ';';

COPY test_data.real_estate (street,city,zip,state,beds,baths,sq__ft,type,sale_date,price,latitude,longitude) FROM 'test2.csv' WITH HEADER = TRUE;

--=========================
create table test_data.tab1 (id int primary key,email text, name text, phone text);


select COUNT(*) from test_data.real_estate;

COPY test_data.tab1 FROM 'test.csv';