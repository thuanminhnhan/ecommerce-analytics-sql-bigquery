-- Query 05: How are active users distributed across device categories (mobile/desktop/tablet)?** 

SELECT

  device.category AS device_category,

  COUNT(DISTINCT user_pseudo_id) AS active_users

FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`

GROUP BY device_category

ORDER BY active_users DESC;

