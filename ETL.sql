-- 1. Isi DimDate (Menggunakan Recursive CTE - Kode Lengkap)
USE Blinkit_Source_DB;
GO
DECLARE @StartDate DATE = '2023-03-16'; 
DECLARE @EndDate DATE = '2024-11-04';  

-- Recursive CTE untuk membuat daftar tanggal
WITH DateSequence AS
(
    -- Anchor member: Base case (the first date)
    SELECT
        @StartDate AS [Date]
    UNION ALL
    -- Recursive member: Add one day until EndDate is reached
    SELECT
        DATEADD(day, 1, [Date])
    FROM DateSequence
    WHERE DATEADD(day, 1, [Date]) <= @EndDate
)
-- Insert hasil CTE ke DimDate
INSERT INTO DimDate (
    DateKey, FullDateAlternateKey, DayNumberOfWeek, DayNameOfWeek,
    DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear, MonthName,
    MonthNumberOfYear, Quarter, Year, IsWeekend
)
SELECT
    -- DateKey: Format YYYYMMDD as INT
    CONVERT(INT, CONVERT(NVARCHAR(8), [Date], 112)),
    [Date],
    DATEPART(dw, [Date]),               -- DayNumberOfWeek
    DATENAME(dw, [Date]),               -- DayNameOfWeek
    DAY([Date]),                        -- DayNumberOfMonth
    DATEPART(dy, [Date]),               -- DayNumberOfYear
    DATEPART(wk, [Date]),               -- WeekNumberOfYear
    DATENAME(m, [Date]),                -- MonthName
    MONTH([Date]),                      -- MonthNumberOfYear
    DATEPART(qq, [Date]),               -- Quarter
    YEAR([Date]),                       -- Year
    CASE WHEN DATENAME(dw, [Date]) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END -- IsWeekend
FROM DateSequence
OPTION (MAXRECURSION 0); -- Penting: Mengizinkan rekursi tanpa batas (untuk rentang tanggal besar)
GO
PRINT 'DimDate berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimDate) AS NVARCHAR(20));
GO
-- Block 2: Isi DimProduct
USE Blinkit_Source_DB;
GO
INSERT INTO DimProduct (ProductID, ProductName, Category, Price, Brand)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.brand
FROM
    Blinkit_Source_DB.dbo.blinkit_products p;
PRINT 'DimProduct berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimProduct) AS NVARCHAR(20));
GO
-- Block 3: Isi DimCustomer
USE Blinkit_Source_DB;
GO
INSERT INTO DimCustomer (CustomerID, CustomerName, Email, Phone, Address, Area, Pincode, RegistrationDate)
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone,
    c.address,
    c.area,
    c.pincode,
    c.registration_date
FROM
    Blinkit_Source_DB.dbo.blinkit_customers c;
PRINT 'DimCustomer berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimCustomer) AS NVARCHAR(20));
GO
-- Block 4: Isi DimOrder
USE Blinkit_Source_DB;
GO
INSERT INTO DimOrder (OrderID, OrderDate, PaymentMethod, DeliveryStatus, OrderTotal)
SELECT
    o.order_id,
    o.order_date,
    o.payment_method,
    o.delivery_status,
    o.order_total
FROM
    Blinkit_Source_DB.dbo.blinkit_orders o;
PRINT 'DimOrder berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimOrder) AS NVARCHAR(20));
GO
-- Block 5: Isi DimDelivery
USE Blinkit_Source_DB;
GO
INSERT INTO DimDelivery (DeliveryPartnerID, DeliveryStatus, DeliveryTimeMinutes, DistanceKm, ActualTime, DeliveryRating)
SELECT
    dp.delivery_partner_id,
    dp.delivery_status,
    dp.delivery_time_minutes,
    dp.distance_km,
    dp.actual_time,
    CAST(cf.rating AS INT) AS DeliveryRating
FROM
    Blinkit_Source_DB.dbo.blinkit_delivery_performance dp
LEFT JOIN
    Blinkit_Source_DB.dbo.blinkit_orders o ON dp.order_id = o.order_id
LEFT JOIN
    Blinkit_Source_DB.dbo.blinkit_customer_feedback cf ON o.order_id = cf.order_id AND cf.feedback_category = 'Delivery';
