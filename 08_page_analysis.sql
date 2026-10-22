-- Query 08: Which pages receive the most views, and how many active users visit each one?

SELECT

  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_path,

  COUNT(1) AS views,

  COUNT(DISTINCT user_pseudo_id) AS active_users

FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`

WHERE event_name = 'page_view'

GROUP BY page_path

ORDER BY views DESC;
