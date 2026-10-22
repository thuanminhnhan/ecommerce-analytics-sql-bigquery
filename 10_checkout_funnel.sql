-- Query 10: For each device category, how many sessions complete each step of the checkout path — begin checkout, add shipping info, add payment info, purchase?

WITH preprocessed_data AS (

  SELECT

    device.category AS device_category,

    event_name,

    -- Ghép ID để tạo Session Key chuẩn

    CONCAT(user_pseudo_id, '-', (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS session_key

  FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`

)

SELECT

  device_category,

  COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN session_key END) AS begin_checkout,

  COUNT(DISTINCT CASE WHEN event_name = 'add_shipping_info' THEN session_key END) AS add_shipping_info,

  COUNT(DISTINCT CASE WHEN event_name = 'add_payment_info' THEN session_key END) AS add_payment_info,

  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_key END) AS purchase



FROM preprocessed_data

WHERE device_category IS NOT NULL

GROUP BY device_category

ORDER BY begin_checkout DESC;
