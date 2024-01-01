create table public.sellers(
    snum int not null,
    sname text not null,
    city text not null,
    comm float not null
);
create table public.customers(
    cnum int not null,
    cname text not null,
    city text not null,
    rating int not null,
    snum int not null
);
create table public.orders(
    onum int not null,
    amt float not null,
    odate date not null default (date '01.01.0001'),
    cnum int not null,
    snum int not null
);
insert into orders
values
        (3001,18.69,'10.03.1990',2008,1007),
        (3003,767.19,'10.03.1990',2001,1001),
        (3002,1900.10,'10.03.1990',2007,1004),
        (3005,5160.45,'10.03.1990',2003,1002),
        (3006,1098.16, '10.03.1990',2008,1007),
        (3009,1713.23,'10.04.1990',2002,1003),
        (3007,75.75,'10.04.1990',2004,1002),
        (3008,4723.00,'10.05.1990',2006,1001),
        (3010,1309.95,'10.06.1990',2004,1002),
        (3011,9891.88,'10.06.1990',2006,1001);

select * from customers;

--1.1
select * from orders where odate='10.03.1990';
select * from orders where odate='10.04.1990';
--1.2
select *
from customers c, sellers s
where ((s.sname='Peel' or s.sname='Motika') and (c.snum=s.snum));
--1.3
select *
from customers
where cname between 'A' and 'G';
--1.4
select *
from customers
where cname like 'C%';
--1.5
select * from orders where amt <>0 and (amt is not null);
--2.1
select sum(amt) from orders;
--2.2
select count(distinct city) from customers;
--2.3
select min(amt), c.cname,c.cnum
from orders o
inner join customers c using(cnum)
group by cname, c.cnum;
--2.4
select distinct * from customers
where cname like 'G%'
order by cname asc;
--2.5
select distinct city, max(rating) from customers
group by city;
--2.6
select odate, count(distinct snum)
from orders
group by odate;
--3.1
select onum, snum, amt*0.12 from orders;
--3.2
select distinct 'For the city', city, 'the highest rating is:', max(rating) from customers
group by city;
--3.3
select rating, cname, cnum from customers
order by rating desc;
--3.4
select odate, sum(amt) from orders
group by odate order by 2 desc;
--4.1+4.2
select distinct onum, cname, sname from
(orders inner join customers on orders.cnum=customers.cnum)
inner join sellers on orders.snum=sellers.snum
group by onum,cname, sname
order by onum asc;
--4.3
select cname, sname, comm
from customers inner join sellers using (snum)
where comm >= 0.12
order by sname asc;
--4.4
select distinct onum, comm*amt, sname
from (sellers inner join customers on rating>100)
inner join orders on orders.snum=sellers.snum
order by onum;
--5.1
select onum
from orders where cnum=
                     (select cnum from customers where cname='Cisneros');
--5.2
select distinct cname,rating,amt
from customers,orders where amt=
                     (select avg(amt) from orders where customers.cnum=orders.cnum);
--5.3
select sname, sum(amt)
from orders
    inner join sellers using (snum)
group by sname
having sum(amt) > (select max(amt) from orders);
--5.4
select cname, cnum, rating,city
from customers _out where rating in
               (select max(rating) from customers _in where _out.city=_in.city );
--5.5 (через объединение)
select distinct s.snum, sname from sellers s,customers c
where (s.city=c.city) and (s.snum !=c.snum);
--5.5(через подзапрос)
select snum,sname from sellers
where city in
      (select city from customers where sellers.snum != customers.snum);
--6.1
select * from sellers where exists
    (select * from customers
              where rating =300 and sellers.snum=customers.snum);
--6.2
select * from sellers s,customers c
where (c.rating=300) and (s.snum=c.snum);
--6.3
select snum,sname from sellers s
where exists
      (select c.cnum from customers c
                where (s.snum != c.snum) and (s.city=c.city));
--6.4
select * from customers c
where exists ( select * from orders o
                where c.snum= o.snum and c.cnum != o.cnum);
--6.5+6.6
select * from customers c
where rating >= any
      (select rating from customers inner join sellers using (snum) where sname='Serres');
--6.7
select distinct s.snum, sname from sellers s
where city = any (select city from customers c where s.snum != c.snum);
--6.8
select * from orders
where amt > any (select amt from orders
                 inner join customers c using (cnum)
                 where c.city='London');
--6.9
select * from orders where amt >
     (select max(amt) from orders inner join customers c using (cnum)
        where c.city='London');
