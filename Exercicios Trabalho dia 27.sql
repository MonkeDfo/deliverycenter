CREATE database db_deliverycenter;

USE db_deliverycenter;

CREATE TABLE `db_deliverycenter`.`channels` (
  `channel_id` int DEFAULT NULL,
  `channel_name` text,
  `channel_type` text);

CREATE TABLE `db_deliverycenter`.`hubs` (
  `hub_id` int DEFAULT NULL,
  `hub_name` text,
  `hub_city` text,
  `hub_state` text,
  `hub_latitude` double DEFAULT NULL,
  `hub_longitude` double DEFAULT NULL);

CREATE TABLE `db_deliverycenter`.`stores` (
  `store_id` int DEFAULT NULL,
  `hub_id` int DEFAULT NULL,
  `store_name` text,
  `store_segment` text,
  `store_plan_price` int DEFAULT NULL,
  `store_latitude` text,
  `store_longitude` text);


CREATE TABLE `db_deliverycenter`.`drivers` (
  `driver_id` int DEFAULT NULL,
  `driver_modal` text,
  `driver_type` text);


CREATE TABLE `db_deliverycenter`.`deliveries` (
  `delivery_id` int DEFAULT NULL,
  `delivery_order_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `delivery_distance_meters` int DEFAULT NULL,
  `delivery_status` text);


CREATE TABLE `db_deliverycenter`.`payments` (
  `payment_id` int DEFAULT NULL,
  `payment_order_id` int DEFAULT NULL,
  `payment_amount` double DEFAULT NULL,
  `payment_fee` double DEFAULT NULL,
  `payment_method` text,
  `payment_status` text);


CREATE TABLE `db_deliverycenter`.`orders` (
  `order_id` int DEFAULT NULL,
  `store_id` int DEFAULT NULL,
  `channel_id` int DEFAULT NULL,
  `payment_order_id` int DEFAULT NULL,
  `delivery_order_id` int DEFAULT NULL,
  `order_status` text,
  `order_amount` double DEFAULT NULL,
  `order_delivery_fee` int DEFAULT NULL,
  `order_delivery_cost` text,
  `order_created_hour` int DEFAULT NULL,
  `order_created_minute` int DEFAULT NULL,
  `order_created_day` int DEFAULT NULL,
  `order_created_month` int DEFAULT NULL,
  `order_created_year` int DEFAULT NULL,
  `order_moment_created` text,
  `order_moment_accepted` text,
  `order_moment_ready` text,
  `order_moment_collected` text,
  `order_moment_in_expedition` text,
  `order_moment_delivering` text,
  `order_moment_delivered` text,
  `order_moment_finished` text,
  `order_metric_collected_time` text,
  `order_metric_paused_time` text,
  `order_metric_production_time` text,
  `order_metric_walking_time` text,
  `order_metric_expediton_speed_time` text,
  `order_metric_transit_time` text,
  `order_metric_cycle_time` text);

/* 1- Qual o número de hubs por cidade? */

select * from hubs;

select count(hub_name) from hubs;

/* 2- Qual o número de pedidos (orders) por status? */

select count(order_status) as 'Quantidades de Pedidos', 'Finalizados' as Status_Pedido from orders
where order_status = 'FINISHED'
union
select count(order_status), 'Cancelados' as Status_Pedido from orders
where order_status = 'CANCELED';


select count(order_status), order_status from orders
group by order_status;

/* 3- Qual o número de lojas (stores) por cidade dos hubs? */

select count(hub_city), hub_city from hubs
group by hub_city;

/* 4- Qual o maior e o menor valor de pagamento (payment_amount) registrado? */

select max(payment_amount), min(payment_amount) from payments;

/* 5- Qual tipo de driver (driver_type) fez o maior número de entregas? */

select count(driver_type) as 'Entregas', driver_type from drivers
group by driver_type;

/* 6- Qual a distância média das entregas por tipo de driver (driver_modal)? */

select avg(delivery_distance_meters) from deliveries;

/* 7- Qual a média de valor de pedido (order_amount) por loja, em ordem decrescente? */

select * from orders;
select * from stores;
select * from payments;

select s.store_name, o.order_amount from stores s
inner join orders o on o.store_id = s.store_id
group by s.store_name;

/* 8- Existem pedidos que não estão associados a lojas? Se caso positivo, quantos? */
 
select COUNT(*) as orders_sem_loja from orders
where store_id is null;

/* 9- Qual o valor total de pedido (order_amount) no channel 'FOOD PLACE' */

select sum(o.order_amount) as total_pedido from orders as o
inner join channels as c on o.channel_id = c.channel_id
where c.channel_name = 'FOOD PLACE';

/* 10- Quantos pagamentos foram cancelados (chargeback)? */

select count(*) as pagamentos_cancelados from payments
where payment_status = 'chargeback';

/* 11- Qual foi o valor médio dos pagamentos cancelados (chargeback)? */

select avg(payment_amount) as media_pagamentos_cancelados from payments
where payment_status = 'chargeback';

/* 12- Qual a média do valor de pagamento por método de pagamento (payment_method) em ordem decrescente? */

select payment_method, avg(payment_amount) as media_pagamento_metodo from payments
group by payment_method
order by media_pagamento_metodo desc;

/* 13- Quais métodos de pagamento tiveram valor médio superior a 100? */

select payment_method from payments
group by payment_method
having avg(payment_amount) > 100;

/* 14- Qual a média de valor de pedido (order_amount) por estado do hub (hub_state), segmento da loja (store_segment) e tipo de canal (channel_type)? */

select hu.hub_state, s.store_segment, ch.channel_type, AVG(ord.order_amount) AS average_order_amount
from orders as ord
inner join stores as s on ord.store_id = s.store_id
inner join channels as ch on ord.channel_id = ch.channel_id
inner join hubs as hu on s.hub_id = hu.hub_id
group by hu.hub_state, s.store_segment, ch.channel_type;

/* 15- Qual estado do hub (hub_state), segmento da loja (store_segment) e tipo de canal (channel_type) teve média de valor de pedido (order_amount) maior que 450? */

select hu.hub_state, s.store_segment, ch.channel_type from hubs as hu
left join stores as s on hu.hub_id = s.hub_id
left join orders as ord on s.store_id = ord.store_id
left join channels as ch on ord.channel_id = ch.channel_id
group by hu.hub_state, s.store_segment, ch.channel_type
having avg(ord.order_amount) > 450;