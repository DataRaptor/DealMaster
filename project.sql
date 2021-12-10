-- Database Project on Shopping Assistant by Shamim Ahamed(Roll-1707028)

set serveroutput on

-- Drop tables
drop table merchant_city;
drop table cities;
drop table countries;
drop table likes;


drop table roles;
drop table my_coupons;
drop table order_items;
drop table reviews;
drop table orders;
drop table users;

drop table product_category;
drop table coupon_product;
drop table coupon_category;
drop table coupons;
drop table tags;
drop table products;
drop table merchants;
drop table categories;



-- Countries Table
create table countries(
    id numeric(3) not null primary key,
    country_name varchar(20) not null
);
-- Add autoincrement id
drop sequence countries_id_seq;
create sequence countries_id_seq start with 1;
create or replace trigger countries_id_trig
before insert on countries
for each row
begin
    select countries_id_seq.nextval into :new.id
    from dual;
end;
/
--describe countries;



-- Cities Table
create table cities (
    id numeric(10) not null,
    city_name varchar(20),
    country_id numeric(3),
    foreign key(country_id) references countries(id) on delete cascade
);
-- Add primary key
alter table cities add(
    constraint id_pk primary key(id)
);
-- Add autoincrement id
drop sequence cities_id_seq;
create sequence cities_id_seq start with 1;
create or replace trigger cities_id_trig
before insert on cities
for each row
begin
    select cities_id_seq.nextval into :new.id
    from dual;
end;
/
--describe cities;

-- Insert Procedure
create or replace procedure add_city (
    vcity_name in varchar,
    vcountry_name in varchar
) is 
    is_country_exist number(10);
    is_city_exist number(10);
begin 
    select count(*) into is_country_exist
    from countries
    where country_name = vcountry_name;

    -- Create country if not exist
    if(is_country_exist = 0) then
        dbms_output.put_line('COUNTRY '||vcountry_name || ' not exist. Creating now...');
        insert into countries (country_name) values (vcountry_name);
    end if;

    -- Check if city already exist
    select count(*) into is_city_exist
    from cities
    where city_name = vcity_name;
    if(is_city_exist = 0) then 
        insert into cities (city_name, country_id) 
        values (vcity_name, (select id from countries where country_name = vcountry_name));
        dbms_output.put_line('CITY: '||vcity_name||', '||vcountry_name || ' added.');
    end if;
end;
/

-- Get city_id
create or replace function get_city_id(
    vcity_name in varchar,
    vcountry_name in varchar
) return number is
    vcity_id number(10);
begin
    select cities.id into vcity_id
    from cities
    left join countries
    on cities.country_id = countries.id
    where city_name = vcity_name and country_name = vcountry_name;
    return vcity_id;
end;
/

--select * from countries;
--select * from cities;
--select get_city_id('AZ', 'USA1') from dual;




-- Users table
create table users(
    id number(10) not null primary key,
    email varchar(50) not null,
    password varchar(50),
    first_name varchar(50),
    last_name varchar(50),
    total_saved number(10) default 0 not null,
    balance number(10) default 0 not null,
    created_at date default sysdate,
    last_active date default sysdate
);
drop sequence users_id_seq;
create sequence users_id_seq start with 1;
create or replace trigger users_id_trig
before insert on users
for each row
begin
    select users_id_seq.nextval into :new.id
    from dual;
end;
/
insert into users (email) values ('a@g.com');
insert into users (email) values ('b@g.com');
select id, email from users;





-- My Coupons Table
create table my_coupons (
    id number(10) not null,
    user_id number(10) not null,
    coupon_code varchar(20),
    coupon_value number(10)
);
drop sequence my_coupons_seq;
create sequence my_coupons_seq start with 1;
create or replace trigger my_coupons_id_trig
before insert on my_coupons
for each row
begin
    select my_coupons_seq.nextval into :new.id
    from dual;
end;
/

insert into my_coupons (user_id, coupon_code, coupon_value) values (1, 'ABC', 120);
insert into my_coupons (user_id, coupon_code, coupon_value) values (1, 'CDE', 140);
insert into my_coupons (user_id, coupon_code, coupon_value) values (1, 'FDG', 160);

select * from my_coupons
where user_id = 1;

select user_id, count(coupon_value) as count, sum(coupon_value) as coupons_balance
from my_coupons
group by user_id;




-- Merchants Table
create table merchants (
    id numeric(10) not null primary key,
    public_id varchar(20),
    merchant_name varchar(30),
    address varchar(255),
    city_id numeric(10),
    phone varchar(255),
    rating numeric(10) default 0 not null,
    details varchar(255),
    visits numeric(10) default 0 not null,
    image_url varchar(255),
    total_likes numeric(10) default 0 not null,
    created_at date default sysdate not null
);
-- Auto Id
drop sequence merchants_id_seq;
create sequence merchants_id_seq start with 1;

-- Merchant City Relation Table
create table merchant_city(
    city_id number(10),
    merchant_id number(10),
    foreign key(city_id) references cities(id) on delete cascade,
    foreign key(merchant_id) references merchants(id) on delete cascade
);

