CREATE OR REPLACE FUNCTION v2.season_definition_timestamp() RETURNS TRIGGER AS $$
DECLARE
  _timestamp TIMESTAMP := now();
BEGIN
  IF NEW.created_at IS NULL THEN
    NEW.created_at = _timestamp;
  END IF;

  NEW.updated_at = _timestamp;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER season_definition_timestamp BEFORE INSERT OR UPDATE ON v2.season_definitions
  FOR EACH ROW EXECUTE FUNCTION v2.season_definition_timestamp();



CREATE OR REPLACE FUNCTION v2.seasons_on_season_type_change() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.active_until IS DISTINCT FROM OLD.active_until THEN
    UPDATE v2.season_definitions SET updated_at = localtimestamp(6)
      WHERE season_type_id = OLD.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER seasons_on_season_type_change AFTER UPDATE
  ON v2.season_types
  FOR EACH ROW EXECUTE FUNCTION v2.seasons_on_season_type_change();



CREATE OR REPLACE FUNCTION v2.seasons_on_season_definition_change() RETURNS TRIGGER AS $$
BEGIN
  PERFORM v2.materialize_season_definition(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER seasons_on_season_definition_change AFTER INSERT OR UPDATE
  ON v2.season_definitions
  FOR EACH ROW EXECUTE FUNCTION v2.seasons_on_season_definition_change();
