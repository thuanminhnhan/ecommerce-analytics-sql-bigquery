# E-commerce Analytics with SQL and Google BigQuery

A portfolio project analyzing Google Analytics 4 (GA4) e-commerce event data with SQL to explore website traffic, user behavior, product performance, and checkout activity.

**Tools:** SQL · Google BigQuery · GA4 Public Sample Dataset

**Project type:** Exploratory data analysis (EDA) using SQL  
**Dataset:** Google Analytics 4 obfuscated sample e-commerce events  
**Analysis focus:** Traffic sources, engagement, products, and purchase-related events

## 1. Project Overview

This project uses SQL in Google BigQuery to analyze e-commerce event data and answer practical business questions about website activity and shopping behavior.

The analysis is organized into 10 SQL queries, covering daily metrics, event tracking, traffic sources, traffic-source activity, devices, geography, browsers and operating systems, page performance, product performance, and checkout events.

The goal is to demonstrate how raw analytics data can be transformed into structured outputs that help identify patterns, investigate potential tracking issues, and support business decisions.

## 2. Business Questions

This project explores the following questions:

1. How do daily sessions, purchases, and recorded purchase revenue vary over time?
2. Which events occur most frequently, and how does activity differ across the customer journey?
3. Which traffic sources account for the largest reported session counts?
4. How do traffic sources compare in item-view, checkout, and purchase activity?
5. How does website activity differ by device category?
6. Which countries contribute the most active users in the returned results?
7. Which browser and operating-system combinations have the most active users?
8. Which pages receive the most views and users?
9. Which products have the highest recorded item revenue and purchase activity?
10. How do checkout-related event counts differ by device, and what should be validated before interpreting them as a funnel?

## 3. Dataset

The project uses the public GA4 sample e-commerce dataset hosted in Google BigQuery:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

The dataset contains event-level records from a sample Google Merchandise Store property. Each record represents an analytics event, with additional information stored in nested and repeated fields.

### Key fields used

| Field | Purpose |
|---|---|
| `event_date` | Date associated with the event |
| `event_name` | Type of event, such as `page_view`, `view_item`, or `purchase` |
| `user_pseudo_id` | Pseudonymous identifier for a user |
| `event_params` | Event-level parameters, including `ga_session_id` |
| `items` | Product-level information included in relevant events |
| `ecommerce.purchase_revenue` | Purchase revenue value recorded in the exported data |
| `traffic_source` | Acquisition-source information available in the GA4 export |
| `device` | Device category, browser, operating system, and related attributes |
| `geo` | Geographic attributes such as country |
| `event_timestamp` | Timestamp associated with an event |

### Important data considerations

- The dataset is an obfuscated sample, not a complete representation of a live business.
- GA4 exports contain nested and repeated fields, so analysis requires extracting event parameters and working with arrays such as `items`.
- The meaning of a metric depends on its calculation and denominator. Event counts, distinct users, distinct sessions, and purchases are not interchangeable.
- The `traffic_source` record in the GA4 export generally describes first-user acquisition information. It should not automatically be interpreted as the source of each individual session.
- Revenue and item-revenue fields should be interpreted according to the query and source-field definitions. This project does not assume an unverified currency or treat every revenue field as interchangeable.

## 4. SQL Analysis

All 10 SQL files are available in the repository root.

| # | Analysis | SQL file | Purpose |
|---|---|---|---|
| 01 | Daily Overview | [`01_daily_overview.sql`](01_daily_overview.sql) | Summarizes daily sessions, product-view activity, cart activity, purchases, recorded revenue, and basket-related metrics. |
| 02 | Event Tracking | [`02_event_tracking.sql`](02_event_tracking.sql) | Compares event counts and active users across GA4 event types. |
| 03 | Traffic Sources | [`03_traffic_sources.sql`](03_traffic_sources.sql) | Examines reported traffic-source and medium groupings and their session counts. |
| 04 | Traffic Source Activity | [`04_traffic_funnel.sql`](04_traffic_funnel.sql) | Compares item-view, checkout, purchase, and first-time purchaser counts across source groupings. |
| 05 | Device Analysis | [`05_device_analysis.sql`](05_device_analysis.sql) | Compares active users across desktop, mobile, and tablet. |
| 06 | Country Analysis | [`06_country_analysis.sql`](06_country_analysis.sql) | Examines active users by country. |
| 07 | OS and Browser Analysis | [`07_os_browser_analysis.sql`](07_os_browser_analysis.sql) | Compares active users across operating-system and browser combinations. |
| 08 | Page Analysis | [`08_page_analysis.sql`](08_page_analysis.sql) | Identifies pages with high view and user counts. |
| 09 | Product Analysis | [`09_product_analysis.sql`](09_product_analysis.sql) | Examines product views, cart activity, checkout activity, items purchased, and recorded item revenue. |
| 10 | Checkout Event Analysis | [`10_checkout_funnel.sql`](10_checkout_funnel.sql) | Compares sessions containing checkout-related events by device category. |