-- Insert Merchant Procedure
create or replace function add_merchant (
    vmerchant_name in varchar,
    vcity_name in varchar,
    vcountry_name in varchar
) return number is 
    vmerchant_id number(10);
begin
    add_city(vcity_name, vcountry_name);
    select merchants_id_seq.nextval into vmerchant_id from dual;
    insert into merchants (id, merchant_name, city_id) 
    values (vmerchant_id, vmerchant_name, get_city_id(vcity_name, vcountry_name));
    dbms_output.put_line('added');
    return vmerchant_id;
end;
/
show errors;




-- Roles Table
create table roles(
    id number(10),
    user_id number(10) not null,
    merchant_id number(10) not null,
    role_name varchar(10)
);

-- Create Merchant
create or replace procedure create_merchant (
    vuser_id in number,
    vmerchant_name in varchar,
    vcity_name in varchar,
    vcountry_name in varchar
) is
begin
    insert into roles (user_id, merchant_id, role_name)
    values (
        vuser_id, 
        add_merchant(vmerchant_name, vcity_name, vcountry_name), 
        'admin'
    );
end;
/

-- Check if current user is merchant
create or replace function is_user_merchant(
    vuser_id number,
    vmerchant_id in number
) return number is
    vcount number(10);
begin
    select count(*) into vcount
    from users
    left join roles
    on users.id = roles.user_id
    where users.id = vuser_id and 
        roles.merchant_id = vmerchant_id and 
        roles.role_name = 'admin';
    return vcount;
end;
/

-- Insert Data
begin
    create_merchant(1, 'Kfc', 'Khulna', 'Bangladesh');
    create_merchant(1, 'Startech', 'Dhaka', 'Bangladesh');
    create_merchant(2, 'Google', 'NY', 'USA');
    create_merchant(1, 'Gamestop', 'AZ', 'USA');
end;
/

-- Display Tables
select id, merchant_name, city_id, created_at from merchants;
select * from roles;

-- Check permission: If current use is merchant
select is_user_merchant(1, 3) from dual;

-- Display all merchant under current user
select merchants.id, merchants.merchant_name from users
left join roles
on users.id = roles.user_id
left join merchants
on roles.merchant_id = merchants.id
where users.id = 1 and roles.role_name = 'admin';




-- Likes Table
create table likes(
    merchant_id number(10) not null,
    user_id number(10) not null,
    foreign key(merchant_id) references merchants(id) on delete cascade,
    foreign key(user_id) references users(id) on delete cascade
);
-- Increment like count
create or replace trigger like_trigger
before insert on likes
for each row
declare
    like_count number(10);
begin
    select total_likes into like_count
    from merchants
    where id = :new.merchant_id;

    like_count := like_count+1;
    update merchants 
    set total_likes = like_count
    where id = :new.merchant_id;
end;
/
-- Decrement like count
create or replace trigger unlike_trigger
before delete on likes
for each row 
declare
    like_count number(10);
begin 
    select total_likes into like_count
    from merchants
    where id = :old.merchant_id;

    like_count := like_count - 1;
    update merchants 
    set total_likes = like_count
    where id = :old.merchant_id;
end;
/

insert into likes (merchant_id, user_id) values (1, 1);
select * from likes;
select id, total_likes from merchants;

delete from likes;
select * from likes;
select id, total_likes from merchants;




-- Products Table
create table products (
    id number(10) not null primary key,
    product_name varchar(25),
    merchant_id number(10),
    price number(10) default 0,
    current_price number(10) default 0,
    status varchar(10) default 'active',
    created_at date default sysdate,
    rating number(3) default 0,
    is_online char(1) default 0
);
drop sequence products_id_seq;
create sequence products_id_seq start with 1;
create or replace trigger products_id_trig
before insert on products
for each row
begin
    select products_id_seq.nextval into :new.id
    from dual;
end;
/

-- Manage Product
create or replace function create_product (
    vuser_id in number,
    vmerchant_id in number,
    vproduct_name in varchar,
    vprice in number
) return number is
    vpermission number(3);
begin
    vpermission := is_user_merchant(vuser_id, vmerchant_id);
    if(vpermission = 0) then
        dbms_output.put_line('Permission Denied');
        return 0;
    end if;

    insert into products (product_name, merchant_id, price)
    values (vproduct_name, vmerchant_id, vprice);

    dbms_output.put_line('Product Added:  ' || vproduct_name);
    return 1;
end;
/

-- Add products
declare
    vvar number(10);
begin
    vvar := create_product(1, 1, 'product1', 10);
    vvar := create_product(1, 1, 'product2', 30);
    vvar := create_product(1, 1, 'product3', 40);
    vvar := create_product(1, 1, 'product4', 50);
    vvar := create_product(1, 1, 'product5', 60);
    vvar := create_product(1, 1, 'product6', 70);
end;
/
select id, product_name, merchant_id, price from products;





