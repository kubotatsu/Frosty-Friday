-- startup
-- 初期設定
create database week_34_db;
create schema ans1_schema;

create or replace table start_data(
    code VARCHAR
  , code_parent VARCHAR
  , valid_until DATE
  , valid_from DATE
  , is_lowest_level BOOLEAN
  , max_level INTEGER
)
as
select * from values
    ('CC0193','EBGABA','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',1,7)
  , ('CC0194','EBGABA','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',1,7)
  , ('EBGABA','EBGAB','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EBGAB','EBGA','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EBGA','EBG','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EBG','EB','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EB','ZZ','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('ZZ',NULL,'9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('7050307','CC','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',1,3)
  , ('CC','A1','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,3)
  , ('A1',NULL,'9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,3)
;


-- answer no.1
-- 再起With句を使って、自己参照しよう！ 1
with recursive r as (
    select 
        to_array(code) as code_array,
        max_level as level,
        1 as depth,
        code_parent
    from
        start_data
    where
        is_lowest_level = 1
        
    union all
    
    select 
        array_cat(code_array,to_array(start_data.code)) as code_array,
        r.level - 1 as level,
        r.depth + 1 as depth,
        start_data.code_parent
    from
        start_data, r
    where
        start_data.code = r.code_parent
)
select
    (case when depth - 1 < 0 then code_array[0] else code_array[depth - 1] end)::varchar as level_1,
    (case when depth - 2 < 0 then code_array[0] else code_array[depth - 2] end)::varchar as level_2,
    (case when depth - 3 < 0 then code_array[0] else code_array[depth - 3] end)::varchar as level_3,
    (case when depth - 4 < 0 then code_array[0] else code_array[depth - 4] end)::varchar as level_4,
    (case when depth - 5 < 0 then code_array[0] else code_array[depth - 5] end)::varchar as level_5,
    (case when depth - 6 < 0 then code_array[0] else code_array[depth - 6] end)::varchar as level_6,
    (case when depth - 7 < 0 then code_array[0] else code_array[depth - 7] end)::varchar as level_7
from r
where level = 1
;

----
-- 再起With句を使って、自己参照しよう！ 2
with recursive r as (
    select 
        to_array(code) as code_array,
        1 as depth,
        *
    from
        start_data
    where
        code_parent is null
        
    union all
    
    select 
        array_cat(to_array(start_data.code),code_array) as code_array,
        r.depth + 1 as depth,
        start_data.*
    from
        start_data, r
    where
        start_data.code_parent = r.code
)
select
    (case when depth - 1 < 0 then code_array[0] else code_array[depth - 1] end)::varchar as level_1,
    (case when depth - 2 < 0 then code_array[0] else code_array[depth - 2] end)::varchar as level_2,
    (case when depth - 3 < 0 then code_array[0] else code_array[depth - 3] end)::varchar as level_3,
    (case when depth - 4 < 0 then code_array[0] else code_array[depth - 4] end)::varchar as level_4,
    (case when depth - 5 < 0 then code_array[0] else code_array[depth - 5] end)::varchar as level_5,
    (case when depth - 6 < 0 then code_array[0] else code_array[depth - 6] end)::varchar as level_6,
    (case when depth - 7 < 0 then code_array[0] else code_array[depth - 7] end)::varchar as level_7
from r
where is_lowest_level = true
;


-- answer no.2
-- connect byを使ってみよう。

with t as (
select
    split(SYS_CONNECT_BY_PATH(code, ','), ',') as code_array,
    *
from start_data
start with code_parent is null
connect by code_parent = prior code
)
select
    code_array,
    array_size(code_array),
    (case when array_size(code_array) - 1 < 1 then code_array[array_size(code_array)-1] else code_array[1] end)::varchar as level_1,
    (case when array_size(code_array) - 2 < 1 then code_array[array_size(code_array)-1] else code_array[2] end)::varchar as level_2,
    (case when array_size(code_array) - 3 < 1 then code_array[array_size(code_array)-1] else code_array[3] end)::varchar as level_3,
    (case when array_size(code_array) - 4 < 1 then code_array[array_size(code_array)-1] else code_array[4] end)::varchar as level_4,
    (case when array_size(code_array) - 5 < 1 then code_array[array_size(code_array)-1] else code_array[5] end)::varchar as level_5,
    (case when array_size(code_array) - 6 < 1 then code_array[array_size(code_array)-1] else code_array[6] end)::varchar as level_6,
    (case when array_size(code_array) - 7 < 1 then code_array[array_size(code_array)-1] else code_array[7] end)::varchar as level_7
from t
where
    is_lowest_level = True


