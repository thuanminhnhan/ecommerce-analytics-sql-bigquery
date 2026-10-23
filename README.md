# E-commerce Analytics with SQL and Google BigQuery

A portfolio project analyzing Google Analytics 4 (GA4) e-commerce event data with SQL to explore website traffic, user behavior, product performance, and checkout activity.

**Tools:** SQL · Google BigQuery · GA4 Public Sample Dataset  
**Project type:** Exploratory data analysis (EDA) using SQL  
**Dataset:** Google Analytics 4 obfuscated sample e-commerce events  
**Analysis focus:** Traffic sources, engagement, products, and purchase-related events

---

## 1. Project Overview

This project uses SQL in Google BigQuery to analyze e-commerce event data and answer practical business questions about website activity and shopping behavior.

The analysis is organized into 10 SQL queries covering:

- Daily overview metrics
- Event tracking
- Traffic sources
- Traffic-source activity
- Device analysis
- Country analysis
- Browser and operating-system analysis
- Page performance
- Product performance
- Checkout-related events

The goal is to demonstrate how raw analytics data can be transformed into structured outputs, business insights, and actionable recommendations while recognizing data-quality and measurement limitations.

---

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

---

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

### Important Data Considerations

- The dataset is an obfuscated sample, not a complete representation of a live business.
- GA4 exports contain nested and repeated fields, requiring techniques such as `UNNEST()`.
- Event counts, distinct users, distinct sessions, and purchases represent different units of analysis.
- The meaning of a metric depends on its calculation and denominator.
- `traffic_source` should be interpreted according to the specific GA4 field and query logic used; it should not automatically be treated as session-level attribution.
- Revenue and item-revenue fields are reported as recorded by the query and should not be treated as independently verified financial totals.

---

# 4. SQL Analysis

All 10 SQL files are available in the repository root.

| # | Analysis | SQL file | Purpose |
|---|---|---|---|
| 01 | Daily Overview | [`01_daily_overview.sql`](01_daily_overview.sql) | Daily sessions, product-view activity, cart activity, purchases, revenue, and basket metrics |
| 02 | Event Tracking | [`02_event_tracking.sql`](02_event_tracking.sql) | Event counts and active users across GA4 events |
| 03 | Traffic Sources | [`03_traffic_sources.sql`](03_traffic_sources.sql) | Reported traffic-source and medium groupings |
| 04 | Traffic Source Activity | [`04_traffic_funnel.sql`](04_traffic_funnel.sql) | Item-view, checkout, and purchase activity across source groupings |
| 05 | Device Analysis | [`05_device_analysis.sql`](05_device_analysis.sql) | Active users across desktop, mobile, and tablet |
| 06 | Country Analysis | [`06_country_analysis.sql`](06_country_analysis.sql) | Active users by country |
| 07 | OS and Browser Analysis | [`07_os_browser_analysis.sql`](07_os_browser_analysis.sql) | Active users across operating-system and browser combinations |
| 08 | Page Analysis | [`08_page_analysis.sql`](08_page_analysis.sql) | Page views and users |
| 09 | Product Analysis | [`09_product_analysis.sql`](09_product_analysis.sql) | Product views, cart activity, checkout activity, purchases, and recorded item revenue |
| 10 | Checkout Event Analysis | [`10_checkout_funnel.sql`](10_checkout_funnel.sql) | Checkout-related sessions by device |

---

# 5. Key Findings

The findings below summarize the outputs returned by the current SQL queries. They are descriptive observations rather than proof of causation.

## 5.1 Daily Activity and Purchase Metrics

The daily overview query calculates sessions, product-view rates, cart-related rates, purchase rate, purchase counts, recorded purchase revenue, average recorded revenue per purchase, and basket quantity.

Selected results:

