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