PRINT 'DimDelivery berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimDelivery) AS NVARCHAR(20));
GO
-- Block 6: Isi DimLocation
USE Blinkit_Source_DB;
GO
INSERT INTO DimLocation (Area, Pincode)
SELECT DISTINCT
    Area,
    Pincode
FROM
    DimCustomer;
PRINT 'DimLocation berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimLocation) AS NVARCHAR(20));
GO
-- Block 7: Isi DimFeedback
USE Blinkit_Source_DB;
GO
INSERT INTO DimFeedback (FeedbackID, FeedbackCategory, Rating, FeedbackText, FeedbackDate)
SELECT
    CAST(cf.feedback_id AS NVARCHAR(50)),
    cf.feedback_category,
    cf.rating,
    cf.feedback_text,
    cf.feedback_date
FROM
    Blinkit_Source_DB.dbo.blinkit_customer_feedback cf;
PRINT 'DimFeedback berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimFeedback) AS NVARCHAR(20));
GO
-- Block 8: Isi DimMarketing
USE Blinkit_Source_DB;
GO
INSERT INTO DimMarketing (MarketingCampaignID, CampaignName, Channel, Date, Spend, Impressions, Clicks, Conversions)
SELECT
    mp.campaign_id,
    mp.campaign_name,
    mp.channel,
    mp.date,
    mp.spend,
    mp.impressions,
    mp.clicks,
    mp.conversions
FROM
    Blinkit_Source_DB.dbo.blinkit_marketing_performance mp;
PRINT 'DimMarketing berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM DimMarketing) AS NVARCHAR(20));
GO
-- Fact Sales
USE Blinkit_Source_DB;
GO
INSERT INTO FactSales (
    DateKey, ProductKey, CustomerKey, OrderKey, DeliveryKey, LocationKey, FeedbackKey, MarketingKey,
    Quantity, UnitPrice, LineTotal, NetRevenue, ProfitMargin
)
SELECT
    ISNULL(DD.DateKey, -1) AS DateKey,
    ISNULL(DP.ProductKey, -1) AS ProductKey,
    ISNULL(DC.CustomerKey, -1) AS CustomerKey,
    ISNULL(DO.OrderKey, -1) AS OrderKey,
    ISNULL(DDEL.DeliveryKey, -1) AS DeliveryKey,
    ISNULL(DL.LocationKey, -1) AS LocationKey,
    ISNULL(DF.FeedbackKey, -1) AS FeedbackKey,
    -1 AS MarketingKey, 
    oi.quantity,
    oi.unit_price AS UnitPrice,
    (oi.quantity * oi.unit_price) AS LineTotal,
    (oi.quantity * oi.unit_price) AS NetRevenue,
    NULL AS ProfitMargin
FROM
    Blinkit_Source_DB.dbo.blinkit_order_items oi
INNER JOIN
    Blinkit_Source_DB.dbo.blinkit_orders o ON oi.order_id = o.order_id
INNER JOIN
    Blinkit_Source_DB.dbo.blinkit_products p ON oi.product_id = p.product_id
INNER JOIN
    Blinkit_Source_DB.dbo.blinkit_customers c ON o.customer_id = c.customer_id
LEFT JOIN
    DimDate DD ON CONVERT(INT, CONVERT(NVARCHAR(8), o.order_date, 112)) = DD.DateKey
LEFT JOIN
    DimProduct DP ON oi.product_id = DP.ProductID
LEFT JOIN
    DimCustomer DC ON o.customer_id = DC.CustomerID
LEFT JOIN
    DimOrder DO ON o.order_id = DO.OrderID
LEFT JOIN
    Blinkit_Source_DB.dbo.blinkit_delivery_performance dp_src ON o.order_id = dp_src.order_id
LEFT JOIN
    DimDelivery DDEL ON dp_src.delivery_partner_id = DDEL.DeliveryPartnerID
LEFT JOIN
    DimLocation DL ON c.area = DL.Area AND c.pincode = DL.Pincode
LEFT JOIN
    Blinkit_Source_DB.dbo.blinkit_customer_feedback cf_src ON o.order_id = cf_src.order_id
LEFT JOIN
    DimFeedback DF ON CAST(cf_src.feedback_id AS NVARCHAR(50)) = DF.FeedbackID;
PRINT 'FactSales berhasil diisi. Jumlah baris: ' + CAST((SELECT COUNT(*) FROM FactSales) AS NVARCHAR(20));
GO
