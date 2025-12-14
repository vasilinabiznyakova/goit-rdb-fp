//Task 2
CREATE TABLE entities (
  entity_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  entity VARCHAR(255) NOT NULL,
  code VARCHAR(32) NULL,
  UNIQUE KEY uq_entity_code (entity, code)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT
  TRIM(Entity),
  NULLIF(TRIM(Code), '')
FROM infectious_cases;


CREATE TABLE infectious_cases_norm (
  entity_id INT UNSIGNED NOT NULL,
  year SMALLINT UNSIGNED NOT NULL,

  number_yaws INT UNSIGNED NULL,
  polio_cases INT UNSIGNED NULL,
  cases_guinea_worm INT UNSIGNED NULL,

  number_rabies DOUBLE NULL,
  number_malaria DOUBLE NULL,
  number_hiv DOUBLE NULL,
  number_tuberculosis DOUBLE NULL,

  number_smallpox INT UNSIGNED NULL,
  number_cholera_cases INT UNSIGNED NULL,

  PRIMARY KEY (entity_id, year),
  FOREIGN KEY (entity_id) REFERENCES entities(entity_id)
);


INSERT INTO infectious_cases_norm (
  entity_id, year,
  number_yaws, polio_cases, cases_guinea_worm,
  number_rabies, number_malaria, number_hiv, number_tuberculosis,
  number_smallpox, number_cholera_cases
)
SELECT
  e.entity_id,
  CAST(NULLIF(TRIM(s.Year), '') AS UNSIGNED),

  CAST(NULLIF(TRIM(s.Number_yaws), '') AS UNSIGNED),
  CAST(NULLIF(TRIM(s.polio_cases), '') AS UNSIGNED),
  CAST(NULLIF(TRIM(s.cases_guinea_worm), '') AS UNSIGNED),

  CAST(NULLIF(TRIM(s.Number_rabies), '') AS DOUBLE),
  CAST(NULLIF(TRIM(s.Number_malaria), '') AS DOUBLE),
  CAST(NULLIF(TRIM(s.Number_hiv), '') AS DOUBLE),
  CAST(NULLIF(TRIM(s.Number_tuberculosis), '') AS DOUBLE),

  CAST(NULLIF(TRIM(s.Number_smallpox), '') AS UNSIGNED),
  CAST(NULLIF(TRIM(s.Number_cholera_cases), '') AS UNSIGNED)
FROM infectious_cases s
JOIN entities e
  ON e.entity = TRIM(s.Entity)
 AND (e.code <=> NULLIF(TRIM(s.Code), ''));



//Task 3
SELECT
  e.entity,
  e.code,
  AVG(c.number_rabies) AS avg_number_rabies,
  MIN(c.number_rabies) AS min_number_rabies,
  MAX(c.number_rabies) AS max_number_rabies,
  SUM(c.number_rabies) AS sum_number_rabies
FROM infectious_cases_norm c
JOIN entities e
  ON e.entity_id = c.entity_id
WHERE c.number_rabies IS NOT NULL
GROUP BY e.entity, e.code
ORDER BY avg_number_rabies DESC
LIMIT 10;



//Task 4

SELECT
  year,
  STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d') AS year_start_date,
  CURDATE() AS today,
  TIMESTAMPDIFF(
    YEAR,
    STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d'),
    CURDATE()
  ) AS diff_in_years
FROM infectious_cases_norm
LIMIT 20

//Task 5

DELIMITER $$

CREATE FUNCTION year_diff_from_now(y INT)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(
    YEAR,
    STR_TO_DATE(CONCAT(y, '-01-01'), '%Y-%m-%d'),
    CURDATE()
  );
END$$

DELIMITER ;

SELECT
  year,
  year_diff_from_now(year) AS diff_in_years
FROM infectious_cases_norm
LIMIT 20;
