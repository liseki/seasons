CREATE OR REPLACE FUNCTION v2.materialize_season_definition(sd_id BIGINT) RETURNS VOID AS $$
BEGIN
  INSERT INTO v2.seasons
    (property_id, season_definition_id, n, starts_on, ends_on, created_at, updated_at)
    SELECT o.property_id,
           o.season_definition_id,
           o.n,
           o.starts_on,
           o.ends_on,
           o.created_at,
           o.updated_at
      FROM (
        SELECT property_id,
               a.id AS season_definition_id, 
               ROW_NUMBER () OVER () + a.current_n AS n,
               CASE WHEN (a.start_year + i) % 4 = 0 AND a.include_leap_day AND a.start_month = 3 AND a.start_day = 1
                 THEN MAKE_DATE(a.start_year + i, a.start_month - 1, 29)
                 ELSE MAKE_DATE(a.start_year + i, a.start_month, a.start_day)
               END AS starts_on,
               CASE WHEN (a.start_year + i) % 4 = 0 AND a.include_leap_day AND a.end_month = 2 AND a.end_day = 28
                 THEN MAKE_DATE(a.end_year + i, a.end_month, 29)
                 ELSE MAKE_DATE(a.end_year + i, a.end_month, a.end_day)
               END AS ends_on,
               a.repeat_until,
               a.updated_at AS created_at,
               a.updated_at
          FROM (
            SELECT sd.id,
                   st.property_id,
                   COUNT(s.*)::INTEGER AS current_n,
                   EXTRACT(YEAR FROM sd.starts_on)::INTEGER AS start_year,
                   EXTRACT(MONTH FROM sd.starts_on)::INTEGER AS start_month,
                   EXTRACT(DAY FROM sd.starts_on)::INTEGER AS start_day,
                   EXTRACT(YEAR FROM sd.ends_on)::INTEGER AS end_year,
                   EXTRACT(MONTH FROM sd.ends_on)::INTEGER AS end_month,
                   EXTRACT(DAY FROM sd.ends_on)::INTEGER AS end_day,
                   LEAST(st.active_until, sd.repeat_until) AS repeat_until,
                   sd.include_leap_day,
                   sd.updated_at
              FROM v2.season_definitions sd
              JOIN v2.season_types st
              ON sd.season_type_id = st.id
              LEFT JOIN v2.seasons s
              ON s.season_definition_id = sd.id AND s.updated_at = sd.updated_at
              WHERE sd.id = sd_id
              GROUP BY st.id, sd.id
          ) a,
          GENERATE_SERIES(a.current_n,
            EXTRACT(YEAR FROM current_date)::INTEGER + 5 - a.start_year) i
      ) o
      WHERE o.repeat_until IS NULL OR o.starts_on <= repeat_until
      ON CONFLICT (season_definition_id, n)
      DO UPDATE SET (property_id, season_definition_id, n, starts_on, ends_on, updated_at) =
        (EXCLUDED.property_id, EXCLUDED.season_definition_id, EXCLUDED.n, EXCLUDED.starts_on,
          EXCLUDED.ends_on, EXCLUDED.updated_at);

END;
$$ LANGUAGE plpgsql;