## 5. Key Findings

The findings below summarize the outputs returned by the current SQL queries. They are descriptive observations, not proof of causation. Query-specific date ranges and metric definitions may differ.

### 5.1 Daily activity and purchase metrics

Query 01 calculates daily sessions, product-view rates, view-to-cart rates, cart-to-purchase rates, purchase rates, purchase counts, recorded purchase revenue, average recorded revenue per purchase, and average basket quantity.

The latest supplied output includes these examples:

| Date | Sessions | Purchases | Recorded purchase revenue | Average recorded revenue per purchase |
|---|---:|---:|---:|---:|
| 2020-11-01 | 2,625 | 14 | 773.00 | 55.21 |
| 2020-11-06 | 3,332 | 58 | 3,438.00 | 59.28 |
| 2020-11-10 | 3,835 | 64 | 4,041.00 | 63.14 |
| 2020-11-13 | 3,347 | 79 | 5,831.00 | 73.81 |
| 2020-11-15 | 2,214 | 21 | 1,483.00 | 70.62 |

These rows show variation in session volume, purchase counts, and recorded revenue across the selected dates. For example, November 13 has more purchases and higher recorded revenue than November 1 in the supplied output.

**Metric validation note:** The current output contains suspicious cart-related rates. On November 1, `cart_to_purchase_rate` is 13.0, while several following dates return `NULL` because the reported cart-session denominator is zero. The output also reports a zero `view_to_cart_rate` for November 2–15. These values are not treated as validated conversion rates. The underlying cart-event/session logic should be checked before using these metrics for business decisions.

The average recorded revenue per purchase in the table is calculated as recorded purchase revenue divided by the purchase count shown in the query output. Revenue and basket metrics should still be checked against the intended source fields and aggregation logic.

### 5.2 Event tracking

For November 1, 2020, the event-tracking query returned the following results:

| Event | Event count | Active users |
|---|---:|---:|
| `page_view` | 9,767 | 2,302 |
| `user_engagement` | 8,667 | 1,844 |
| `view_item` | 3,380 | 516 |
| `scroll` | 3,040 | 1,168 |
| `session_start` | 2,594 | 2,339 |
| `first_visit` | 1,946 | 1,946 |
| `view_promotion` | 1,263 | 779 |
| `begin_checkout` | 127 | 91 |
| `add_shipping_info` | 127 | 91 |
| `add_payment_info` | 73 | 26 |
| `purchase` | 14 | 13 |
| `add_to_cart` | 4 | 1 |

`page_view` and `user_engagement` were among the most frequent events in this output. The query also returned only four `add_to_cart` events, compared with 127 `begin_checkout` events.

This difference is a reason to investigate event implementation, event definitions, and query logic. It does not, by itself, establish why the counts differ or prove that users bypassed the cart.

### 5.3 Traffic sources

The traffic-source query returned these leading rows:

| Source / medium | Reported sessions | Share reported by query |
|---|---:|---:|
| `google / organic` | 111,488 | 31.42% |
| `(direct) / (none)` | 82,362 | 23.21% |
| `Other / Other` | 51,775 | 14.59% |
| `Other / referral` | 34,110 | 9.61% |
| `shop.googlemerchandisestore.com / referral` | 28,044 | 7.90% |
| `(data deleted) / (data deleted)` | 21,087 | 5.94% |
| `google / cpc` | 15,534 | 4.38% |

Google organic and direct were the two largest reported source/medium groupings in this output.

