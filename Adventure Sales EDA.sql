Create Database Adventure_Works;
Use Adventure_Works;

-- Database Exploration --

-- Exploring all the Objects in the Database 
Select * From INFORMATION_SCHEMA.TABLES;

-- Exploring all the columns in the Database Tables
Select * from Sales;
Select * From Customers;
Select * From Categories;
Select * From Products;
Select * From Products_SubCategories;
Select * From Sales_Returns;
Select * From Territory;


-- Dimensions Exploration --

-- Exploring all Regions the customers come from
Select Distinct Region From Territory; 

-- Exploring all Countries the customers come from
Select Distinct Country From Territory; 

-- Exploring all Continents the customers come from
Select Distinct Continent From Territory; 

-- Exploring all categories "The major divisions" 
Select Distinct CategoryName From Categories;

-- Exploring all Product SubCategories "The major divisions" 
Select Distinct SubCategoryName From Products_Subcategories;

-- Exploring all Product "The major divisions" 
Select Distinct ProductName From Products;


---- Date Exploration ----

-- Finding the date of the first and last order
-- And Order Range in Years and Months
Select MIN(OrderDate) First_Order_Date,
	   MAX(OrderDate) Last_Order_Date,
	   DATEDIFF(YEAR, MIN(OrderDate), MAX(OrderDate)) Orders_Year_Range,
	   DATEDIFF(MONTH, MIN(OrderDate), MAX(OrderDate)) Orders_Year_Range
From Sales;

-- Finding Youngest and oldest customers --
Select MIN(BirthDate) Oldest_DOB,
	   DATEDIFF(YEAR, MIN(BirthDate), GETDATE()) Oldest_Customer,
	   MAX(BirthDate) Youngest_Customer,
	   DATEDIFF(YEAR, MAX(BirthDate), GETDATE()) Youngest_Customer
From Customers;


---- Measures Exploration ----

-- Find the total Sales
Select SUM(S.OrderQuantity * P.ProductPrice) Total_Sales
From Sales S
Inner Join Products P
On P.ProductKey = S.ProductKey;

-- Find the total quantity were sold
Select SUM(OrderQuantity) Total_Qty_Sold
From Sales;

-- Find the total profit from sales
Select SUM(S.OrderQuantity * P.Profit) Total_Profit
From Sales S
Inner Join Products P
On P.ProductKey = S.ProductKey;

-- Find the total quantity were Returned
Select SUM(ReturnQuantity) Total_Qty_Returned
From Sales_Returns;

-- Find the average product price
Select AVG(ProductPrice) Avg_Price 
From Products;

-- Find the total number of orders
Select COUNT(Distinct OrderNumber) Total_Orders
From Sales;

-- Find the total number of products
Select COUNT(*) Total_Products From Products;

-- Find the total number of customers
Select COUNT(CustomerKey) Total_Customers From Customers;

-- Find the total number of customers placed an order
Select COUNT(Distinct CustomerKey) Total_Cust_Placed_Orders From Sales;



-- Generating a report that shows all the key metrics of the business --
Select 'Total Sales' as Measure_Name, SUM(S.OrderQuantity * P.ProductPrice) as Measure_Value
From Sales S
Inner Join Products P
On P.ProductKey = S.ProductKey
UNION ALL
Select 'Total Quantity Sold' as Measure_Name, SUM(OrderQuantity) as Measure_Value From Sales
UNION ALL
Select 'Total Profit' as Measure_Name, SUM(S.OrderQuantity * P.Profit) as Measure_Value From Sales S
Inner Join Products P
On P.ProductKey = S.ProductKey
UNION ALL
Select 'Total Return Quantity' as Measure_Name, SUM(ReturnQuantity) as Measure_Value From Sales_Returns
UNION ALL
Select 'Avg Product Price' as Measure_Name, AVG(ProductPrice) as Measure_Value From Products
UNION ALL
Select 'Total No Of Orders' as Measure_Name, COUNT(Distinct OrderNumber) as Measure_Value From Sales
UNION ALL
Select 'Total No Of Products' as Measure_Name, COUNT(Distinct ProductKey) as Measure_Value From Products
UNION ALL
Select 'Total No Of Customers' as Measure_Name, COUNT(CustomerKey) as Measure_Value From Customers
UNION ALL
Select 'Total No Of Customers Orders Placed' as Measure_Name, COUNT(Distinct CustomerKey) as Measure_Value From Sales;


-- Magnitude Analysis --

-- Find total customers by countries
Select T.Country, 
	   Count(Distinct C.CustomerKey) Total_Customers
From Territory T
Inner Join Sales S
On S.TerritoryKey = T.SalesTerritoryKey
Inner Join Customers C
On C.CustomerKey = S.CustomerKey
Group by T.Country
Union All 
-- Customers count who did not placed an order --
Select 'Others' as Country,
		COUNT(CustomerKey) Total_Customers 
From 
	(Select C.CustomerKey, COUNT(S.CustomerKey) Total_Customers From Customers C
	Left Join Sales S
	On S.CustomerKey = C.CustomerKey
	Group by C.CustomerKey)t
	where Total_Customers = 0

-- Find total customers by gender
Select Gender, 
	   COUNT(*) Customers_Cnt 
From Customers
Group By Gender;

-- Find total products by category
Select C.CategoryName, 
	   SUM(S.OrderQuantity) Qty_Sold
From Categories C
Inner Join Products_Subcategories PS
On PS.ProductCategoryKey = C.ProductCategoryKey
Inner Join Products P
On P.ProductSubcategoryKey = PS.ProductSubcategoryKey
Inner Join Sales S
On S.ProductKey = P.ProductKey
Group By C.CategoryName
Order By SUM(S.OrderQuantity) Desc;

