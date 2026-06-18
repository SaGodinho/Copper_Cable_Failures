CREATE VIEW copper_view AS
SELECT
    machine,
    shift,
    operator,
    production_date,
    cable_failures,
    cable_failure_downtime,
    other_failures,
    other_failure_downtime,
    (cable_failures + other_failures) AS total_failures,
    (cable_failure_downtime + other_failure_downtime) AS total_downtime
FROM copper_production;

# How many data rows do we have?
SELECT COUNT(*) AS total_records
FROM copper_view;

# Totals (Failures, Downtime, Average, Machines, Operators)
SELECT 
    SUM(total_failures) AS total_failures,
    SUM(total_downtime) AS total_downtime,
    ROUND(SUM(total_downtime) / NULLIF(SUM(total_failures), 0),
            2) AS avg_downtime_per_failure,
    COUNT(DISTINCT machine) AS machine_count,
    COUNT(DISTINCT operator) AS operator_count
FROM
    copper_view;

# Cable vs Other Failures
SELECT
    'Cable Failures' AS failure_type,
    SUM(cable_failures) AS failures,
    SUM(cable_failure_downtime) AS downtime
FROM copper_view
UNION ALL
SELECT
    'Other Failures' AS failure_type,
    SUM(other_failures) AS failures,
    SUM(other_failure_downtime) AS downtime
FROM copper_view
UNION ALL
SELECT
    'TOTAL' AS failure_type,
    SUM(cable_failures + other_failures) AS failures,
    SUM(cable_failure_downtime + other_failure_downtime) AS downtime
FROM copper_view;

# What percentage is Cable Downtime?
SELECT
    SUM(cable_failure_downtime) AS cable_downtime,
    SUM(other_failure_downtime) AS other_downtime,
    ROUND(
        100 * SUM(cable_failure_downtime) /
        NULLIF(SUM(cable_failure_downtime + other_failure_downtime), 0),
        2
    ) AS cable_percentage_downtime
FROM copper_view;

# Failure Stats by Machine
SELECT
    machine,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime,
    ROUND(
        SUM(total_downtime) / NULLIF(SUM(total_failures), 0),
        2
    ) AS avg_downtime_per_failure
FROM copper_view
GROUP BY machine
ORDER BY downtime DESC;

# Machine Performance - Pareto Contribution
WITH machine_totals AS (
    SELECT
        machine,
        SUM(total_downtime) AS downtime
    FROM copper_view
    GROUP BY machine),
ranked AS (
    SELECT
        machine,
        downtime,
        SUM(downtime) OVER () AS total_downtime,
        ROUND(100 * downtime / SUM(downtime) OVER (), 2) AS percentage_contribution,
        SUM(downtime) OVER (ORDER BY downtime DESC) AS cumulative_downtime
    FROM machine_totals)
SELECT
    machine,
    downtime,
    percentage_contribution,
    ROUND(100 * cumulative_downtime / total_downtime, 2) AS cumulative_percentage
FROM ranked
ORDER BY downtime DESC;

# Failure Stats by Shift - Roughly the same
SELECT
    shift,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime,
    ROUND(
        SUM(total_downtime) / NULLIF(SUM(total_failures), 0),
        2
    ) AS avg_downtime_per_failure
FROM copper_view
GROUP BY shift
ORDER BY downtime DESC;

# Failure Stats by Operator
SELECT
    operator,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime,
    ROUND(
        SUM(total_downtime) / NULLIF(SUM(total_failures), 0),
        2
    ) AS avg_downtime_per_failure
FROM copper_view
GROUP BY operator
ORDER BY downtime DESC;

# Operator Performance - Pareto Contribution
WITH operator_totals AS (
    SELECT
        operator,
        SUM(total_downtime) AS downtime
    FROM copper_view
    GROUP BY operator),
ranked AS (
    SELECT
        operator,
        downtime,
        SUM(downtime) OVER () AS total_downtime,
        ROUND(100 * downtime / SUM(downtime) OVER (), 2) AS pct_contribution,
        SUM(downtime) OVER (ORDER BY downtime DESC) AS cumulative_downtime
    FROM operator_totals)
SELECT
    operator,
    downtime,
    pct_contribution,
    ROUND(100 * cumulative_downtime / total_downtime, 2) AS cumulative_pct
FROM ranked
ORDER BY downtime DESC;

# Daily Failure Stats
SELECT
    production_date,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime
FROM copper_view
GROUP BY production_date
ORDER BY production_date;

# Failure and Downtime Variation from Day-to-Day (%)
SELECT
    production_date,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime,
    ROUND(
        100 * (
            SUM(total_failures)
            - LAG(SUM(total_failures)) OVER (ORDER BY production_date)
        )
        / NULLIF(LAG(SUM(total_failures)) OVER (ORDER BY production_date), 0),
        2
    ) AS failure_percentage_change,
    ROUND(
        100 * (
            SUM(total_downtime)
            - LAG(SUM(total_downtime)) OVER (ORDER BY production_date)
        )
        / NULLIF(LAG(SUM(total_downtime)) OVER (ORDER BY production_date), 0),
        2
    ) AS downtime_percentage_change
FROM copper_view
GROUP BY production_date
ORDER BY production_date;

# Downtime Moving Average
SELECT
    production_date,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime,
    AVG(SUM(total_downtime)) OVER (
        ORDER BY production_date
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS downtime_5day_avg
FROM copper_view
GROUP BY production_date
ORDER BY production_date;

# Evolution Slope: 0.0007735203337932418
# slightly positive value indicates a drift in the process and possible systemic degradation
# resulting in increased downtime by day
SELECT
    (AVG(xy) - AVG(x) * AVG(y)) / (AVG(x2) - AVG(x) * AVG(x)) AS slope
FROM (
    SELECT
        UNIX_TIMESTAMP(production_date) AS x,
        SUM(total_downtime) AS y,
        UNIX_TIMESTAMP(production_date) * SUM(total_downtime) AS xy,
        POWER(UNIX_TIMESTAMP(production_date), 2) AS x2
    FROM copper_view
    GROUP BY production_date
) t;

# Machine x Shift top failures
SELECT
    machine,
    shift,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime,
    ROUND(SUM(total_downtime) / NULLIF(SUM(total_failures), 0), 2) AS downtime_per_failure
FROM copper_view
GROUP BY machine, shift
ORDER BY downtime DESC
LIMIT 20;

# Machine x Operator
SELECT
    machine,
    operator,
    SUM(total_failures) AS failures,
    SUM(total_downtime) AS downtime,
    ROUND(SUM(total_downtime) / NULLIF(SUM(total_failures), 0), 2) AS downtime_per_failure
FROM copper_view
GROUP BY machine, operator
ORDER BY downtime DESC
LIMIT 20;

# Downtime that stands out (2x > avg)
SELECT *
FROM copper_view
WHERE total_downtime > (
    SELECT AVG(total_downtime) * 2
    FROM copper_view
)
ORDER BY total_downtime DESC;


