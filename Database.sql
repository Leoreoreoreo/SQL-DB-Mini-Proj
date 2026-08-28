PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------
CREATE TABLE COUNTRIES (
    CountryID     INTEGER PRIMARY KEY AUTOINCREMENT,
    CountryName   TEXT NOT NULL UNIQUE,
    Region        TEXT
);

-- ---------------------------------------------------------
CREATE TABLE CATEGORIES (
    CategoryID        INTEGER PRIMARY KEY AUTOINCREMENT,
    CategoryName      TEXT NOT NULL,
    SubCategoryName   TEXT
);

-- ---------------------------------------------------------
CREATE TABLE CUSTOMERS (
    CustomerID             INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerName           TEXT NOT NULL,
    Gender                  TEXT,
    Age                      INTEGER,
    CustomerSegment          TEXT,
    CountryID                 INTEGER,
    AccountCreationDate        DATE,
    CustomerLoyaltyScore        REAL,
    FOREIGN KEY (CountryID) REFERENCES COUNTRIES(CountryID)
);

-- ---------------------------------------------------------
CREATE TABLE PRODUCTS (
    ProductID             INTEGER PRIMARY KEY AUTOINCREMENT,
    ProductName            TEXT NOT NULL,
    CategoryID               INTEGER,
    Brand                     TEXT,
    ProductRatingAvg           REAL,
    ProductReviewsCount          INTEGER,
    StockQuantity                  INTEGER,
    FOREIGN KEY (CategoryID) REFERENCES CATEGORIES(CategoryID)
);

-- ---------------------------------------------------------
CREATE TABLE ORDERS (
    OrderID           INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerID          INTEGER NOT NULL,
    OrderDate             DATE NOT NULL,
    OrderStatus             TEXT,
    OrderPriority             TEXT,
    CampaignSource              TEXT,
    CouponCode                    TEXT,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID)
);

-- ---------------------------------------------------------
CREATE TABLE ORDERITEMS (
    OrderItemID          INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID                INTEGER NOT NULL,
    ProductID                INTEGER NOT NULL,
    Quantity                   INTEGER NOT NULL,
    UnitPriceUSD                 REAL,
    DiscountPercent                REAL,
    DiscountAmountUSD                REAL,
    CostUSD                            REAL,
    TaxUSD                                REAL,
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);

-- ---------------------------------------------------------
-- Orders : Payments is one-to-many (supports installment plans)
CREATE TABLE PAYMENTS (
    PaymentID          INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID               INTEGER NOT NULL,
    PaymentMethod           TEXT,
    PaymentStatus              TEXT,
    InstallmentPlan               TEXT,
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID)
);

-- ---------------------------------------------------------
-- Orders : Shipments is one-to-many (supports split shipments)
CREATE TABLE SHIPMENTS (
    ShipmentID          INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID                INTEGER NOT NULL,
    ShippingMethod            TEXT,
    ShippingCostUSD              REAL,
    DeliveryDays                   INTEGER,
    ShippingCountryID                INTEGER,
    WarehouseLocation                  TEXT,
    DeliveryStatus                       TEXT,
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (ShippingCountryID) REFERENCES COUNTRIES(CountryID)
);

-- ---------------------------------------------------------
CREATE TABLE REVIEWS (
    ReviewID          INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderItemID          INTEGER NOT NULL,
    Rating                  INTEGER,
    ReviewSentiment           TEXT,
    CustomerFeedback            TEXT,
    FOREIGN KEY (OrderItemID) REFERENCES ORDERITEMS(OrderItemID)
);

-- ---------------------------------------------------------
CREATE TABLE SESSIONS (
    SessionID           INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerID             INTEGER NOT NULL,
    OrderID                   INTEGER,       -- nullable: session may not convert
    DeviceType                  TEXT,
    TrafficSource                  TEXT,
    SessionDurationMinutes           INTEGER,
    PagesVisited                        INTEGER,
    AbandonedCartBefore                    INTEGER,  -- boolean: 0/1
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID)
);

-- Indexes — foreign keys + common filter/search columns

CREATE INDEX idx_customers_country_id      ON CUSTOMERS(CountryID);
CREATE INDEX idx_customers_segment         ON CUSTOMERS(CustomerSegment);
CREATE INDEX idx_products_category_id      ON PRODUCTS(CategoryID);
CREATE INDEX idx_products_brand            ON PRODUCTS(Brand);
CREATE INDEX idx_products_name             ON PRODUCTS(ProductName);
CREATE INDEX idx_orders_customer_id        ON ORDERS(CustomerID);
CREATE INDEX idx_orders_order_date         ON ORDERS(OrderDate);
CREATE INDEX idx_orders_order_status       ON ORDERS(OrderStatus);
CREATE INDEX idx_orderitems_order_id       ON ORDERITEMS(OrderID);
CREATE INDEX idx_orderitems_product_id     ON ORDERITEMS(ProductID);
CREATE INDEX idx_payments_order_id         ON PAYMENTS(OrderID);
CREATE INDEX idx_shipments_order_id        ON SHIPMENTS(OrderID);
CREATE INDEX idx_shipments_country_id      ON SHIPMENTS(ShippingCountryID);
CREATE INDEX idx_shipments_delivery_status ON SHIPMENTS(DeliveryStatus);
CREATE INDEX idx_reviews_orderitem_id      ON REVIEWS(OrderItemID);
CREATE INDEX idx_reviews_rating            ON REVIEWS(Rating);
CREATE INDEX idx_sessions_customer_id      ON SESSIONS(CustomerID);
CREATE INDEX idx_sessions_order_id         ON SESSIONS(OrderID);
