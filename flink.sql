-- create schema catalog

create catalog postgres with (
  'type'='jdbc',
  'property-version'='1',
  'base-url'='jdbc:postgresql://postgres:5432/',
  'default-database'='postgres',
  'username'='postgres',
  'password'='postgres'
);

-- replicated tables to flink but via kafka

create table orders with (
  'connector' = 'kafka',
  'topic' = 'pg.public.orders',
  'properties.bootstrap.servers' = 'broker:29092',
  'properties.group.id' = 'flink-sql-orders-consumer-group',
  'format' = 'debezium-json',
  'scan.startup.mode' = 'earliest-offset'
 )
like postgres.postgres.`public.orders` (excluding options);

create table customers with (
  'connector' = 'kafka',
  'topic' = 'pg.public.customers',
  'properties.bootstrap.servers' = 'broker:29092',
  'properties.group.id' = 'flink-sql-customers-consumer-group',
  'format' = 'debezium-json',
  'scan.startup.mode' = 'earliest-offset'
 )
like postgres.postgres.`public.customers` (excluding options);

-- test queries

select * from orders 
left join customers on customers.uidpk = orders.customer_uid;

-- create table directly on DB

create table orders_agg
like postgres.postgres.`public.orders_agg` 
(including options);

-- insert back into DB

insert into orders_agg
  select 
    customers.uidpk as customer_uid,
    sum(orders.total) as total
  from orders 
  left join customers on customers.uidpk = orders.customer_uid
  where orders.status = 'COMPLETED'
  group by 
    customers.uidpk;