-- What is the average cost in each category?
Select C.CategoryName, 
	   AVG(P.ProductPrice) Avg_Price
From Categories C
Inner Join Products_Subcategories PS
On PS.ProductCategoryKey = C.ProductCategoryKey
Inner Join Products P
On P.ProductSubcategoryKey = PS.ProductSubcategoryKey
Group By C.CategoryName
Order By AVG(P.ProductPrice) Desc;

-- What is the total revenue generated by each category?
Select C.CategoryName, 
	   SUM(S.OrderQuantity * P.ProductPrice) Category_Reveune
From Categories C
Inner Join Products_Subcategories PS
On PS.ProductCategoryKey = C.ProductCategoryKey
Inner Join Products P
On P.ProductSubcategoryKey = PS.ProductSubcategoryKey
Left Join Sales S
On S.ProductKey = P.ProductKey
Group By C.CategoryName;


-- What is the total revenue generated by each customer?
Select C.CustomerKey, 
	   CONCAT_WS(' ', C.FirstName, C.LastName) FullName, 
	   SUM(S.OrderQuantity * P.ProductPrice) Customer_Wise_Reveune 
From Customers C
Left Join Sales S
On S.CustomerKey = C.CustomerKey
Left Join Products P
On P.ProductKey = S.ProductKey
Group By C.CustomerKey, 
		 CONCAT_WS(' ', C.FirstName, C.LastName)
Order By SUM(S.OrderQuantity * P.ProductPrice) Desc;


-- Find Total Sales by Income Group 
Select 
    Case 
    When AnnualIncome < 30000 Then 'Low Income'
	When AnnualIncome Between 30000 And 60000 Then 'Middle Income'
    Else 'High Income'
    End As IncomeGroup,
    SUM(S.OrderQuantity) AS TotalSales
From Sales S
Join Customers C 
On S.CustomerKey = C.CustomerKey
Group By 
    Case 
    When AnnualIncome < 30000 Then 'Low Income'
	When AnnualIncome Between 30000 And 60000 Then 'Middle Income'
    Else 'High Income'
    End;

-- What is the distribution of items sold across countries?
Select T.Country, 
	   SUM(OrderQuantity) Qty_sold 
From Territory T
Left Join Sales S
On S.TerritoryKey = T.SalesTerritoryKey
Group By T.Country
Order By SUM(OrderQuantity) Desc;


---- Ranking Analysis ----

-- What are the top 5 performing products in terms of Quantity Sold?
With Ranked_CTE as
(
Select P.ProductKey, 
	   P.ProductName, 
	   SUM(S.OrderQuantity) Qty_Sold,
	   DENSE_RANK() Over (Order By SUM(S.OrderQuantity) Desc) Prod_Rnk
From Products P
Left Join Sales S 
On S.ProductKey = P.ProductKey
Group By P.ProductKey, 
		 P.ProductName
)
Select * From Ranked_CTE 
Where Prod_Rnk <= 5;


Select Top 5 
	   P.ProductKey, 
	   P.ProductName, 
	   SUM(S.OrderQuantity) Qty_Sold
From Products P
Left Join Sales S 
On S.ProductKey = P.ProductKey
Group By P.ProductKey, 
		 P.ProductName
Order By SUM(S.OrderQuantity) Desc;

-- What are the 5 least performing products in terms of Quantity Sold?
With Ranked_CTE as
(
Select P.ProductKey, 
	   P.ProductName, 
	   SUM(S.OrderQuantity) Qty_Sold,
	   Dense_Rank() Over (Order By SUM(S.OrderQuantity)) Prod_Rnk
From Products P
Left Join Sales S 
On S.ProductKey = P.ProductKey
Group By P.ProductKey, 
		 P.ProductName
)
Select * From Ranked_CTE 
Where Prod_Rnk <= 5;

Select Top 5 
	   P.ProductKey, 
	   P.ProductName, 
	   SUM(S.OrderQuantity) Qty_Sold
From Products P
Left Join Sales S 
On S.ProductKey = P.ProductKey
Group By P.ProductKey, 
		 P.ProductName
Order By SUM(S.OrderQuantity);

-- Find the top 10 customers who have generated the highest revenue?
With Ranked_CTE as 
(
Select C.CustomerKey, 
	   CONCAT_WS(' ', C.FirstName, C.LastName) FullName, 
	   SUM(S.OrderQuantity * P.ProductPrice) Customer_Wise_Reveune,
	   DENSE_RANK() Over(Order By SUM(S.OrderQuantity * P.ProductPrice) Desc) Cust_Rnk
From Customers C
Left Join Sales S
On S.CustomerKey = C.CustomerKey
Left Join Products P
On P.ProductKey = S.ProductKey
Group By C.CustomerKey, 
		 CONCAT_WS(' ', C.FirstName, C.LastName)
)
Select * From Ranked_CTE 
Where Cust_Rnk <= 10;

-- Find the least orders placed customers?
With Ranked_CTE as 
(
Select C.CustomerKey, 
	   CONCAT_WS(' ', C.FirstName, C.LastName) FullName, 
	   COUNT(Distinct S.OrderQuantity) Orders_Cnt,
	   DENSE_RANK() Over(Order By Count(Distinct S.OrderQuantity)) Cust_Rnk
From Customers C
Left Join Sales S
On S.CustomerKey = C.CustomerKey
Group By C.CustomerKey, 
		 CONCAT_WS(' ', C.FirstName, C.LastName)
)
Select * From Ranked_CTE 
Where Cust_Rnk <= 10;


