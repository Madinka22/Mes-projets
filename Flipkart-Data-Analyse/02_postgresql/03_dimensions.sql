--Creer dim_category
CREATE TABLE analytics.dim_category (
    category_id SERIAL PRIMARY KEY,
    main_category VARCHAR(100) NOT NULL
);

INSERT INTO analytics.dim_category (main_category)
SELECT DISTINCT main_category
FROM staging.products_raw
ORDER BY main_category;

-- Creer dim_subcategory
CREATE TABLE analytics.dim_subcategory (
    subcategory_id SERIAL PRIMARY KEY,
    sub_category VARCHAR(100) NOT NULL,
    category_id INTEGER NOT NULL,

	CONSTRAINT fk_subcategory_category
	  FOREIGN KEY (category_id)
	  REFERENCES analytics.dim_category(category_id)
);

INSERT INTO analytics.dim_subcategory (
    sub_category,
	category_id
)
SELECT DISTINCT 
    p.sub_category,
	c.category_id
FROM staging.products_raw p
JOIN analytics.dim_category c
ON p.main_category = c.main_category;


--Créer dim_seller
CREATE TABLE analytics.dim_seller (
    seller_id SERIAL PRIMARY KEY,
    seller VARCHAR(255) NOT NULL
);

INSERT INTO analytics.dim_seller (seller)
SELECT DISTINCT seller
FROM staging.products_raw
ORDER BY seller;

--Créer dim_product
CREATE TABLE analytics.dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(500) NOT NULL,
    product_url TEXT
);

INSERT INTO analytics.dim_product (
    product_name,
    product_url
)
SELECT DISTINCT
    product_name,
    product_url
FROM staging.products_raw;