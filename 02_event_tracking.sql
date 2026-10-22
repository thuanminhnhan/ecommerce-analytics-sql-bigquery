-- Query 02: What types of user actions (event_name) is the website tracking? List them all.** 

WITH raw_events AS (

  SELECT

    -- Chuyển event_date (STRING YYYYMMDD) sang định dạng DATE YYYY-MM-DD

    PARSE_DATE('%Y%m%d', event_date) AS event_date,

    -- Tạo session_key duy nhất bằng cách ghép user_pseudo_id và ga_session_id

    CONCAT(user_pseudo_id, '-', (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')) AS session_key,

    event_name,

    -- Lấy doanh thu mua hàng từ bảng ecommerce

    ecommerce.purchase_revenue,

    -- Lấy danh sách items để tính basket size

    items

  FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`

  -- Giới hạn khoảng thời gian theo mẫu bài tập (tháng 11/2020)

  WHERE \_TABLE_SUFFIX BETWEEN '20201101' AND '20201118'

),



session_metrics AS (

  SELECT

    event_date,

    COUNT(DISTINCT session_key) AS sessions,

    COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN session_key END) AS view_item_sessions,

    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_key END) AS cart_sessions,

    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_key END) AS purchase_sessions,

    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_key END) AS ecommerce_purchases,

    SUM(CASE WHEN event_name = 'purchase' THEN purchase_revenue END) AS purchase_revenue,

    SUM((SELECT SUM(quantity) FROM UNNEST(items))) AS basket_qty

  FROM raw_events

  GROUP BY event_date

)



SELECT

  CAST(event_date AS STRING) AS event_date,

  sessions,

  ROUND(SAFE_DIVIDE(view_item_sessions, sessions), 4) AS view_product_rate,

  ROUND(SAFE_DIVIDE(cart_sessions, view_item_sessions), 4) AS view_to_cart_rate,

  ROUND(SAFE_DIVIDE(purchase_sessions, cart_sessions), 4) AS cart_to_purchase_rate,

  ROUND(SAFE_DIVIDE(purchase_sessions, sessions), 4) AS purchase_rate,

  ecommerce_purchases,

  ROUND(IFNULL(purchase_revenue, 0), 2) AS purchase_revenue,

  ROUND(SAFE_DIVIDE(purchase_revenue, ecommerce_purchases), 2) AS avg_purchase_revenue,

  ROUND(SAFE_DIVIDE(basket_qty, ecommerce_purchases), 2) AS avg_basket_size,

  ROUND(SAFE_DIVIDE(purchase_revenue, sessions), 2) AS revenue_per_user

FROM session_metrics

ORDER BY event_date ASC;
