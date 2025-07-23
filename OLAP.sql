--ROLL UP DATABASE Blinkit_Source_DB;
USE Blinkit_Source_DB;
GO
SELECT TOP 25
    dc.CustomerName,       -- Nama Pelanggan
    SUM(fs.NetRevenue) AS TotalNetPurchase -- Total Pendapatan Bersih dari semua pembelian pelanggan
FROM
    FactSales fs
JOIN DimCustomer dc ON fs.CustomerKey = dc.CustomerKey
WHERE
    dc.CustomerKey != -1 -- Kecualikan pelanggan 'Unknown'
GROUP BY
    dc.CustomerName
ORDER BY
    TotalNetPurchase DESC;
GO


-- Drill Down DATABASE Blinkit_Source_DB;
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


-- Slice DATABASE Blinkit_Source_DB;
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


-- Dice DATABASE Blinkit_Source_DB;
USE Blinkit_Source_DB;
GO
SELECT  	
    dc.CustomerName,           -- Nama Pelanggan
    dc.Area AS CustomerArea,   -- Area Pelanggan (filter 1)
    dd.Year,                   -- Tahun pembelian (filter 2)
    do.PaymentMethod,          -- Metode Pembayaran (filter 3)
    SUM(fs.NetRevenue) AS TotalNetPurchase -- Total Pendapatan Bersih dari pelanggan dalam kombinasi ini
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


-- Pivot DATABASE Blinkit_Source_DB;
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

