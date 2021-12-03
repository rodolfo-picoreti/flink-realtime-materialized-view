from pyflink.table import DataTypes, StreamTableEnvironment, EnvironmentSettings

settings = EnvironmentSettings.new_instance().in_streaming_mode().use_blink_planner().build()

t_env = StreamTableEnvironment.create(environment_settings=settings)

sql_query = """
  create catalog postgres with (
    'type'='jdbc',
    'property-version'='1',
    'base-url'='jdbc:postgresql://postgres:5432/',
    'default-database'='postgres',
    'username'='postgres',
    'password'='postgres'
  );

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

  create table orders_agg_index (
    customer_uid integer primary key not enforced,
    email string,
    total decimal(38,2)
  ) with (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://elasticsearch:9200',
    'index' = 'orders_agg'
  );

  insert into orders_agg_index
    select 
      orders.customer_uid as customer_uid,
      customers.email as email,
      sum(orders.total) as total
    from orders 
    left join customers on customers.uidpk = orders.customer_uid
    where orders.status = 'COMPLETED'
    group by 
      orders.customer_uid,
      customers.email;
"""

for query in sql_query.split(';')[:-1]:
  print(f'\nExecuting: \n{query}', flush=True)
  t_env.execute_sql(query)
