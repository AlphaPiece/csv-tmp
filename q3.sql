/*
** Q3. Find all the infamous developers.
** An infamous developer is defined as:
** (1) every game they released received more negative
** reviews than positive reviews;
** (2) the number of negative reviews of each game is greater than 1000. 
*/

drop table if exists q3 cascade;
create table q3 (
	developer text not null
);

drop view if exists AtLeastOneGood cascade;
create view AtLeastOneGood as
select developer
from (Develop D1 join Rating R1 on D1.game_id = R1.game_id) as T1
where T1.positive_ratings > T1.negative_ratings;

drop view if exists Condition1 cascade;
create view Condition1 as
(select developer from Develop)
except
(select developer from AtLeastOneGood);

drop view if exists AtLeastOneLess cascade;
create view AtLeastOneLess as
select developer
from (Develop D1 join Rating R1 on D1.game_id = R1.game_id) as T1
where T1.negative_ratings <= 1000;

drop view if exists Condition2 cascade;
create view Condition2 as
(select developer from Develop)
except
(select developer from AtLeastOneLess);

insert into q3
(select * from Condition1)
intersect
(select * from Condition2);