The seven rows above account for approximately 97.05% of the reported total share. They are selected leading rows, not the entire output table.

**Attribution limitation:** The source and medium fields must be interpreted according to the exact fields used in the query. In the GA4 BigQuery export, `traffic_source` generally describes first-user acquisition rather than session-scoped attribution. The results should therefore not be presented as definitive session acquisition-channel performance without validating the query's attribution logic.

### 5.4 Traffic-source activity

The traffic-source activity query returned these purchase counts for selected source/medium groupings:

| Source / medium | Reported sessions | Item-view events | Checkout count | Purchase count |
|---|---:|---:|---:|---:|
| `google / organic` | 102,530 | 116,917 | 10,642 | 1,454 |
| `(direct) / (none)` | 75,025 | 87,916 | 8,597 | 1,251 |
| `Other / Other` | 50,776 | 50,969 | 4,452 | 606 |
| `Other / referral` | 32,362 | 36,776 | 3,733 | 557 |
| `shop.googlemerchandisestore.com / referral` | 25,350 | 35,418 | 4,437 | 701 |
| `(data deleted) / (data deleted)` | 16,969 | 32,716 | 4,884 | 830 |
| `google / cpc` | 15,449 | 14,831 | 1,162 | 166 |

Google organic has the largest reported purchase count among the source groupings shown. This is a count-based observation, not evidence that it has the highest conversion rate or marketing effectiveness.

The number of item-view events can exceed the session count because one session can contain multiple events. Source attribution, event definitions, and denominators should be validated before making channel comparisons based on conversion rates.

### 5.5 Device analysis

The device query returned these active-user counts:

| Device category | Active users |
|---|---:|
| Desktop | 158,917 |
| Mobile | 109,195 |
| Tablet | 6,250 |

Desktop had the largest active-user count in the returned results, followed by mobile and tablet.

These figures describe the output of the device query. They do not establish that desktop users convert better, generate more revenue, or have stronger engagement without corresponding validated metrics.

### 5.6 Country analysis

The leading country rows supplied by the query were:

| Country | Active users |
|---|---:|
| United States | 118,493 |
| India | 25,367 |
| Canada | 20,268 |
| United Kingdom | 8,527 |
| France | 5,381 |

The United States had the largest active-user count among the countries shown.

These are the first five supplied rows, not necessarily a complete list of countries in the dataset.

### 5.7 Operating system and browser

The OS/browser query returned the following leading combinations:

| Platform / browser combination | Active users |
|---|---:|
| Web / Chrome | 113,813 |
| Web / Safari | 32,758 |
| iOS / Safari | 28,724 |
| Windows / Chrome | 27,887 |
| Android / Chrome | 21,056 |
| Macintosh / Chrome | 15,114 |

Web/Chrome had the highest active-user count among the combinations shown.

This analysis helps describe the technology mix represented in the data. It does not independently measure browser compatibility, user satisfaction, or conversion performance.

### 5.8 Page analysis

The page-analysis query returned these high-view pages:

| Page | Views | Users |
|---|---:|---:|
| `https://shop.googlemerchandisestore.com/` | 183,074 | 93,511 |
| `/Google+Redesign/Apparel` | 81,681 | 50,193 |
| `/basket.html` | 78,876 | 22,720 |
| `/store.html` | 73,568 | 32,324 |
| `https://googlemerchandisestore.com/` | 61,893 | 34,686 |
| `/Google+Redesign/Apparel/Mens` | 46,387 | 21,580 |

The first homepage URL had the highest view count among the listed pages. The basket page also appeared among the high-view pages.

Page-view volume alone does not indicate whether a page performs well. A more complete assessment would consider page purpose, event definitions, navigation paths, and downstream outcomes. The two homepage URLs may also represent different hostnames or URL variations and should be reviewed before combining them.

### 5.9 Product analysis

The product query returned the following examples:

| Product | Views | Add-to-cart count | Checkout count | Items purchased | Recorded item revenue |
|---|---:|---:|---:|---:|---:|
| Google Navy Speckled Tee | 56,466 | 14,094 | 462 | 178 | 4,440 |
| Super G Unisex Joggers | 52,758 | 12,015 | 1,185 | 308 | 9,548 |
| Google Zip Hoodie F/C | 49,795 | 13,011 | 986 | 273 | 13,788 |
| Google Campus Bike Eco Tee Navy | 43,140 | 11,631 | 140 | 56 | 1,165 |
| Google Women's Striped L/S | 42,142 | 11,847 | 0 | 0 | 0 |
| Android Large Removable Sticker Sheet | 38,604 | 10,395 | 228 | 134 | 268 |

