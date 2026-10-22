-- Query 03: Which traffic sources and mediums generate the most sessions, and what percentage of total sessions does each one represent?** 

WITH source_sessions AS (

  SELECT

    -- 1. Lấy cột source và medium từ cấu trúc traffic_source

    traffic_source.source AS session_source,

    traffic_source.medium AS session_medium,



    -- 2. Đếm số lượng session duy nhất dựa vào session_key

    COUNT(DISTINCT CONCAT(user_pseudo_id, '-', (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id'))) AS sessions

tôi ko hiểu câu lệnh này tại sao là concat và unnest các thứ



  FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`



  -- 3. Điền điều kiện lọc sự kiện khởi tạo session vào đây

  WHERE event_name = 'session_start'



  -- 4. Gom nhóm theo source và medium

  GROUP BY session_source, session_medium

)



SELECT

  session_source,

  session_medium,

  sessions,



  -- 5. Tính phần trăm số session của nguồn đó so với tổng số sessions toàn cục.

  -- Gợi ý: Lấy sessions chia cho Tổng toàn cục (dùng SUM(sessions) OVER() hoặc tính tổng ở mẫu số).

ROUND(

  SAFE_DIVIDE(sessions, SUM(sessions) OVER()) \* 100, 2

) AS pct_sessions

tại sao lại safe divide các thứ



FROM source_sessions

ORDER BY sessions DESC;
