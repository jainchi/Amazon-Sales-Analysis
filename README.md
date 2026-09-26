# Amazon-Sales-Analysis




# Amazon Sales Analytics — SQL Project

An end-to-end SQL analytics project built on a simulated Amazon-style e-commerce dataset in **PostgreSQL**. The project covers everything from foundational joins to advanced window functions, correlated subqueries, business-facing analytical models (RFM segmentation, churn detection, YoY/MoM growth), and a PL/pgSQL stored procedure for automating inventory updates.

## Dataset & Schema

The dataset models a typical e-commerce marketplace with 8 relational tables:

| Table | Description |
|---|---|
| `category` | Product categories (Electronics, Clothing, Pet Supplies, etc.) |
| `customers` | Customer records — name, state |
| `sellers` | Seller records — name, country of origin |
| `products` | Product catalog — price, cost of goods sold (COGS), category |
| `orders` | Order-level records — date, customer, seller, status |
| `order_items` | Line-item detail per order — product, quantity, price per unit |
| `payments` | Payment status and date per order |
| `shippings` | Shipping and delivery status per order |
| `inventory` | Stock levels per product per warehouse |

All foreign key relationships are enforced at the schema level (see the `CREATE TABLE` statements at the top of the SQL file).

## What's Covered

The queries are organized progressively by concept:

- **Q1–Q10** — Basic SELECT, filtering, INNER/LEFT/RIGHT/CROSS joins
- **Q11–Q20** — Aggregate functions, GROUP BY, HAVING, conditional aggregation with `FILTER`
- **Q21–Q30** — Subqueries: simple, correlated, nested, IN/NOT IN, subquery-with-JOIN
- **Q31–Q40** — Window functions: `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `NTILE`, `LEAD`, `LAG`, running totals, cumulative sums
- **Q41–Q50** — Date/time functions: `EXTRACT`, `DATE_TRUNC`, `AGE`, delivery-time calculations, weekend/overdue-order filters
- 
- **Q51–Q59** — Applied business analytics:
  - Year-over-Year and Month-over-Month revenue growth
  - RFM-style customer segmentation (Recency, Frequency, Monetary)
  - Churn prediction based on historical purchase consistency
  - Cumulative revenue tracking with milestone flags
  - Geographic category-preference ranking by state
  - Manual pivot/crosstab reporting
  - Payment audit (successful vs. failed/at-risk revenue)
  - Inventory burn-rate forecasting (days-until-stockout)
  
- **Q60** — A PL/pgSQL stored procedure (`productquantity`) that validates stock, decrements inventory, and inserts a new order + order item transactionally, with `RAISE EXCEPTION`/`RAISE NOTICE` for error handling and logging.

## Notes on Design Decisions

A few queries use a fixed historical date (rather than `CURRENT_DATE`) as the anchor point for "recency" calculations (e.g. churn detection in Q52–Q53). This is intentional: the underlying dataset is static and historical, so anchoring against `CURRENT_DATE` would cause every customer to appear as churned. The anchor date is set relative to the dataset's own most recent order date instead.

## Tools

- **PostgreSQL** (window functions, `FILTER` clauses, PL/pgSQL procedures)
- Developed and tested in **pgAdmin 4**

## About

This project is part of a broader portfolio combining SQL analytics with Power BI dashboarding, built while preparing for data analytics roles. Feedback and suggestions welcome.
