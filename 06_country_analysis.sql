-- Query 06: Which countries have the highest number of active users?

SELECT

  geo.country as country,

  COUNT(DISTINCT user_pseudo_id) AS active_users

FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`

GROUP BY country

ORDER BY active_users DESC;