| Date | Sessions | Purchases | Recorded Purchase Revenue | Avg. Recorded Revenue / Purchase |
|---|---:|---:|---:|---:|
| 2020-11-01 | 2,625 | 14 | 773.00 | 55.21 |
| 2020-11-06 | 3,332 | 58 | 3,438.00 | 59.28 |
| 2020-11-10 | 3,835 | 64 | 4,041.00 | 63.14 |
| 2020-11-13 | 3,347 | 79 | 5,831.00 | 73.81 |
| 2020-11-15 | 2,214 | 21 | 1,483.00 | 70.62 |

November 13 recorded the highest purchase count and purchase revenue among the selected dates shown.

However, the current output also contains suspicious cart-related metrics. For example, `cart_to_purchase_rate` is `13.0` on November 1, while several following dates return `NULL` because the cart-session denominator is zero.

These values are therefore treated as **measurement/query validation issues rather than confirmed conversion performance**.

---

## 5.2 Event Tracking

For November 1, 2020, the event-tracking query returned:

| Event | Event Count | Active Users |
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

`page_view` and `user_engagement` were among the most frequent events.

A notable finding is the difference between `begin_checkout` (127 events) and `add_to_cart` (4 events).

This is an important **tracking validation signal**, but it does not prove that users bypassed the cart. Possible explanations include event implementation, event definitions, data collection behavior, or differences in query logic.

---

## 5.3 Traffic Sources

The traffic-source query returned these leading source/medium groupings:

| Source / Medium | Reported Sessions | Share |
|---|---:|---:|
| `google / organic` | 111,488 | 31.42% |
| `(direct) / (none)` | 82,362 | 23.21% |
| `Other / Other` | 51,775 | 14.59% |
| `Other / referral` | 34,110 | 9.61% |
| `shop.googlemerchandisestore.com / referral` | 28,044 | 7.90% |
| `(data deleted) / (data deleted)` | 21,087 | 5.94% |
| `google / cpc` | 15,534 | 4.38% |

The two largest reported source/medium groupings were:

- `google / organic` — 111,488 sessions
- `(direct) / (none)` — 82,362 sessions

Together, they represent approximately **54.6% of the reported sessions** in these two groups.

This suggests that organic search and direct traffic are important traffic sources in the returned data.

**Attribution limitation:** the exact interpretation depends on the GA4 fields used by the query. The exported `traffic_source` fields generally describe first-user acquisition rather than necessarily representing session-scoped attribution.

---

## 5.4 Traffic-Source Activity

Selected results:

| Source / Medium | Reported Sessions | Item Views | Checkout Count | Purchase Count |
|---|---:|---:|---:|---:|
| `google / organic` | 102,530 | 116,917 | 10,642 | 1,454 |
| `(direct) / (none)` | 75,025 | 87,916 | 8,597 | 1,251 |
| `Other / Other` | 50,776 | 50,969 | 4,452 | 606 |
| `Other / referral` | 32,362 | 36,776 | 3,733 | 557 |
| `shop.googlemerchandisestore.com / referral` | 25,350 | 35,418 | 4,437 | 701 |
| `(data deleted) / (data deleted)` | 16,969 | 32,716 | 4,884 | 830 |
| `google / cpc` | 15,449 | 14,831 | 1,162 | 166 |

`google / organic` had the highest reported purchase count among the displayed source/medium groups, with **1,454 purchases**.

This is a count-based observation and does not establish that organic search has the highest conversion rate or return on marketing spend.

---

## 5.5 Device Analysis

| Device | Active Users |
|---|---:|
| Desktop | 158,917 |
| Mobile | 109,195 |
| Tablet | 6,250 |

Desktop had the largest active-user count, followed by mobile and tablet.

The data therefore suggests that **desktop and mobile should be the primary platforms considered when evaluating website experience**.

However, active-user volume alone does not establish that one device converts better or generates more revenue.

---

## 5.6 Country Analysis

Top countries in the returned results:

| Country | Active Users |
|---|---:|
| United States | 118,493 |
| India | 25,367 |
| Canada | 20,268 |
| United Kingdom | 8,527 |
| France | 5,381 |

The **United States** had the largest active-user count among the countries shown, with **118,493 active users**.

