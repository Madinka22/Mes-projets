-- SQL Business Analysis

--1.global kpi's
SELECT
    COUNT(DISTINCT f.product_id) AS total_products,
    COUNT(DISTINCT f.seller_id) AS total_sellers,
    COUNT(DISTINCT sc.subcategory_id) AS total_subcategories,
    COUNT(DISTINCT c.category_id) AS total_categories,

    SUM(f.total_sold) AS total_units_sold,
    SUM(f.number_of_buyers) AS total_buyers,

    ROUND(AVG(f.price), 2) AS avg_product_price,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    ROUND(AVG(f.discount), 2) AS avg_discount,

    ROUND(AVG(f.sell_through_rate) * 100, 2) AS avg_sell_through_rate,

    SUM(f.estimated_revenue) AS total_estimated_revenue

FROM analytics.fact_product_performance f

JOIN analytics.dim_subcategory sc
    ON f.subcategory_id = sc.subcategory_id

JOIN analytics.dim_category c
    ON sc.category_id = c.category_id;

--2.Quelle categorie est plus performante?
SELECT
    c.main_category,

    COUNT(DISTINCT f.product_id) AS total_products,

    SUM(f.total_sold) AS total_units_sold,

    SUM(f.estimated_revenue) AS estimated_revenue,

    ROUND(
        100.0 * SUM(f.estimated_revenue)
        / SUM(SUM(f.estimated_revenue)) OVER (),
        2
    ) AS revenue_share_pct,

    ROUND(AVG(f.price), 2) AS avg_price,

    ROUND(AVG(f.rating), 2) AS avg_rating,

    ROUND(AVG(f.discount), 2) AS avg_discount,

    ROUND(AVG(f.sell_through_rate) * 100, 2) AS avg_sell_through_rate

FROM analytics.fact_product_performance f

JOIN analytics.dim_subcategory sc
    ON f.subcategory_id = sc.subcategory_id

JOIN analytics.dim_category c
    ON sc.category_id = c.category_id

GROUP BY c.main_category

ORDER BY estimated_revenue DESC;

--3.Quelle catégorie vend le plus ?
SELECT
    c.main_category,
    COUNT(DISTINCT f.product_id) AS total_products,
    SUM(f.total_sold) AS total_units_sold,
    SUM(f.estimated_revenue) AS estimated_revenue,
    ROUND(
        100.0 * SUM(f.total_sold)
        / SUM(SUM(f.total_sold)) OVER (),
        2
    ) AS sales_share_pct,
    ROUND(AVG(f.price), 2) AS avg_price,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    ROUND(AVG(f.discount), 2) AS avg_discount,
    ROUND(AVG(f.sell_through_rate) * 100, 2) AS avg_sell_through_rate
FROM analytics.fact_product_performance f
JOIN analytics.dim_subcategory sc
    ON f.subcategory_id = sc.subcategory_id
JOIN analytics.dim_category c
    ON sc.category_id = c.category_id
GROUP BY c.main_category
ORDER BY total_units_sold DESC;

--4.Quelle catégorie possède le meilleur sell-through?
SELECT
    c.main_category,
    COUNT(DISTINCT f.product_id) AS total_products,
    SUM(f.total_sold) AS total_units_sold,
    SUM(f.available_stock) AS available_stock,
    ROUND(AVG(f.sell_through_rate) * 100, 2) AS avg_sell_through_rate,
    ROUND(AVG(f.discount), 2) AS avg_discount,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    RANK() OVER (
        ORDER BY AVG(f.sell_through_rate) DESC
    ) AS sell_through_rank
FROM analytics.fact_product_performance f
JOIN analytics.dim_subcategory sc
    ON f.subcategory_id = sc.subcategory_id
JOIN analytics.dim_category c
    ON sc.category_id = c.category_id
GROUP BY c.main_category
ORDER BY sell_through_rank;


--5.Quels vendeurs génèrent le plus de revenu ?
SELECT
    s.seller,
    COUNT(DISTINCT f.product_id) AS total_products,
    SUM(f.total_sold) AS total_units_sold,
    SUM(f.estimated_revenue) AS estimated_revenue,
    ROUND(
        100.0 * SUM(f.estimated_revenue)
        / SUM(SUM(f.estimated_revenue)) OVER (),
        2
    ) AS revenue_share_pct,
    ROUND(AVG(f.price), 2) AS avg_price,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    ROUND(AVG(f.discount), 2) AS avg_discount,
    ROUND(AVG(f.sell_through_rate) * 100, 2) AS avg_sell_through_rate,
    RANK() OVER (
        ORDER BY SUM(f.estimated_revenue) DESC
    ) AS revenue_rank
FROM analytics.fact_product_performance f
JOIN analytics.dim_seller s
    ON f.seller_id = s.seller_id
GROUP BY s.seller
ORDER BY revenue_rank;

