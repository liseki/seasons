DROP SCHEMA IF EXISTS v2 CASCADE;
CREATE SCHEMA v2;


CREATE TABLE v2.season_types (
  id SERIAL PRIMARY KEY,
  property_id BIGINT NOT NULL,
  title VARCHAR NOT NULL,
  code CHAR,
  active_from DATE,
  active_until DATE,
  closed BOOLEAN DEFAULT FALSE
);
CREATE INDEX season_types_on_property_id ON v2.season_types
  USING btree(property_id);


CREATE TABLE v2.season_definitions (
  id SERIAL PRIMARY KEY,
  season_type_id BIGINT NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL,
  include_leap_day BOOLEAN DEFAULT FALSE,
  repeat BOOLEAN DEFAULT TRUE,
  repeat_until DATE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
CREATE INDEX season_definitions_on_season_type_id ON v2.season_definitions
  USING btree(season_type_id);


CREATE TABLE v2.seasons (
  id SERIAL PRIMARY KEY,
  property_id BIGINT NOT NULL,
  season_definition_id BIGINT NOT NULL,
  n INTEGER NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
CREATE UNIQUE INDEX seasons_on_season_definition_id ON v2.seasons
  USING btree(season_definition_id, n);
CREATE INDEX seasons_on_property_id ON v2.seasons
  USING btree(property_id);