This provides a useful starting point for geographic segmentation, although the project does not attempt to determine profitability or conversion performance by country.

---

## 5.7 Operating System and Browser

Top combinations:

| Platform / Browser | Active Users |
|---|---:|
| Web / Chrome | 113,813 |
| Web / Safari | 32,758 |
| iOS / Safari | 28,724 |
| Windows / Chrome | 27,887 |
| Android / Chrome | 21,056 |
| Macintosh / Chrome | 15,114 |

`Web / Chrome` had the highest active-user count among the combinations shown.

This analysis describes the technology mix represented in the dataset. It does not independently measure browser compatibility, performance, or conversion.

---

## 5.8 Page Analysis

High-view pages in the returned results:

| Page | Views | Users |
|---|---:|---:|
| `https://shop.googlemerchandisestore.com/` | 183,074 | 93,511 |
| `/Google+Redesign/Apparel` | 81,681 | 50,193 |
| `/basket.html` | 78,876 | 22,720 |
| `/store.html` | 73,568 | 32,324 |
| `https://googlemerchandisestore.com/` | 61,893 | 34,686 |
| `/Google+Redesign/Apparel/Mens` | 46,387 | 21,580 |

The main homepage URL had the highest view count among the listed pages.

The basket page also appeared among the highest-view pages, showing substantial activity around the shopping process.

Page views alone do not indicate whether a page performs well. Page purpose, navigation behavior, event tracking, and downstream outcomes should also be considered.

---

## 5.9 Product Analysis

Selected product results:

| Product | Views | Add-to-Cart | Checkout | Items Purchased | Recorded Item Revenue |
|---|---:|---:|---:|---:|---:|
| Google Navy Speckled Tee | 56,466 | 14,094 | 462 | 178 | 4,440 |
| Super G Unisex Joggers | 52,758 | 12,015 | 1,185 | 308 | 9,548 |
| Google Zip Hoodie F/C | 49,795 | 13,011 | 986 | 273 | 13,788 |
| Google Campus Bike Eco Tee Navy | 43,140 | 11,631 | 140 | 56 | 1,165 |
| Google Women's Striped L/S | 42,142 | 11,847 | 0 | 0 | 0 |
| Android Large Removable Sticker Sheet | 38,604 | 10,395 | 228 | 134 | 268 |

Among the products shown:

- **Google Zip Hoodie F/C** had the highest recorded item revenue: **13,788**.
- **Super G Unisex Joggers** had the highest items-purchased count: **308**.
- **Google Women's Striped L/S** recorded high views and add-to-cart activity but **0 checkout and 0 purchased items** in this output.

The product results demonstrate why product analysis should consider multiple stages and not rely on views alone.

The revenue values are reported query outputs; their financial interpretation depends on the underlying GA4 field and aggregation logic.

---

## 5.10 Checkout Activity by Device

The checkout query counts distinct sessions containing each checkout-related event.

| Device | Begin Checkout | Shipping Info | Payment Info | Purchase | Payment / Checkout | Purchase / Payment |
|---|---:|---:|---:|---:|---:|---:|
| Desktop | 6,392 | 6,390 | 3,885 | 2,749 | 0.61 | 0.71 |
| Mobile | 4,474 | 4,475 | 2,778 | 1,995 | 0.62 | 0.72 |
| Tablet | 240 | 240 | 152 | 104 | 0.63 | 0.68 |

The reported ratios are:

- **Payment / Checkout** = sessions containing `add_payment_info` ÷ sessions containing `begin_checkout`
- **Purchase / Payment** = sessions containing `purchase` ÷ sessions containing `add_payment_info`

The results show relatively similar ratios across desktop and mobile.

However, these should **not be described as validated sequential conversion rates**, because the query identifies sessions containing events rather than proving that events occurred in the intended sequence.

---

# 6. Four Key Insights

Based on the combined results of the 10 queries, four findings stand out as the most useful from a business perspective.