--6.Quel vendeur possède le meilleur portefeuille de produits ?
SELECT
    s.seller,
    COUNT(DISTINCT f.product_id) AS total_products,

    ROUND(
        SUM(f.estimated_revenue)
        / COUNT(DISTINCT f.product_id),
        2
    ) AS avg_revenue_per_product,

    ROUND(
        SUM(f.total_sold)::NUMERIC
        / COUNT(DISTINCT f.product_id),
        2
    ) AS avg_units_sold_per_product,

    ROUND(AVG(f.rating), 2) AS avg_rating,

    ROUND(
        AVG(f.sell_through_rate) * 100,
        2
    ) AS avg_sell_through_rate,

    ROUND(AVG(f.discount), 2) AS avg_discount,

    SUM(f.estimated_revenue) AS total_estimated_revenue,

    SUM(f.total_sold) AS total_units_sold

FROM analytics.fact_product_performance f
JOIN analytics.dim_seller s
    ON f.seller_id = s.seller_id

GROUP BY s.seller
ORDER BY avg_revenue_per_product DESC;

-- 7.Produits présentant un risque de rupture -- 
-- Critères : 
-- - sell-through >= 95 % 
-- - stock <= 5 unités 
-- - volume vendu significatif

SELECT
    p.product_name,
    s.seller,
    sc.sub_category,
    f.total_sold,
    f.available_stock,
    ROUND(f.sell_through_rate * 100, 2) AS sell_through_pct,
    ROUND(f.estimated_revenue, 2) AS estimated_revenue,
    f.discount,

    CASE
        WHEN f.available_stock = 0
             AND f.sell_through_rate >= 0.99
            THEN 'CRITICAL'

        WHEN f.available_stock <= 5
             AND f.sell_through_rate >= 0.95
            THEN 'HIGH'

        ELSE 'MEDIUM'
    END AS stock_risk

FROM analytics.fact_product_performance f

JOIN analytics.dim_product p
    ON f.product_id = p.product_id

JOIN analytics.dim_seller s
    ON f.seller_id = s.seller_id

JOIN analytics.dim_subcategory sc
    ON f.subcategory_id = sc.subcategory_id

WHERE
    f.sell_through_rate >= 0.95
    AND f.available_stock <= 5
    AND f.total_sold >= 100

ORDER BY
    stock_risk,
    f.estimated_revenue DESC;


-- 8.Produits présentant un risque de surstock

-- Critères :
-- - sell-through relativement faible
-- - stock important
-- - volume déjà vendu significatif

SELECT
    p.product_name,
    s.seller,
    sc.sub_category,
    f.total_sold,
    f.available_stock,
    ROUND(f.sell_through_rate * 100, 2) AS sell_through_pct,
    ROUND(f.estimated_revenue, 2) AS estimated_revenue,
    f.discount,
    f.rating,

    CASE
        WHEN f.sell_through_rate < 0.70
             AND f.available_stock >= 4000
            THEN 'HIGH'

        WHEN f.sell_through_rate < 0.75
             AND f.available_stock >= 3000
            THEN 'MEDIUM'

        ELSE 'LOW'
    END AS overstock_risk

FROM analytics.fact_product_performance f

JOIN analytics.dim_product p
    ON f.product_id = p.product_id

JOIN analytics.dim_seller s
    ON f.seller_id = s.seller_id

JOIN analytics.dim_subcategory sc
    ON f.subcategory_id = sc.subcategory_id

WHERE
    f.sell_through_rate < 0.75
    AND f.available_stock >= 3000

ORDER BY
    f.available_stock DESC;


-- 9. VOLUME VS VALUE --
-- Identifier les produits qui vendent beaucoup mais génèrent
-- relativement peu de valeur, et inversement.

WITH product_percentiles AS (

    SELECT
        p.product_name,
        s.seller,
        sc.sub_category,

        f.total_sold,
        f.estimated_revenue,

        PERCENT_RANK() OVER (
            ORDER BY f.total_sold
        ) AS volume_percentile,

        PERCENT_RANK() OVER (
            ORDER BY f.estimated_revenue
        ) AS revenue_percentile

    FROM analytics.fact_product_performance f

    JOIN analytics.dim_product p
        ON f.product_id = p.product_id

    JOIN analytics.dim_seller s
        ON f.seller_id = s.seller_id

    JOIN analytics.dim_subcategory sc
        ON f.subcategory_id = sc.subcategory_id
)

SELECT
    product_name,
    seller,
    sub_category,
    total_sold,

    ROUND(estimated_revenue, 2) AS estimated_revenue,

    ROUND(
        (volume_percentile * 100)::NUMERIC,
        2
    ) AS volume_percentile,

    ROUND(
        (revenue_percentile * 100)::NUMERIC,
        2
    ) AS revenue_percentile,

    CASE
        WHEN volume_percentile >= 0.75
             AND revenue_percentile < 0.50
            THEN 'HIGH VOLUME / LOW VALUE'

        WHEN volume_percentile < 0.50
             AND revenue_percentile >= 0.75
            THEN 'LOW VOLUME / HIGH VALUE'

        WHEN volume_percentile >= 0.75
             AND revenue_percentile >= 0.75
            THEN 'HIGH VOLUME / HIGH VALUE'

        ELSE 'OTHER'
    END AS performance_profile

FROM product_percentiles

WHERE
    volume_percentile >= 0.75
    OR revenue_percentile >= 0.75

ORDER BY
    estimated_revenue DESC;
