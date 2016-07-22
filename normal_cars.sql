DROP USER IF EXISTS normal_user;
CREATE USER normal_user;
DROP DATABASE normal_cars;
CREATE DATABASE normal_cars WITH OWNER normal_user;
\c normal_cars;
\i scripts/denormal_data.sql;

CREATE TABLE IF NOT EXISTS make (
  id SERIAL PRIMARY KEY,
  make_code character varying(125) NOT NULL,
  make_title character varying(125) NOT NULL
);

INSERT INTO make (make_code, make_title)
  SELECT DISTINCT make_code, make_title FROM car_models;

CREATE TABLE IF NOT EXISTS model (
  id SERIAL PRIMARY KEY,
  model_code character varying(125) NOT NULL,
  model_title character varying(125) NOT NULL,
  make_id integer REFERENCES make(id)
);

INSERT INTO model (model_code, model_title, make_id)
  SELECT DISTINCT model_code, model_title, id
  FROM car_models INNER JOIN make ON car_models.make_title = make.make_title;

CREATE TABLE IF NOT EXISTS year (
  id SERIAL PRIMARY KEY,
  year integer NOT NULL
);

INSERT INTO year (year)
  SELECT DISTINCT year
  FROM car_models;

CREATE TABLE IF NOT EXISTS joined_table (
  id SERIAL PRIMARY KEY,
  model_id integer REFERENCES model(id),
  year_id integer REFERENCES year(id)
);

INSERT INTO joined_table (model_id, year_id)
  SELECT model.id, year.id
  FROM model INNER JOIN year ON 1 = 1;

SELECT DISTINCT model_title
  FROM joined_table
  INNER JOIN model ON joined_table.model_id = model.id
  INNER JOIN make ON model.make_id = make.id
  WHERE make_code = 'VOLKS';

SELECT make_code, model_code, model_title, year
  FROM joined_table
  INNER JOIN model ON joined_table.model_id = model.make_id
  INNER JOIN make ON model.make_id = make.id
  INNER JOIN year ON joined_table.year_id = year.id
  WHERE make_code = 'LAM';

SELECT *
  FROM joined_table
  INNER JOIN model ON joined_table.model_id = model.id
  INNER JOIN make ON model.make_id = make.id
  INNER JOIN year on joined_table.year_id = year.id
  WHERE year BETWEEN 2010 AND 2015;