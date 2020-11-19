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
where T1.positive_ratings / (T1.positive_ratings + T1.negative_ratings) > 0.8;

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