Among the products shown, **Google Zip Hoodie F/C had the highest recorded item revenue (13,788)**. Super G Unisex Joggers had the highest items-purchased count among these six products.

These results illustrate why product performance should be examined using several measures rather than views alone.

**Metric limitation:** The values above are reported as recorded item revenue from the query output. The revenue field's unit, currency, and aggregation logic should be validated before interpreting the values as confirmed financial totals. Product views, add-to-cart counts, checkout counts, and items purchased may also have different event-level definitions and are not automatically comparable as a sequential funnel.

### 5.10 Checkout activity by device

The checkout query counts distinct sessions containing each checkout-related event. The returned results were:

| Device | `begin_checkout` sessions | `add_shipping_info` sessions | `add_payment_info` sessions | `purchase` sessions | Payment / checkout | Purchase / payment |
|---|---:|---:|---:|---:|---:|---:|
| Desktop | 6,392 | 6,390 | 3,885 | 2,749 | 0.61 | 0.71 |
| Mobile | 4,474 | 4,475 | 2,778 | 1,995 | 0.62 | 0.72 |
| Tablet | 240 | 240 | 152 | 104 | 0.63 | 0.68 |

The two reported ratios are calculated as:

- **Payment / checkout** = sessions containing `add_payment_info` ÷ sessions containing `begin_checkout`.
- **Purchase / payment** = sessions containing `purchase` ÷ sessions containing `add_payment_info`.

These ratios describe the returned session-level event counts. They are not confirmed step-by-step conversion rates: the query counts sessions containing each event, and does not prove that every session completed the events in the intended sequence. The slight differences between `begin_checkout` and `add_shipping_info` counts also warrant validation before drawing conclusions.

## 6. SQL Skills Demonstrated

This project demonstrates practical SQL techniques used in analytics workflows:

- **Common Table Expressions (CTEs):** Organizing multi-step queries for readability.
- **Date parsing and filtering:** Converting GA4 date strings and selecting analysis periods.
- **Nested and repeated data:** Extracting `event_params` with `UNNEST` and analyzing product arrays in `items`.
- **Conditional aggregation:** Using `CASE WHEN`, `COUNTIF`, and conditional counts to summarize specific events.
- **Distinct counting:** Counting distinct users and session identifiers.
- **Session-key construction:** Combining `user_pseudo_id` and `ga_session_id` to identify sessions.
- **Aggregation:** Using `COUNT`, `SUM`, and grouped calculations for traffic, event, page, and product analysis.
- **Safe calculations:** Using `SAFE_DIVIDE` to avoid division-by-zero errors.
- **Data segmentation:** Grouping results by source/medium, device, country, browser, operating system, page, and product.
- **Metric interpretation:** Reviewing denominators, null values, event counts, and attribution limitations before drawing conclusions.

## 7. Data Quality and Limitations

The project is intended as a portfolio demonstration of SQL-based analytics, and its findings should be interpreted within the limits of the data and query definitions.

### 7.1 Session identification

The project constructs a session key using the pseudonymous user identifier and `ga_session_id`. Events without a usable session ID can affect session-based calculations. Session-key construction and missing identifiers should be checked consistently across queries.

### 7.2 Event counts versus sessions

An event count represents how many times an event was recorded. A distinct session count represents how many sessions contained the event. These measures answer different questions and should not be substituted for each other.

### 7.3 Funnel definitions

A query that counts sessions containing `begin_checkout`, `add_shipping_info`, `add_payment_info`, and `purchase` does not automatically establish sequential progression through those steps. A validated sequential funnel would need explicit event-order and session logic.

### 7.4 Daily metric validation

The latest daily output contains suspicious cart-related rates, including a `cart_to_purchase_rate` of 13.0 on November 1 and zero reported cart-session denominators on several following dates. These values are not presented as verified business performance metrics.

### 7.5 Attribution

