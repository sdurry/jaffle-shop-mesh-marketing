{{
    config(
        materialized='table'
    )
}}

WITH customers AS (
  SELECT
    *
  FROM {{ ref('customers') }}
), orders AS (
  SELECT
    CUSTOMER_ID,
    ORDER_TOTAL
  FROM {{ ref('jaffle_shop_mesh_finance', 'orders') }}
), aggregate_1 AS (
  SELECT
    CUSTOMER_ID,
    SUM(ORDER_TOTAL) AS LIFETIME_VALUE
  FROM orders
  GROUP BY
    CUSTOMER_ID
), join_1 AS (
  SELECT
    customers.CUSTOMER_ID,
    aggregate_1.LIFETIME_VALUE
  FROM customers
  LEFT JOIN aggregate_1
    ON customers.CUSTOMER_ID = aggregate_1.CUSTOMER_ID
), formula_1 AS (
  SELECT
    CUSTOMER_ID,
    LIFETIME_VALUE,
    CASE
      WHEN LIFETIME_VALUE > 2500
      THEN 'gold'
      WHEN LIFETIME_VALUE BETWEEN 1000 AND 2499
      THEN 'silver'
      ELSE 'bronze'
    END AS LOYALTY_TIER,
    CURRENT_TIMESTAMP AS loaded_at
  FROM join_1
), loyalty_sql AS (
  SELECT
    *
  FROM formula_1
)
SELECT
  *
FROM loyalty_sql