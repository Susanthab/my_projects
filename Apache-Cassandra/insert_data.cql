


CREATE KEYSPACE hr
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

INSERT INTO hr.employee  (id, emp_name, emp_city) VALUES (1, 'Susantha Bathige', 'Colorado') USING TTL 86400;