--7.1
select cname,city,'Высокий рейтинг',rating from customers where rating >=200
union
select cname,city,'Низкий рейтинг',rating from customers where rating <=200
order by rating;
--7.2
select sname,'seller with number',snum from sellers s
where 1 < (select count(*) from orders o where s.snum=o.snum)
union
select cname,'customer with number',cnum from customers c
where 1 < (select count(*) from orders o where c.cnum=o.cnum)
order by 2 asc;
--7.3
select snum from sellers where city='San Jose'
union
(select cnum from customers where city='San Jose'
union all
select onum from orders where odate='03.10.1990');
--8.1( comm у меня изначально подразумевался как столбец not null, поэтому 0
update sellers
set snum=1100,sname='Bianco',city='San Jose',comm=0
 where snum= (select o.snum from orders o where onum=3001);
update orders set snum=1100 where onum=3001;--для соответствия таблиц
--обратный запрос (вернуть как было)
update sellers
set snum=1007, sname='Rifkin',city='Barcelona',comm=0.15
where snum=1100;
update orders set snum=1007 where onum=3001;
--8.2+обратный
delete from orders where cnum=
                         (select cnum from customers where cname='Clemens');

insert into orders
values (3008,4723.00,'10.05.1990',2006,1001),
       (3011,9891.88,'10.06.1990',2006,1001);
--8.3+обратный
update customers
set rating=rating+100 where city='Rome';

update customers
set rating=rating-100 where city='Rome';
--8.4+обратный
update customers
set snum=(select snum from sellers where sname='Motika')
where snum=(select snum from sellers where sname='Serres');

update customers
set snum=(select snum from sellers where sname='Serres')
where cname ='Liu' or cname='Grass';
--9.1
insert into multicast
select * from sellers s where 1 <
        (select count(*) from customers c where s.snum=c.snum);
--9.2
delete from customers c where 0=
                            (select count(*) from orders o where c.cnum=o.cnum);
--9.3+back
update sellers s
set comm=comm*1.2 where 3000 <
            (select sum(amt) from orders o where s.snum=o.snum);

update sellers s
set comm=comm/1.2 where 3000 <
            (select sum(amt) from orders o where s.snum=o.snum);
--10.1
create table public.customers(
    cnum int not null,
    cname text not null,
    city text not null,
    rating int not null,
    snum int not null
);
--10.2+back
create index order_date on orders (odate);

drop index order_date;
--10.3+back
create unique index order_num_key on orders(onum);

drop index order_num_key;
--10.4+back
create index order_num_date on orders(onum,odate);

drop index order_num_date;
--10.5 (предполагая что у каждого продавца только один заказчик(не наш случай))
create unique index customer_key on customers(snum,rating);
select * from customers use (customer_key);
drop index customer_key;
--11.1
create table public.orders(
    onum integer not null unique,
    amt float not null,
    odate date not null default (date '01.01.0001'),
    cnum int not null,
    snum int not null,
    unique(cnum,snum)
) ;
--11.2
create table public.sellers(
    snum int not null primary key,
    sname text not null check (sname between 'AA' and 'MZ'),
    city text not null,
    comm float not null default 0.1
);
--11.3
create table public.orders(
    onum int not null primary key,
    amt float not null,
    odate date not null default (date '01.01.0001'),
    cnum int not null,
    snum int not null
    check (onum>cnum and cnum>snum)
);
--11.4
create table public.Cityorders(
    onum int not null primary key,
    amt float not null,
    snum int not null references orders(onum,amt,snum),
    cnum int not null references customers(cnum,city),
    city text not null
);
--11.5
alter table orders add column prev int not null;
alter table orders add foreign key (cnum,prev) references orders(cnum,onum);
alter table orders add unique(cnum,onum);
--12.1
create view high_rating as
select * from customers where rating=(select max(rating) from customers);
--12.2
create view snumCity as
select distinct snum,city from sellers group by city,snum;
--12.3
create view orderSeller as
select sname, avg(amt), sum(amt) from sellers inner join orders using (snum)
group by sname;
select * from orderSeller;
--12.4
create view manyCustomers as
select * from sellers s where 1< (select count(*) from customers c where s.snum=c.snum);
select * from manyCustomers;
--12.5
--view #4
--12.6
create view Comissions as
select comm,snum from sellers where comm>0.1 and comm<0.2
with check option;
--12.7
create table Orders(
  onum int primary key,
  amt float not null,
  snum int not null references sellers(snum),
  cnum int not null references customers(cnum),
  odate date not null default(current_date)
);
create view Entryorders as
    select onum,amt,snum,cnum from Orders;


