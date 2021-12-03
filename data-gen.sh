#!/bin/sh

export customersLen=200000
export ordersPerIteration=100
export sleepInterval=1
export PGPASSWORD=$POSTGRES_PASSWORD

echo "creating schema"

until psql --host=postgres --user=$POSTGRES_USER  --dbname=$POSTGRES_DB --command="select 1"
do
  echo "Waiting for database to become available"
  sleep 1
done

psql --host=postgres --user=$POSTGRES_USER  --dbname=$POSTGRES_DB << SQL
create table customers (
  uidpk serial,
  created_date varchar(20) default to_char(current_timestamp,'YYYY-MM-DD HH:MI:SS'),
  email varchar(255) unique not null,
  primary key(uidpk)
);

alter table customers replica identity full;

create table orders (
  uidpk serial,
  created_date varchar(20) default to_char(current_timestamp,'YYYY-MM-DD HH:MI:SS'),
  total decimal(19,2) default null,
  status varchar(20) default null,
  order_number varchar(64) not null,
  customer_uid integer,
  primary key(uidpk),
  constraint customer_fk foreign key(customer_uid) references customers(uidpk) on delete set null
);

alter table orders replica identity full;

create table orders_agg (
  customer_uid integer,
  email varchar(255) unique not null,
  total decimal(19,2) default null,
  primary key(customer_uid)
);
SQL

echo "inserting $customersLen customers"

psql --host=postgres --user=$POSTGRES_USER  --dbname=$POSTGRES_DB << SQL
insert into customers (email) 
select 'hodor@'||random() 
from generate_series(1,$customersLen);
SQL

while true; do
  echo "inserting $ordersPerIteration orders"

  psql --host=postgres --user=$POSTGRES_USER  --dbname=$POSTGRES_DB << SQL
  insert into orders (total, status, order_number, customer_uid) 
  select
  	100*random(), 
  	'COMPLETED', 
  	md5(random()::text || clock_timestamp()::text),
  	trunc(random() * $customersLen  + 1)
  from generate_series(1,$ordersPerIteration);
SQL

  sleep $sleepInterval
done