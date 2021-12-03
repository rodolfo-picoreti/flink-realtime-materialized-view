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
