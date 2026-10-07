CREATE TABLE staging.products_raw (
    product_name VARCHAR(500),
    price NUMERIC(12,2),
    rating NUMERIC(3,2),
    number_of_buyers INTEGER,
    total_sold INTEGER,
    available_stock INTEGER,
    main_category VARCHAR(100),
    sub_category VARCHAR(100),
    discount NUMERIC(5,2),
    seller VARCHAR(255),
    return_policy BOOLEAN,
    product_url TEXT,
    
    estimated_revenue NUMERIC(15,2),
    sell_through_rate NUMERIC(10,4),
    stock_status VARCHAR(20),
    discount_band VARCHAR(20)
);