drop schema if exists steamschema cascade; 
CREATE schema steamschema;
SET search_path TO steamschema;

CREATE TABLE  Game(
	game_id SERIAL UNIQUE PRIMARY KEY,
	game_title TEXT NOT NULL,
	genre TEXT,
	release_date TEXT NOT NULL,
	developer TEXT NOT NULL
);

CREATE TABLE Develop(
	developer TEXT,
	game_id INTEGER REFERENCES Game(game_id)
);

CREATE TABLE Platform(
	game_id INTEGER REFERENCES Game(game_id),
	platform TEXT
);
	
CREATE TABLE Rating(
	game_id INTEGER REFERENCES Game(game_id),
	positive_ratings INTEGER,
	negative_ratings INTEGER
);

CREATE TABLE Playtime(
	game_id INTEGER REFERENCES Game(game_id),
	average_playtime INTEGER,
	median_playtime INTEGER
);

CREATE TABLE Language(
	game_id INTEGER REFERENCES Game(game_id),
	languages TEXT
);

CREATE TABLE Price(
	game_id INTEGER REFERENCES Game(game_id),
	price FLOAT,
	discount_price FLOAT
);

CREATE TABLE SteamGame(
	url TEXT,
	types TEXT,
	name TEXT,
	desc_snippet TEXT,
	recent_reviews TEXT,
	all_reviews TEXT,
	release_date TEXT,
	developer TEXT,
	publisher TEXT,
	popular_tags TEXT,
	game_details TEXT,
	languages TEXT,
	achievements TEXT,
	genre TEXT,
	game_description TEXT,
	mature_content TEXT,
	minimum_requirements TEXT,
	recommended_requirements TEXT,
	original_price TEXT,
	discount_price TEXT
);

\COPY SteamGame FROM steam_games.csv WITH csv;

CREATE TABLE SteamData(
	appid TEXT,
	name TEXT,
	release_date TEXT,
	english TEXT,
	developer TEXT,
	publisher TEXT,
	platforms TEXT,
	required_age TEXT,
	categories TEXT,
	genres TEXT,
	steamspy_tags TEXT,
	achievements TEXT,
	positive_ratings TEXT,
	negative_ratings TEXT,
	average_playtime TEXt,
	median_playtime TEXT,
	owners TEXT,
	price TEXT
);
	
\COPY SteamData FROM steam.csv WITH csv;

DELETE FROM SteamData
WHERE appid = 'appid';

/*
** Game
*/

insert into Game(game_title, genre, release_date, developer)
select T1.name, genre, release_date, developer
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

create table Mac(
	game_title TEXT,
	platform TEXT default 'Mac'
);

insert into Mac(game_title)
select name
from SteamGame
where minimum_requirements like '%Mac%';

create table Windows(
	game_title TEXT,
	platform TEXT default 'Windows'
);

insert into Windows(game_title)
select name
from SteamGame
where minimum_requirements like '%Windows%';

create table Linux(
	game_title TEXT,
	platform TEXT default 'Linux'
);

insert into Linux(game_title)
select name
from SteamGame
where minimum_requirements like '%Linux%';

insert into Platform(game_id, platform)
select game_id, platform
from ((select * from Mac) union all
	  (select * from Windows) union all
	  (select * from Linux)) T1 natural join
	 Game
order by game_id;

drop table Mac;
drop table Windows;
drop table Linux;

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
