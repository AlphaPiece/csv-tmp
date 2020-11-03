drop schema if exists steamschema cascade; 
create schema steamschema;
SET search_path TO steamschema;

CREATE TABLE  Game(
	game_id INTEGER PRIMARY KEY,
	game_title TEXT NOT NULL,
	genre TEXT,
	release_date DATE NOT NULL,
	developer TEXT NOT NULL
);

CREATE TABLE Develop(
	developer TEXT,
	game_id INTEGER  REFERENCES Game(game_id),
	PRIMARY KEY(developer, game_id)
);

CREATE TABLE Requirement(
	game_id INTEGER PRIMARY KEY REFERENCES Game(game_id),
	minimum_requirement TEXT,
	recommended_requirement TEXT
);
	
CREATE TABLE Rating(
	game_id INTEGER PRIMARY KEY REFERENCES Game(game_id),
	positive_review INTEGER NOT NULL,
	negative_review INTEGER NOT NULL
);

CREATE TABLE Playtime(
	game_id INTEGER PRIMARY KEY REFERENCES Game(game_id),
	average_playtime FLOAT,
	median_playtime FLOAT 
);

CREATE TABLE Language(
	game_id INTEGER REFERENCES Game(game_id),
	language TEXT NOT NULL,
	PRIMARY KEY(game_id, language)
);

CREATE TABLE Price(
	game_id INTEGER PRIMARY KEY REFERENCES Game(game_id),
	price FLOAT NOT NULL,
	discount_price FLOAT
);

