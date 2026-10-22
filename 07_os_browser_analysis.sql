-- Query 07: How are active users distributed across operating systems and browsers?

SELECT

  device.operating_system AS OS,

  device.web_info.browser AS browser,

  COUNT(DISTINCT user_pseudo_id) AS active_users

FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`

GROUP BY OS, browser

ORDER BY active_users DESC;
