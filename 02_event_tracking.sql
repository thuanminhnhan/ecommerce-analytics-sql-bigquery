WITH aggregated_events AS (
  SELECT
    -- Chuyển định dạng ngày tháng
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_name,
    -- Đếm số lượng sự kiện
    COUNT(1) AS event_count,
    -- Đếm số lượng người dùng độc lập
    COUNT(DISTINCT user_pseudo_id) AS active_users
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201102'
  -- Gom nhóm theo ngày và tên sự kiện
  GROUP BY event_date, event_name
)
SELECT
  CAST(event_date AS STRING) AS event_date,
  event_name,
  event_count,
  -- Tính tỷ lệ phần trăm sự kiện trong ngày bằng Window Function an toàn
  ROUND(
    SAFE_DIVIDE(
      event_count, 
      SUM(event_count) OVER(PARTITION BY event_date)
    ), 4
  ) AS event_percent,
  active_users
FROM aggregated_events
ORDER BY event_date ASC, event_count DESC;