-- Product Tags Table
create table tags (
    product_id number(10),
    title varchar(15),
    foreign key(product_id) references products(id) on delete cascade
);

-- Add product tags
insert into tags values (1, 'watch');
insert into tags values (1, 'wearables');
insert into tags values (2, 'phone');
insert into tags values (2, 'smartphone');
insert into tags values (3, 'cloath');
select * from tags;

-- Search product using tag
select products.id, products.product_name, products.price from tags
left join products
on tags.product_id = products.id
where tags.title = 'phone';




-- Category Table
create table categories(
    id number(10) not null primary key,
    title varchar(20),
    parent_id number(10),
    foreign key(parent_id) references categories(id) on delete cascade
);
drop sequence categories_id_seq;
create sequence categories_id_seq start with 1;
create or replace trigger categories_id_trig
before insert on categories
for each row
begin
    select categories_id_seq.nextval into :new.id
    from dual;
end;
/

-- Insert data
insert into categories (title, parent_id) values ('Electronics', null);
insert into categories (title, parent_id) values ('Smart Phone', 1);
insert into categories (title, parent_id) values ('Smart Watch', 1);
insert into categories (title, parent_id) values ('Fans', 1);
insert into categories (title, parent_id) values ('Table Fan', 4);
insert into categories (title, parent_id) values ('Ceiling Fan', 4);
insert into categories (title, parent_id) values ('Clothing', null);
select * from categories;



-- Product Category Relation
create table product_category(
    product_id number(10) not null,
    category_id number(10) not null,
    foreign key(product_id) references products(id) on delete cascade,
    foreign key(category_id) references categories(id) on delete cascade
);

-- Insert Data
insert into product_category values (1, 1);
insert into product_category values (1, 2);
insert into product_category values (2, 5);
insert into product_category values (3, 6);
select * from product_category;

-- Search produce by category





-- Coupons Table
create table coupons(
    id number(10) not null primary key,
    merchant_id number(10),
    category_id number(10),
    code varchar(30),
    description varchar(50),
    coupon_type varchar(20),
    amount number(10),
    is_fixed char(1),
    min_spend number(10),
    max_spend number(10),
    foreign key(merchant_id) references merchants(id) on delete cascade
);
drop sequence coupons_id_seq;
create sequence coupons_id_seq start with 1;
create or replace trigger coupons_id_trig
before insert on coupons
for each row
begin
    select coupons_id_seq.nextval into :new.id
    from dual;
end;
/

-- Insert Coupons
insert into coupons (merchant_id, code, amount) values (1, 'ABC', 120);
insert into coupons (merchant_id, code, amount) values (1, 'BCD', 500);
insert into coupons (merchant_id, code, amount) values (1, 'ACB', 900);
select id, merchant_id, code, amount from coupons;



-- Coupon Product Relation
create table coupon_product(
    coupon_id number(10),
    product_id number(10),
    foreign key(coupon_id) references coupons(id) on delete cascade,
    foreign key(product_id) references products(id) on delete cascade
);

insert into coupon_product values (1, 1);
insert into coupon_product values (2, 2);
insert into coupon_product values (3, 2);
select * from coupon_product;


-- Coupon Category Relation
create table coupon_category(
    coupon_id number(10),
    category_id number(10),
    foreign key(coupon_id) references coupons(id) on delete cascade,
    foreign key(category_id) references categories(id) on delete cascade
);

insert into coupon_category values (1, 1);
insert into coupon_category values (1, 3);
select * from coupon_category;





-- Orders Table
create table orders (
    id number(10) not null primary key,
    user_id number(10) not null,
    status varchar(10) default 'active',
    created_at date default sysdate not null,
    foreign key(user_id) references users(id) on delete cascade
);
drop sequence orders_id_seq;
create sequence orders_id_seq start with 1;
create or replace trigger order_id_trig
before insert on orders
for each row
begin
    select orders_id_seq.nextval into :new.id
    from dual;
end;
/

insert into orders (user_id) values (1);
insert into orders (user_id) values (1);
insert into orders (user_id) values (1);


-- Order Items
create table order_items (
    order_id number(10),
    product_id number(10),
    quantity number(10),
    foreign key(order_id) references orders(id) on delete cascade,
    foreign key(product_id) references products(id) on delete cascade
);

insert into order_items values (1, 1, 10);
insert into order_items values (1, 2, 10);
insert into order_items values (1, 4, 10);
insert into order_items values (2, 1, 10);
insert into order_items values (2, 2, 10);



-- Reviews table
create table reviews (
    order_id number(10),
    user_id number(10),
    rating number(10),
    text varchar(40),
    foreign key(order_id) references orders(id) on delete cascade,
    foreign key(user_id) references users(id) on delete cascade
);

insert into reviews (order_id, user_id, rating, text) values (1, 1, 5, 'Good');
insert into reviews (order_id, user_id, rating, text) values (2, 1, 5, 'Good');
insert into reviews (order_id, user_id, rating, text) values (3, 1, 5, 'Good');
select order_id, user_id, rating, text from reviews;

commit;
