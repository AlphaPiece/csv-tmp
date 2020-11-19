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
