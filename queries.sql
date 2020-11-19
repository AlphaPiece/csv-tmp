/*
** Q1. Find the most expensive non-zero hour least played game on
** each specific platform with its price one of its supported
** languages is English.
**
** Expected column: plaform, game_id, price
*/

drop table if exists q1 cascade;
create table q1 (
	platform text,
	game_id int references Game(game_id),
	price float,
	primary key (platform, game_id),
	check (platform = 'Mac' or platform = 'Windows' or platform = 'Linux')
);

drop view if exists EnglishSupported cascade;
create view EnglishSupported as
select game_id
from Language
where languages like '%English%';

drop view if exists LeastPlayed cascade;
create view LeastPlayed as
select platform, game_id, price, average_playtime
from (Platform natural join EnglishSupported natural join
	Price natural join Playtime) T1
where T1.average_playtime <= all(
	select average_playtime
	from Playtime natural join Platform
	where average_playtime <> 0
) and T1.average_playtime <> 0;

drop view if exists MostExpensive cascade;
create view MostExpensive as
select platform, max(price) as max_price
from LeastPlayed
group by platform;

insert into q1
select T1.platform, game_id, price
from LeastPlayed T1 join MostExpensive T2 on T1.platform = T2.platform
where T1.price = T2.max_price;


/*
** Q2. Find the games which are the most popular.
** The most popular game is defined as:
** (1) the number of positive reviews is greater than
** the 80% of the total number of reviews;
** (2) the number of total reviews is greater than every
** other game on steam.
** There can be more than one most popular game.
*/

drop table if exists q2 cascade;
create table q2 (
	game_id int references Game(game_id)
);

drop view if exists Condition1 cascade;
create view Condition1 as
select game_id
from Rating T1
where T1.positive_ratings::float / (T1.positive_ratings + T1.negative_ratings) > 0.8;

drop view if exists Condition2 cascade;
create view Condition2 as
select game_id
from Rating T1
where T1.positive_ratings + T1.negative_ratings >= all(
	select positive_ratings + negative_ratings
	from Rating T2
);

insert into q2
(select * from Condition1)
intersect
(select * from Condition2);


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
