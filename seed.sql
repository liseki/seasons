INSERT INTO v2.season_types
  (property_id, title, active_until, closed)
  VALUES
  (1, 'Shoulder Season', NULL, NULL),
  (1, 'Low Season',      NULL, NULL),
  (1, 'High Season',     NULL, NULL),
  (1, 'Festive Season',  NULL, NULL),
  (1, 'Closed Season',   NULL, TRUE);


INSERT INTO v2.season_definitions
  (season_type_id, starts_on, ends_on, include_leap_day, repeat_until)
  VALUES
  (2, '2020-01-04', '2020-02-28', TRUE, NULL),
  (1, '2020-03-01', '2020-04-30', NULL, NULL),
  (5, '2020-05-01', '2020-05-31', NULL, NULL),
  (3, '2020-06-01', '2020-08-30', NULL, NULL),
  (2, '2020-08-31', '2020-10-15', NULL, NULL),
  (1, '2020-10-16', '2020-12-03', NULL, NULL),
  (4, '2020-12-04', '2021-01-03', NULL, NULL);

