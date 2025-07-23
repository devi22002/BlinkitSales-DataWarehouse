<h1 align="center">
    BlinkitSales
</h1>
<h3 align="center"> 
    Data Warehouse Study Case  
</h3>

## 📌 Project Description
This repository contains a final project for the **Data Warehouse course**, completed in one month. The project simulates the design of a sales data warehouse system for an e-commerce platform using the **Blinkit Sales Dataset** from Kaggle (CSV format).

We used **SQL Server Management Studio (SSMS)** to perform the full **ETL process**, structure the data into a **star schema**, and run **OLAP queries** for business analysis. The final result is an interactive **Power BI dashboard** that presents insights such as revenue trends, order volume, top areas, and payment method comparisons.

This project showcases practical skills in ETL, OLAP, data modeling, and building an interactive analytical dashboard using real-world data and industry-standard tools.

## 📦 Dataset
The dataset used is from Kaggle: [Blinkit Sales Dataset](https://www.kaggle.com/datasets/akxiit/blinkit-sales-dataset).  
It represents daily essential sales data from an online platform, including information about:
- Products
- Customers
- Orders
- Deliveries
- Customer feedback

Each transaction includes order details, shipping info, item pricing, and service reviews, all of which serve as the foundation for building the Data Warehouse to support business analysis and strategic decision-making.

## ⚙️ ETL Process
The ETL (Extract, Transform, Load) process is used to transform raw data into structured formats that follow the star schema. The stages include:
- **Extract:** Load data from raw sources
- **Transform:** Clean and format data according to schema definitions
- **Load:** Insert data into Data Warehouse tables

💡 You can run the `ETL.sql` script using a compatible SQL engine such as SQL Server Management Studio, based on the schema defined in `table-definitions.sql`.

## 📊 OLAP

- OLAP queries are written in `OLAP.sql` to extract business insights from the warehouse.
- The final dashboard is built using **Microsoft Power BI**, connected to the OLAP results for interactive reporting.

## 📌 Final Outcome

The key deliverable of this project is an interactive **sales analysis dashboard** that features:
- Insights into revenue trends across years and product categories
- Comparative analysis of payment methods and customer behavior
- Visual breakdown of high-performing regions and average purchase metrics
- Easy-to-use filters for time-based exploration (Year, Month)

📄 View Full Report [(PDF)](https://drive.google.com/file/d/1PkEzEc1yXYowtCZz6zqvbPwn-uXtl5n1/view?usp=sharing) 

## 👥 Project Team
This project was developed by:

- 140810220001 - Nadia Mulyadi [@nmulis](https://github.com/nmulis)
- 140810220015 - Devi Humaira [@devi22002](https://github.com/devi22002)
- 140810220029 - Reghina Maisarah [@reghina22001](https://github.com/reghina22001)
- 140810220071 - Nabila Rahmanisa Putri Arzetta [@nabilarahmansiaputriarzetta](https://github.com/nabilarahmansiaputriarzetta)
