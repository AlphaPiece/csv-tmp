/*
** Game
*/

insert into Game(game_title, genre, release_date, developer)
select distinct T1.name, genre, release_date, developer
from SteamGame T1 join (select name from SteamData) T2 on T1.name = T2.name
where developer is not null and all_reviews <> 'NaN';

/*
** Develop
*/

insert into Develop(developer, game_id)
select developer, game_id
from Game;

/*
** Platform
*/

drop view if exists Mac cascade;
create view Mac as
select name, 'Mac' as platform
from SteamGame
where minimum_requirements like '%Mac%';

drop view if exists Windows cascade;
create view Windows as
select name, 'Windows' as platform
from SteamGame
where minimum_requirements like '%Windows%';

drop view if exists Linux cascade;
create view Linux as
select name, 'Linux' as platform
from SteamGame
where minimum_requirements like '%Linux%';

insert into Platform(game_id, platform)
select game_id, platform
from ((select * from Mac) union
          (select * from Windows) union
          (select * from Linux)) T1 join
         Game on T1.name = Game.game_title
order by game_id;

/*
** Rating
*/

insert into Rating(game_id, positive_ratings, negative_ratings)
select game_id,
       cast(positive_ratings as integer),
       cast(negative_ratings as integer)
from (select game_id, game_title from Game) T1 join
     (select name, positive_ratings, negative_ratings from SteamData) T2 on
     game_title = name;

/*
** Playtime
*/

insert into Playtime(game_id, average_playtime, median_playtime)
select game_id,
       cast(average_playtime as integer),
       cast(median_playtime as integer)
from (select game_id, game_title from Game) T1 join
     (select name, average_playtime, median_playtime from SteamData) T2 on
     game_title = name;

/*
** Language
*/

insert into Language(game_id, languages)
select game_id, languages
from (select game_id, game_title from Game) T1 join
         (select name, languages from SteamGame) T2 on game_title = name;

/*
** Price
*/

update SteamGame
set original_price = '$0.00'
where original_price not like '$%';

update SteamGame
set discount_price = '$0.00'
where discount_price not like '$%';

update SteamGame
set original_price = substr(original_price, 2, length(original_price) - 1),
    discount_price = substr(discount_price, 2, length(original_price) - 1);

insert into Price(game_id, price, discount_price)
select game_id,
       cast(original_price as double precision),
       cast(discount_price as double precision)
from (select name, original_price, discount_price from SteamGame) T1 join
     (select game_id, game_title from Game) T2 on name = game_title;
