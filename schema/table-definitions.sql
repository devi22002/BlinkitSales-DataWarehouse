CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDateAlternateKey DATE,
    DayNumberOfWeek INT,
    DayNameOfWeek NVARCHAR(20),
    DayNumberOfMonth INT,
    DayNumberOfYear INT,
    WeekNumberOfYear INT,
    MonthName NVARCHAR(20),
    MonthNumberOfYear INT,
    Quarter INT,
    Year INT,
    IsWeekend BIT
);

CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    Category VARCHAR(100),
    Price DECIMAL(10,2),
    Brand VARCHAR(100)
);

CREATE TABLE DimOrder (
    OrderID BIGINT PRIMARY KEY,
    OrderDate DATETIME,
    PaymentMethod VARCHAR(50),
    DeliveryStatus VARCHAR(50),
    OrderTotal INT
);


CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(255),
    Email VARCHAR(255),
    Phone VARCHAR(20),
    Address VARCHAR(500),
    Area VARCHAR(100),
    Pincode INT,
    RegistrationDate DATE,
);

CREATE TABLE DimDelivery (
    DeliveryPartnerID INT PRIMARY KEY,
    DeliveryStatus VARCHAR(50),
    DeliveryTimeMinutes INT,
    DistanceKm FLOAT,
    ActualTime TIME,
    DeliveryRating INT
);

CREATE TABLE DimLocation (
    LocationID INT PRIMARY KEY,
    Area VARCHAR(100),
    Pincode INT
);

CREATE TABLE DimFeedback (
    FeedbackID NVARCHAR(50) PRIMARY KEY,
    CustomerID INT,
    OrderID BIGINT,
    FeedbackCategory NVARCHAR(100),
    Rating INT,
    FeedbackText NVARCHAR(500),
    FeedbackDate DATE,

    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (OrderID) REFERENCES DimOrder(OrderID)
);

CREATE TABLE DimMarketing (
    MarketingCampaignID INT PRIMARY KEY,
    CampaignName NVARCHAR(255),
    Channel NVARCHAR(100),
    Date DATE,
    Spend DECIMAL(18, 2),
    Impressions INT,
    Clicks INT,
    Conversions INT
);

CREATE TABLE FactSales (
    SalesID INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT,
    ProductKey INT,
    CustomerKey INT,
    OrderKey INT,
    DeliveryKey INT,
    LocationKey INT,
    FeedbackKey INT,
    MarketingKey INT,
    Quantity INT,
    UnitPrice DECIMAL(18,2),
    LineTotal AS (Quantity * UnitPrice) PERSISTED,
    NetRevenue DECIMAL(18,2),
    ProfitMargin DECIMAL(5,2),

    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (OrderKey) REFERENCES DimOrder(OrderID),
    FOREIGN KEY (DeliveryKey) REFERENCES DimDelivery(DeliveryPartner    ID),
    FOREIGN KEY (LocationKey) REFERENCES DimLocation(LocationID),
    FOREIGN KEY (FeedbackKey) REFERENCES DimFeedback(FeedbackID),
    FOREIGN KEY (MarketingKey) REFERENCES DimMarketing(MarketingCampaignID)
);
