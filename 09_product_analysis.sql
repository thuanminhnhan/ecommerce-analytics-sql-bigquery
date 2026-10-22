-- Query 09: For each product, how many views, add-to-cart actions, checkouts, units purchased, and how much revenue did it generate.

SELECT

  item.item_name AS item_name,

  -- 1. Đếm số lượt xem sản phẩm

  COUNT(CASE WHEN event_name = 'view_item' THEN 1 END) AS views,

  -- 2. Đếm số lượt thêm vào giỏ

  COUNT(CASE WHEN event_name = 'add_to_cart' THEN 1 END) AS added_to_cart,

  -- 3. Đếm số lượt bắt đầu thanh toán

  COUNT(CASE WHEN event_name = 'begin_checkout' THEN 1 END) AS checked_out,

  -- 4. Tính tổng số lượng sản phẩm đã bán thành công

  SUM(CASE WHEN event_name = 'purchase' THEN item.quantity ELSE 0 END) AS items_purchased,

  -- 5. Tính tổng doanh thu của sản phẩm đó (Giá x Số lượng)

  SUM(CASE WHEN event_name = 'purchase' THEN COALESCE(item.item_revenue, item.price \* item.quantity) ELSE 0 END) AS item_revenue



FROM \`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events\_\*\`,

UNNEST(items) AS item



WHERE item.item_name IS NOT NULL 

  AND item.item_name != '(not set)'



GROUP BY item_name

ORDER BY views DESC;