GA4's exported `traffic_source` fields generally represent first-user acquisition. They should not be treated as session attribution unless the query uses an appropriate session-scoped source definition.

### 7.6 Revenue interpretation

Revenue and item-revenue fields must be interpreted in the context of the specific source field and aggregation used. This README reports values as recorded query outputs and does not claim an independently verified currency or financial total.

### 7.7 Scope and generalizability

The queries do not necessarily use identical date ranges or aggregation scopes. For example, the daily overview uses a specified date window, the event-tracking example uses November 1, 2020, and the checkout query has no date filter in the supplied version. Results from different queries should not be compared as though they share the same time period unless that has been confirmed.

The dataset is a sample e-commerce dataset, so findings should not be generalized to all online retailers.

## 8. How to Run the SQL

### Prerequisites

- A Google account with access to Google BigQuery.
- Access to the BigQuery console.
- Familiarity with basic SQL and BigQuery's Standard SQL dialect.

The queries read from Google's public sample dataset. Running them in your own project may still require a Google Cloud project and may incur query-processing charges depending on your setup and usage.

### Step 1: Open BigQuery

Go to the [Google Cloud BigQuery console](https://console.cloud.google.com/bigquery).

Select or create a Google Cloud project to use for running queries.

### Step 2: Open the public dataset

The SQL files reference this table wildcard:

`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

This is the public GA4 sample e-commerce dataset. You do not need to upload the source data manually.

### Step 3: Open a SQL file

Choose one of the SQL files in this repository. For example:

[`01_daily_overview.sql`](01_daily_overview.sql)

Copy the query into a new BigQuery SQL editor tab.

### Step 4: Check the query configuration

Before running a query:

1. Confirm that the query uses **GoogleSQL (Standard SQL)**.
2. Check the date filters and table reference.
3. Review the selected columns and aggregation logic.
4. Confirm that the metric definitions match the question you intend to answer.

### Step 5: Run the query

Click **Run** in the BigQuery editor.

Review the result table and confirm that the query completes successfully. For ratio calculations, inspect the numerator and denominator when a result is unexpectedly zero, null, or outside the expected range.

### Step 6: Review and interpret the results

For each query:

1. Identify the unit of analysis: events, users, sessions, pages, or products.
2. Check the date range and grouping dimensions.
3. Validate important calculations against the underlying counts.
4. Separate observations from hypotheses about why a pattern occurred.
5. Avoid treating correlation or count differences as proof of causation.

### Step 7: Explore the remaining queries

Run the other SQL files to explore event tracking, traffic sources, devices, countries, browsers, pages, products, and checkout-related activity.

**Repository:** [ecommerce-analytics-sql-bigquery](https://github.com/thuanminhnhan/ecommerce-analytics-sql-bigquery)

## 9. Repository Structure

The repository contains the following SQL files:

```text
ecommerce-analytics-sql-bigquery/
├── 01_daily_overview.sql
├── 02_event_tracking.sql
├── 03_traffic_sources.sql
├── 04_traffic_funnel.sql
├── 05_device_analysis.sql
├── 06_country_analysis.sql
├── 07_os_browser_analysis.sql
├── 08_page_analysis.sql
├── 09_product_analysis.sql
├── 10_checkout_funnel.sql
└── sql/
    └── README.md
```

The 10 analysis queries are stored at the repository root. The additional `sql/README.md` file is retained in the existing repository structure.

## 10. Project Summary

This project demonstrates an end-to-end SQL analysis workflow using a public GA4 e-commerce dataset in Google BigQuery.

It covers daily activity, event tracking, traffic-source groupings, user segmentation, page performance, product metrics, and checkout-related events. The outputs provide descriptive insights into the sample data while highlighting why metric definitions, attribution, and data quality checks matter in analytics work.

The project also documents limitations where the current output does not support a confident business conclusion. In particular, cart-related daily rates, source attribution, revenue interpretation, and sequential checkout behavior require careful validation before being used for decision-making.

## Author

**Thuan Minh Nhan**

- GitHub: [thuanminhnhan](https://github.com/thuanminhnhan)
- Project repository: [E-commerce Analytics with SQL and BigQuery](https://github.com/thuanminhnhan/ecommerce-analytics-sql-bigquery)