### Insight 1 — Organic search and direct traffic are major acquisition sources

`google / organic` generated **111,488 reported sessions (31.42%)**, while `(direct) / (none)` generated **82,362 (23.21%)**.

Together, these two groups represent approximately **54.6%** of the reported sessions in the displayed source/medium results.

**Business interpretation:** Organic search appears to be an important traffic source, while the large direct segment also indicates substantial direct or unattributed entry activity.

---

### Insight 2 — Desktop and mobile represent the core user base

Desktop recorded **158,917 active users**, while mobile recorded **109,195**.

Together, these two device categories account for the vast majority of active users in the returned device results.

**Business interpretation:** Website experience should be evaluated primarily across desktop and mobile rather than treating tablet as a major optimization priority.

---

### Insight 3 — Product demand does not translate equally into purchase outcomes

Among the selected products, Google Zip Hoodie F/C generated the highest recorded item revenue (**13,788**), while Super G Unisex Joggers had the highest items-purchased count (**308**).

At the same time, Google Women's Striped L/S recorded **42,142 views and 11,847 add-to-cart events but 0 checkout and 0 purchased items** in the returned query output.

**Business interpretation:** Product performance varies significantly across the shopping journey. High product interest does not necessarily result in recorded purchases, making product-level funnel analysis valuable.

---

### Insight 4 — Checkout tracking requires validation before conversion optimization

The event query returned **127 `begin_checkout` events but only 4 `add_to_cart` events** on November 1.

The daily overview also produced suspicious cart-related metrics, including a `cart_to_purchase_rate` of **13.0** on November 1 and `NULL` values on dates where the cart-session denominator was zero.

**Business interpretation:** The current data contains signals of inconsistent event tracking or metric logic. Conversion optimization should not rely on these funnel metrics until the event instrumentation and calculation logic are validated.

---

# 7. Business Recommendations

The analysis suggests four practical areas for further business action.

### Recommendation 1 — Prioritize SEO and organic acquisition

Organic search is the largest reported source group, with **111,488 sessions and 1,454 purchases** in the traffic-source activity output.

**Recommended actions:**

- Identify the landing pages receiving organic traffic.
- Analyze which product/category pages attract organic users.
- Improve SEO content around high-interest product categories.
- Track organic sessions, product views, add-to-cart, and purchases using consistent session-level attribution.

**Expected objective:** Improve the ability to convert existing organic traffic rather than focusing only on increasing traffic volume.

---

### Recommendation 2 — Prioritize desktop and mobile UX

Desktop and mobile recorded **158,917** and **109,195 active users**, respectively.

**Recommended actions:**

- Validate checkout usability on both desktop and mobile.
- Review page speed and interaction issues on mobile.
- Compare product-view → cart → checkout → purchase behavior by device after tracking is validated.
- Prioritize mobile and desktop testing before investing heavily in tablet-specific optimization.

**Expected objective:** Ensure the two largest user segments have a reliable and frictionless shopping experience.

---

### Recommendation 3 — Use product-level performance to guide merchandising

Google Zip Hoodie F/C had the highest recorded item revenue among the selected products (**13,788**), while Super G Unisex Joggers had the highest purchased-item count (**308**).

The Google Women's Striped L/S result is also worth investigating because it recorded **42,142 views and 11,847 add-to-cart events but no recorded checkout or purchase activity** in the query output.

**Recommended actions:**

- Investigate high-view/high-cart products with low or zero recorded purchases.
- Review product availability, pricing, product-page experience, and tracking implementation.
- Identify high-revenue products for merchandising and promotional testing.
- Separate genuine product-performance issues from tracking problems before making inventory or pricing decisions.

**Expected objective:** Improve the transition from product interest to completed purchases.

---

### Recommendation 4 — Fix and validate analytics tracking before using funnel KPIs

The largest immediate analytical risk is not traffic volume but **measurement reliability**.

The project identified several signals requiring investigation:

- `begin_checkout` = 127 events vs. `add_to_cart` = 4 events on November 1.
- `cart_to_purchase_rate` = 13.0 on November 1.
- Multiple dates have zero cart-session denominators.
- Checkout events do not necessarily prove sequential progression.

**Recommended actions:**

1. Audit GA4 ecommerce event implementation.
2. Verify that `add_to_cart`, `begin_checkout`, `add_shipping_info`, `add_payment_info`, and `purchase` fire at the intended user actions.
3. Validate `transaction_id` and purchase-event deduplication.
4. Rebuild the funnel using explicit session-level event ordering.
5. Standardize metric definitions and denominators before reporting conversion KPIs.

**Expected objective:** Establish trustworthy conversion metrics before making marketing, UX, or product decisions based on the funnel.

---

# 8. SQL Skills Demonstrated

This project demonstrates practical SQL techniques used in analytics workflows:

- **Common Table Expressions (CTEs):** Organizing multi-step queries for readability.
- **Date parsing and filtering:** Converting GA4 date strings and selecting analysis periods.
- **Nested and repeated data:** Extracting `event_params` with `UNNEST()` and analyzing product arrays in `items`.
- **Conditional aggregation:** Using `CASE WHEN`, `COUNTIF`, and conditional counts.
- **Distinct counting:** Counting distinct users and session identifiers.
- **Session-key construction:** Combining `user_pseudo_id` and `ga_session_id`.
- **Aggregation:** Using `COUNT`, `SUM`, and grouped calculations.
- **Safe calculations:** Using `SAFE_DIVIDE` to avoid division-by-zero errors.
- **Data segmentation:** Grouping results by source/medium, device, country, browser, operating system, page, and product.
- **Metric validation:** Reviewing denominators, null values, event counts, and attribution limitations before drawing conclusions.

### Example: Session Key Construction

One of the important steps in the project is constructing a session-level identifier from GA4 event parameters:

```sql
CONCAT(
  user_pseudo_id,
  '-',
  (
    SELECT value.int_value
    FROM UNNEST(event_params)
    WHERE key = 'ga_session_id'
  )
) AS session_key
```

This allows event-level GA4 data to be aggregated at the session level for metrics such as sessions, view-item sessions, cart sessions, and purchase sessions.

---

# 9. Data Quality and Limitations

This project is designed as a portfolio demonstration of SQL-based analytics. Results should therefore be interpreted according to the source data and query definitions.

### Session Identification

The project constructs a session key using `user_pseudo_id` and `ga_session_id`.

Events without a usable session ID can affect session-based calculations.

### Event Counts vs. Sessions

An event count represents how many times an event was recorded.

A distinct session count represents how many sessions contained that event.

These measures answer different questions and should not be substituted for one another.

### Funnel Definitions

A query counting sessions containing `begin_checkout`, `add_shipping_info`, `add_payment_info`, and `purchase` does not automatically establish sequential progression.

A validated sequential funnel requires explicit event-order and session logic.

### Daily Metric Validation

The latest daily output contains suspicious cart-related rates, including:

- `cart_to_purchase_rate = 13.0` on November 1.
- `view_to_cart_rate = 0` across several following dates.
- `NULL` cart-to-purchase rates where the cart-session denominator is zero.

These values are therefore treated as **data-quality/query-validation signals**, not confirmed business conversion rates.

### Attribution

GA4 `traffic_source` fields generally represent first-user acquisition information. They should not automatically be interpreted as session-level marketing attribution.

### Revenue Interpretation

Revenue and item-revenue values are reported as recorded by the query output.

The project does not independently verify the currency, financial accounting treatment, or aggregation methodology.

### Scope

The queries may use different date ranges or aggregation scopes.

For example, the daily overview uses a specified date window, while the event-tracking and checkout analyses may use different scopes.

Results from different queries should therefore only be compared when their time period and metric definitions are aligned.

### Dataset Generalizability

The dataset is a public GA4 sample dataset and should not be treated as representative of all e-commerce businesses.

---

