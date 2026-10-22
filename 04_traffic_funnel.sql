-- Query 04: For each traffic source/medium, how many sessions start, product-view events, checkouts, purchases, and first-time purchasers are there?&#xA0;**

WITH purchasers AS (

  -- Lấy danh sách những user đã từng phát sinh sự kiện purchase

  SELECT DISTINCT user_pseudo_id 

  FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`

  WHERE event_name = 'purchase'

)



SELECT

  e.traffic_source.source AS session_source,

  e.traffic_source.medium AS session_medium,

  COUNT(DISTINCT CASE WHEN e.event_name = 'session_start' THEN e.user_pseudo_id END) AS sessions,

  COUNTIF(e.event_name = 'view_item') AS item_view_events,

  COUNTIF(e.event_name = 'begin_checkout') AS checkouts,

  COUNTIF(e.event_name = 'purchase') AS ecommerce_purchases,



  -- Sửa đoạn EXISTS thành kiểm tra user nằm trong danh sách purchasers ở trên

  COUNTIF(e.event_name = 'first_visit' AND e.user_pseudo_id IN (SELECT user_pseudo_id FROM purchasers)) AS first_time_purchasers



FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\` e

GROUP BY 1, 2

ORDER BY sessions DESC;
