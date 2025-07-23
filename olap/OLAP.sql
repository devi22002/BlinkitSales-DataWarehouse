-- 1. ROLL UP
--- 1.1 Total Pembelian
USE Blinkit_Source_DB;
GO
SELECT TOP 25
    dc.CustomerName,       -- Nama Pelanggan
    SUM(fs.NetRevenue) AS TotalNetPurchase -- Total Pendapatan Bersih dari semua pembelian pelanggan
FROM
    FactSales fs
JOIN DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
WHERE
    dc.CustomerKey != -1 
GROUP BY
    dc.CustomerName
ORDER BY
    TotalNetPurchase DESC;
GO

--- 1.2 Agregasi pesanan berdasarkan status pengiriman
USE Blinkit_Source_DB;
GO
SELECT
    dd.DeliveryStatus,
    COUNT(fs.OrderKey) AS TotalOrders,
    AVG(dd.DeliveryTimeMinutes) AS AverageDeliveryTime,
    AVG(dd.DeliveryRating) AS AverageDeliveryRating
FROM
    FactSales fs
JOIN DimDelivery dd ON fs.DeliveryKey = dd.DeliveryKey
WHERE
    fs.DeliveryKey != -1 -- Mengabaikan data yang tidak memiliki informasi pengiriman
GROUP BY
    dd.DeliveryStatus
ORDER BY
    TotalOrders DESC;
GO



-- 2. DRILL DOWN
--- 2.1 Data pembelian tahunan ke tingkat bulanan
USE Blinkit_Source_DB;
GO
SELECT TOP 25
    dc.CustomerName,       -- Nama Pelanggan
    dd.Year,               -- Tahun pembelian
    dd.MonthName,          -- Bulan pembelian (detail lebih rendah)
    SUM(fs.NetRevenue) AS MonthlyNetPurchase -- Total Pendapatan Bersih pelanggan per bulan
FROM
    FactSales fs
JOIN DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
JOIN DimDate dd ON fs.DateKey = dd.DateKey
WHERE
    dc.CustomerKey != -1 -- Kecualikan pelanggan 'Unknown'
    AND dd.Year = 2023   --  Pilih tahun tertentu untuk di-drill-down 
GROUP BY
    dc.CustomerName, dd.Year, dd.MonthName, dd.MonthNumberOfYear
ORDER BY
    dc.CustomerName, dd.Year, dd.MonthNumberOfYear;
GO

--- 2.2 Pendapatan setiap merk berdasarkan kategori
USE Blinkit_Source_DB;
GO
SELECT
    dp.Category,
    dp.Brand,
    SUM(fs.NetRevenue) AS TotalRevenue
FROM
    FactSales fs
JOIN DimProduct dp ON fs.ProductKey = dp.ProductKey
WHERE
    -- Memfokuskan analisis pada satu kategori untuk di-drill-down
    dp.Category = 'Dairy & Breakfast'
GROUP BY
    dp.Category,
    dp.Brand
ORDER BY
    TotalRevenue DESC;



-- 3. SLICE
--- 3.1 Mengambil data pembelian pelanggan di area Orai
USE Blinkit_Source_DB;
GO
SELECT
    dc.CustomerName,       -- Nama Pelanggan
    dc.Area AS CustomerArea, -- Area Pelanggan (dimensi yang difilter)
    SUM(fs.NetRevenue) AS TotalNetPurchase -- Total Pendapatan Bersih dari pelanggan di area ini
FROM
    FactSales fs
JOIN DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
WHERE
    dc.Area = 'Orai'
    AND dc.CustomerKey != -1 
GROUP BY
    dc.CustomerName, dc.Area
ORDER BY
    TotalNetPurchase DESC;
GO

--- 3.2 Mengambil data pembelian berdasarkan metode pembayaran Card
USE Blinkit_Source_DB;
GO
SELECT
    do.PaymentMethod,
    COUNT(DISTINCT fs.CustomerKey) AS TotalUniqueCustomers,
    SUM(fs.NetRevenue) AS TotalRevenueFromCard,
    AVG(fs.NetRevenue) AS AverageTransactionValue
FROM
    FactSales fs
JOIN DimOrder do ON fs.OrderKey = do.OrderKey
WHERE
    do.PaymentMethod = 'Card'
GROUP BY
    do.PaymentMethod;
GO



