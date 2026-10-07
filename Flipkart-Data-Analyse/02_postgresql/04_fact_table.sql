--Table de faits 
CREATE TABLE analytics.fact_product_performance (
    product_id INTEGER NOT NULL,
    seller_id INTEGER NOT NULL,
    subcategory_id INTEGER NOT NULL,

    price NUMERIC(12,2),
    rating NUMERIC(3,2),
    number_of_buyers INTEGER,
    total_sold INTEGER,
    available_stock INTEGER,
    discount NUMERIC(5,2),
    return_policy BOOLEAN,

    estimated_revenue NUMERIC(15,2),
    sell_through_rate NUMERIC(10,4),
    stock_status VARCHAR(20),
    discount_band VARCHAR(20),

    PRIMARY KEY (
        product_id,
        seller_id,
        subcategory_id
    ),

    CONSTRAINT fk_fact_product
        FOREIGN KEY (product_id)
        REFERENCES analytics.dim_product(product_id),

    CONSTRAINT fk_fact_seller
        FOREIGN KEY (seller_id)
        REFERENCES analytics.dim_seller(seller_id),

    CONSTRAINT fk_fact_subcategory
        FOREIGN KEY (subcategory_id)
        REFERENCES analytics.dim_subcategory(subcategory_id)
);

INSERT INTO analytics.fact_product_performance (
    product_id,
    seller_id,
    subcategory_id,
    price,
    rating,
    number_of_buyers,
    total_sold,
    available_stock,
    discount,
    return_policy,
    estimated_revenue,
    sell_through_rate,
    stock_status,
    discount_band
)
SELECT
    p.product_id,
    s.seller_id,
    sc.subcategory_id,
    r.price,
    r.rating,
    r.number_of_buyers,
    r.total_sold,
    r.available_stock,
    r.discount,
    r.return_policy,
    r.estimated_revenue,
    r.sell_through_rate,
    r.stock_status,
    r.discount_band
FROM staging.products_raw r
JOIN analytics.dim_product p
    ON r.product_name = p.product_name
    AND r.product_url = p.product_url
JOIN analytics.dim_seller s
    ON r.seller = s.seller
JOIN analytics.dim_subcategory sc
    ON r.sub_category = sc.sub_category;