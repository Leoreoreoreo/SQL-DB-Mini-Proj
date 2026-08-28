/* ============================================================
   GLOBAL E-COMMERCE DATABASE
   SQL Server
   ============================================================ */

CREATE DATABASE GlobalECommerce;
GO

USE GlobalECommerce;
GO


/* ============================================================
   1. COUNTRIES
   ============================================================ */

CREATE TABLE Countries
(
    CountryID      INT IDENTITY(1,1) PRIMARY KEY,
    CountryName    VARCHAR(100) NOT NULL,
    Region         VARCHAR(100),

    CONSTRAINT UQ_Countries_CountryName
        UNIQUE (CountryName)
);
GO


/* ============================================================
   2. CUSTOMERS
   ============================================================ */

CREATE TABLE Customers
(
    CustomerID             VARCHAR(50) PRIMARY KEY,
    CustomerName           VARCHAR(150),
    Gender                 VARCHAR(20),
    Age                    INT,
    CustomerSegment        VARCHAR(50),
    CountryID              INT,
    AccountCreationDate    DATE,
    CustomerLoyaltyScore   DECIMAL(10,2),

    CONSTRAINT FK_Customers_Countries
        FOREIGN KEY (CountryID)
        REFERENCES Countries(CountryID),

    CONSTRAINT CK_Customers_Age
        CHECK (Age IS NULL OR Age >= 0)
);
GO


/* ============================================================
   3. CATEGORIES
   ============================================================ */

CREATE TABLE Categories
(
    CategoryID         INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName       VARCHAR(100) NOT NULL,
    SubCategoryName    VARCHAR(100),

    CONSTRAINT UQ_Categories_Category_SubCategory
        UNIQUE (CategoryName, SubCategoryName)
);
GO


/* ============================================================
   4. PRODUCTS
   ============================================================ */

CREATE TABLE Products
(
    ProductID              VARCHAR(50) PRIMARY KEY,
    ProductName            VARCHAR(200),
    CategoryID             INT,
    Brand                  VARCHAR(100),
    ProductRatingAvg       DECIMAL(3,2),
    ProductReviewsCount    INT,
    StockQuantity          INT,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT CK_Products_Rating
        CHECK
        (
            ProductRatingAvg IS NULL
            OR ProductRatingAvg BETWEEN 0 AND 5
        ),

    CONSTRAINT CK_Products_Stock
        CHECK
        (
            StockQuantity IS NULL
            OR StockQuantity >= 0
        )
);
GO


/* ============================================================
   5. ORDERS
   ============================================================ */

CREATE TABLE Orders
(
    OrderID          VARCHAR(50) PRIMARY KEY,
    CustomerID       VARCHAR(50) NOT NULL,
    OrderDate        DATETIME2,
    OrderStatus      VARCHAR(50),
    OrderPriority    VARCHAR(50),
    CampaignSource   VARCHAR(100),
    CouponCode       VARCHAR(50),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);
GO


/* ============================================================
   6. ORDER ITEMS
   ============================================================ */

CREATE TABLE OrderItems
(
    OrderItemID         BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID             VARCHAR(50) NOT NULL,
    ProductID           VARCHAR(50) NOT NULL,
    Quantity            INT NOT NULL,
    UnitPriceUSD        DECIMAL(18,2),
    DiscountPercent     DECIMAL(5,2),
    DiscountAmountUSD   DECIMAL(18,2),
    CostUSD             DECIMAL(18,2),
    TaxUSD              DECIMAL(18,2),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_OrderItems_UnitPrice
        CHECK (UnitPriceUSD IS NULL OR UnitPriceUSD >= 0),

    CONSTRAINT CK_OrderItems_DiscountPercent
        CHECK
        (
            DiscountPercent IS NULL
            OR DiscountPercent BETWEEN 0 AND 100
        )
);
GO


/* ============================================================
   7. PAYMENTS
   ============================================================ */

CREATE TABLE Payments
(
    PaymentID          BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID            VARCHAR(50) NOT NULL,
    PaymentMethod      VARCHAR(50),
    PaymentStatus      VARCHAR(50),
    InstallmentPlan    VARCHAR(100),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);
GO


/* ============================================================
   8. SHIPMENTS
   ============================================================ */

CREATE TABLE Shipments
(
    ShipmentID           BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID              VARCHAR(50) NOT NULL,
    ShippingMethod       VARCHAR(100),
    ShippingCostUSD      DECIMAL(18,2),
    DeliveryDays         INT,
    ShippingCountryID    INT,
    WarehouseLocation    VARCHAR(150),
    DeliveryStatus       VARCHAR(50),

    CONSTRAINT FK_Shipments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_Shipments_Countries
        FOREIGN KEY (ShippingCountryID)
        REFERENCES Countries(CountryID),

    CONSTRAINT CK_Shipments_ShippingCost
        CHECK
        (
            ShippingCostUSD IS NULL
            OR ShippingCostUSD >= 0
        ),

    CONSTRAINT CK_Shipments_DeliveryDays
        CHECK
        (
            DeliveryDays IS NULL
            OR DeliveryDays >= 0
        )
);
GO


/* ============================================================
   9. REVIEWS
   ============================================================ */

CREATE TABLE Reviews
(
    ReviewID             BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderItemID          BIGINT NOT NULL,
    Rating               INT,
    ReviewSentiment      VARCHAR(50),
    CustomerFeedback     VARCHAR(MAX),

    CONSTRAINT FK_Reviews_OrderItems
        FOREIGN KEY (OrderItemID)
        REFERENCES OrderItems(OrderItemID),

    CONSTRAINT CK_Reviews_Rating
        CHECK
        (
            Rating IS NULL
            OR Rating BETWEEN 1 AND 5
        )
);
GO


/* ============================================================
   10. SESSIONS
   ============================================================ */

CREATE TABLE Sessions
(
    SessionID                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerID                VARCHAR(50) NOT NULL,
    OrderID                   VARCHAR(50) NULL,
    DeviceType                VARCHAR(50),
    TrafficSource             VARCHAR(100),
    SessionDurationMinutes    DECIMAL(10,2),
    PagesVisited              INT,
    AbandonedCartBefore       BIT,

    CONSTRAINT FK_Sessions_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Sessions_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT CK_Sessions_Duration
        CHECK
        (
            SessionDurationMinutes IS NULL
            OR SessionDurationMinutes >= 0
        ),

    CONSTRAINT CK_Sessions_PagesVisited
        CHECK
        (
            PagesVisited IS NULL
            OR PagesVisited >= 0
        )
);
GO