-- 4. DICE
--- 4.1 Mengambil data pembelian pelanggan di area Orai dan menggunakan Cash sebagai metode pembayaran Cash
USE Blinkit_Source_DB;
GO
SELECT  	
    dc.CustomerName,           
    dc.Area AS CustomerArea,   
    dd.Year,                   
    do.PaymentMethod,          
    SUM(fs.NetRevenue) AS TotalNetPurchase -- Total Pendapatan Bersih dari pelanggan di area Orai dengan metode pembayaran Cash
FROM
    FactSales fs
JOIN DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
JOIN DimDate dd ON fs.DateKey = dd.DateKey
JOIN DimOrder do ON fs.OrderKey = do.OrderKey -- Bergabung dengan DimOrder untuk filter Metode Pembayaran
WHERE
    dc.Area = 'Orai' 
    AND dd.Year = 2024   
    AND do.PaymentMethod = 'Cash' 
    AND dc.CustomerKey != -1 
GROUP BY
    dc.CustomerName, dc.Area, dd.Year, do.PaymentMethod
ORDER BY
    TotalNetPurchase DESC;
GO

--- 4.2 Mengambil data pembelian pelanggan di area Orai dengan metode pembayaran Card pada tahun 2024
USE Blinkit_Source_DB;
GO
-- CTE untuk menyiapkan data yang telah di-filter (di-dice) dari beberapa dimensi.
WITH OraiCardUsers2024 AS (
    SELECT
        fs.CustomerKey,
        fs.NetRevenue,
        dc.Area,
        d.Year,
        do.PaymentMethod
    FROM
        FactSales AS fs
    -- Menggabungkan semua dimensi yang dibutuhkan untuk filter.
    JOIN
        DimOrder AS do ON fs.OrderKey = do.OrderKey
    JOIN
        DimCustomer AS dc ON fs.CustomerKey = dc.CustomerKey
    JOIN
        DimDate AS d ON fs.DateKey = d.DateKey
    WHERE
        -- Kondisi filter dari 3 dimensi berbeda (Dice).
        do.PaymentMethod = 'Card'
        AND dc.Area = 'Orai'
        AND d.Year = 2024
)
-- agregasi pada sub-kubus data yang sudah spesifik.
SELECT
    ocu.Area,
    ocu.Year,
    ocu.PaymentMethod,
    COUNT(DISTINCT ocu.CustomerKey) AS TotalUniqueCustomers,
    SUM(ocu.NetRevenue) AS TotalRevenue,
    AVG(ocu.NetRevenue) AS AverageTransactionValue
FROM
    OraiCardUsers2024 AS ocu
GROUP BY
    ocu.Area,
    ocu.Year,
    ocu.PaymentMethod;
GO



-- 5. PIVOT
--- 5.1 Data penjualan per tahun    
USE Blinkit_Source_DB;
GO
SELECT
    dd.MonthName,           -- Bulan Pembelian
    SUM(CASE WHEN dd.Year = 2023 THEN fs.NetRevenue ELSE 0 END) AS Purchase2023, -- Pembelian di tahun 2023
    SUM(CASE WHEN dd.Year = 2024 THEN fs.NetRevenue ELSE 0 END) AS Purchase2024, -- Pembelian di tahun 2024
    SUM(fs.NetRevenue) AS TotalMonthlyPurchase -- Total Pembelian Bulan Ini (semua tahun dan semua pelanggan)
FROM
    FactSales fs
JOIN DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
JOIN DimDate dd ON fs.DateKey = dd.DateKey
WHERE
    dc.CustomerKey != -1
    AND dd.Year IN (2023, 2024)
GROUP BY
    dd.MonthName, dd.MonthNumberOfYear -- Mengelompokkan hanya berdasarkan Bulan
ORDER BY
    dd.MonthNumberOfYear;
GO



-- 6. Ranking
--- 6.1 Ranking pendapatan per kategori produk
USE Blinkit_Source_DB;
GO
SELECT TOP 10
    dp.Category,
    SUM(fs.NetRevenue) AS TotalNetRevenue,
    SUM(fs.Quantity) AS TotalQuantitySold
FROM
    FactSales fs
JOIN DimProduct dp ON fs.ProductKey = dp.ProductKey
WHERE
    dp.ProductKey != -1
GROUP BY
    dp.Category
ORDER BY
    TotalNetRevenue DESC;
GO
