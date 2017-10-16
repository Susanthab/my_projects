

cqlsh 172.31.61.2


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

>cqlsh 172.31.58.121

CREATE KEYSPACE test_data
  WITH REPLICATION = { 
   'class' : 'SimpleStrategy', 
   'replication_factor' : 2
  };


CREATE KEYSPACE kp_realstate
  WITH REPLICATION = { 
   'class' : 'SimpleStrategy', 
   'replication_factor' : 2
  };


CREATE TABLE kp_realstate.realestate_data ( 
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

#curl -O http://samplecsvs.s3.amazonaws.com/Sacramentorealestatetransactions.csv

#COPY test_data.real_estate (street,city,zip,state,beds,baths,sq__ft,type,sale_date,price,latitude,longitude) FROM '~/realstatesdata.csv' WITH HEADER = TRUE AND DELIMITER = ';';
#COPY test_data.real_estate FROM '~/realstatesdata.csv' WITH HEADER = TRUE AND DELIMITER = ';';

# The below one worked. 
COPY kp_realstate.realestate_data (street,city,zip,state,beds,baths,sq__ft,type,sale_date,price,latitude,longitude) FROM 'realstatesdata.csv' WITH HEADER = TRUE;

--=========================
create table test_data.tab1 (id int primary key,email text, name text, phone text);


select COUNT(*) from kp_realstate.realestate_data;

COPY test_data.tab1 FROM 'test.csv';