# 10. How to Run the SQL

## Prerequisites

- Google account with access to Google BigQuery.
- Access to the BigQuery console.
- Basic knowledge of SQL and BigQuery Standard SQL.

The queries reference Google's public sample dataset. Depending on your Google Cloud configuration and usage, query processing may incur charges.

## Step 1 — Open BigQuery

Open the [Google Cloud BigQuery Console](https://console.cloud.google.com/bigquery).

Select or create a Google Cloud project to use for running queries.

## Step 2 — Use the Public Dataset

The queries reference:

```text
bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
```

The source data does not need to be uploaded manually.

## Step 3 — Open a SQL File

Choose a query from the repository.

For example:

[`01_daily_overview.sql`](01_daily_overview.sql)

Copy the query into a new BigQuery SQL editor tab.

## Step 4 — Check Query Configuration

Before running:

1. Confirm **GoogleSQL / Standard SQL** is enabled.
2. Review the date filters.
3. Check the table reference.
4. Review the selected dimensions and metrics.
5. Confirm that the metric definition matches the business question.

## Step 5 — Run the Query

Click **Run** in BigQuery.

Review the output table and pay particular attention to:

- Numerators and denominators for ratios.
- `NULL` values.
- Unexpected zero values.
- Event counts versus distinct sessions.
- Duplicate or missing identifiers.

## Step 6 — Interpret the Results

For each query:

1. Identify the unit of analysis: event, user, session, page, or product.
2. Check the date range.
3. Validate important calculations against underlying counts.
4. Separate observations from hypotheses.
5. Avoid treating count differences as proof of causation.
6. Check data quality before making business recommendations.

## Step 7 — Explore the Full Analysis

Run the remaining SQL files to explore:

- Event behavior
- Traffic acquisition
- Device usage
- Geographic distribution
- Browser and OS usage
- Page performance
- Product performance
- Checkout activity

---

# 11. Repository Structure

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

The 10 analysis queries are stored at the repository root.

---

# 12. Project Summary

This project demonstrates an end-to-end SQL analytics workflow using a public GA4 e-commerce dataset in Google BigQuery.

The analysis covers:

**Acquisition → User behavior → Devices & geography → Pages → Products → Checkout**

The main business takeaways are:

1. **Organic search and direct traffic are major traffic sources**, with Google organic representing 31.42% of the reported sessions in the traffic-source output.
2. **Desktop and mobile are the core user segments**, with 158,917 and 109,195 active users respectively.
3. **Product performance varies across the shopping journey**, with Google Zip Hoodie F/C showing the highest recorded item revenue among the selected products.
4. **Checkout and cart tracking requires validation** before the funnel metrics can be used confidently for business decisions.

The most important recommendation from this analysis is to **validate the ecommerce tracking and funnel logic before optimizing conversion KPIs**. Once measurement is reliable, the business can use the resulting data to make better decisions around acquisition, UX, merchandising, and checkout optimization.

This project intentionally distinguishes between:

**What the data shows → What it may mean → What should be validated → What the business could do next.**

That distinction is an important part of practical data analysis.

---

# 13. Links

**GitHub Repository:**  
[ecommerce-analytics-sql-bigquery](https://github.com/thuanminhnhan/ecommerce-analytics-sql-bigquery)

**Author:**  
[Thuan Minh Nhan](https://github.com/thuanminhnhan)

**SQL Files:**  
[01 Daily Overview](01_daily_overview.sql) · [02 Event Tracking](02_event_tracking.sql) · [03 Traffic Sources](03_traffic_sources.sql) · [04 Traffic Funnel](04_traffic_funnel.sql) · [05 Device Analysis](05_device_analysis.sql) · [06 Country Analysis](06_country_analysis.sql) · [07 OS & Browser Analysis](07_os_browser_analysis.sql) · [08 Page Analysis](08_page_analysis.sql) · [09 Product Analysis](09_product_analysis.sql) · [10 Checkout Funnel](10_checkout_funnel.sql)
