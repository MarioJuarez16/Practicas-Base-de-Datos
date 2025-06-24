-- Crear base de datos y copiar tablas
CREATE DATABASE practicaPE;
USE practicaPE;

SELECT * INTO SalesOrderHeader
FROM AdventureWorks2022.sales.SalesOrderHeader;

SELECT * INTO SalesOrderDetail
FROM AdventureWorks2022.sales.SalesOrderDetail;

SELECT * INTO Customer
FROM AdventureWorks2022.sales.Customer;

SELECT * INTO SalesTerritory
FROM AdventureWorks2022.sales.SalesTerritory;

SELECT * INTO Product
FROM AdventureWorks2022.Production.Product;

SELECT * INTO ProductCategory
FROM AdventureWorks2022.Production.ProductCategory;

SELECT * INTO ProductSubcategory
FROM AdventureWorks2022.Production.ProductSubcategory;

SELECT BusinessEntityID, FirstName, LastName INTO Person
FROM AdventureWorks2022.Person.Person;

-------------------------------------------------------------------------
-- PRACTICA 2. PUNTO 1
USE AdventureWorks2022;
GO

WITH ProductoVentas AS (
    SELECT 
        c.Name AS Categoria,
        p.Name AS Producto,
        SUM(sod.OrderQty) AS TotalVendido
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory c ON psc.ProductCategoryID = c.ProductCategoryID
    GROUP BY c.Name, p.Name
),
MaxVentasPorCategoria AS (
    SELECT 
        Categoria,
        MAX(TotalVendido) AS MaxVendido
    FROM ProductoVentas
    GROUP BY Categoria
)
SELECT 
    pv.Categoria,
    pv.Producto,
    pv.TotalVendido
FROM ProductoVentas pv
JOIN MaxVentasPorCategoria mv
    ON pv.Categoria = mv.Categoria 
    AND pv.TotalVendido = mv.MaxVendido
ORDER BY pv.Categoria;

USE practicaPE;
GO

CREATE NONCLUSTERED INDEX SOD_CoveringQuery
ON SalesOrderDetail(ProductID)
INCLUDE (OrderQty);

WITH ProductoVentas AS (
    SELECT 
        c.Name AS Categoria,
        p.Name AS Producto,
        SUM(sod.OrderQty) AS TotalVendido
    FROM SalesOrderDetail sod
    JOIN Product p ON sod.ProductID = p.ProductID
    JOIN ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN ProductCategory c ON psc.ProductCategoryID = c.ProductCategoryID
    GROUP BY c.Name, p.Name
),
MaxVentasPorCategoria AS (
    SELECT 
        Categoria,
        MAX(TotalVendido) AS MaxVendido
    FROM ProductoVentas
    GROUP BY Categoria
)
SELECT 
    pv.Categoria,
    pv.Producto,
    pv.TotalVendido
FROM ProductoVentas pv
JOIN MaxVentasPorCategoria mv
    ON pv.Categoria = mv.Categoria 
    AND pv.TotalVendido = mv.MaxVendido
ORDER BY pv.Categoria;

-------------------------------------------------------------------------
-- PRACTICA 2. PUNTO 2
WITH Customer_Orders AS (
    SELECT 
        soh.SalesOrderID, 
        c.CustomerID, 
        soh.TerritoryID, 
        p.FirstName,  
        p.LastName
    FROM SalesOrderHeader soh
    JOIN Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person p ON c.PersonID = p.BusinessEntityID
),
OrdenesPorCliente AS (
    SELECT 
        TerritoryID, 
        CustomerID, 
        FirstName,  
        LastName, 
        COUNT(*) AS Orders
    FROM Customer_Orders
    GROUP BY TerritoryID, CustomerID, FirstName, LastName
),
MaxOrdenesPorTerritorio AS (
    SELECT 
        TerritoryID, 
        MAX(Orders) AS MaxOrders
    FROM OrdenesPorCliente
    GROUP BY TerritoryID
)
SELECT 
    o.TerritoryID, 
    o.FirstName,  
    o.LastName, 
    o.Orders
FROM OrdenesPorCliente o
JOIN MaxOrdenesPorTerritorio m
    ON o.TerritoryID = m.TerritoryID 
    AND o.Orders = m.MaxOrders
ORDER BY o.TerritoryID;

-------------------------------------------------------------------------
-- PRACTICA 2. PUNTO 3
USE AdventureWorks2022;
GO

SELECT DISTINCT SalesOrderID
FROM Sales.SalesOrderDetail AS OD
WHERE NOT EXISTS (
    SELECT *
    FROM (
        SELECT ProductID
        FROM Sales.SalesOrderDetail 
        WHERE SalesOrderID = 43676
    ) AS P
    WHERE NOT EXISTS (
        SELECT *
        FROM Sales.SalesOrderDetail AS OD2
        WHERE OD.SalesOrderID = OD2.SalesOrderID
        AND OD2.ProductID = P.ProductID
    )
);

USE practicaPE;
GO

CREATE NONCLUSTERED INDEX IDX_SalesOrderDetail_SalesOrder_Product
ON SalesOrderDetail (SalesOrderID, ProductID);

SELECT DISTINCT SalesOrderID
FROM SalesOrderDetail AS OD
WHERE NOT EXISTS (
    SELECT *
    FROM (
        SELECT ProductID
        FROM SalesOrderDetail 
        WHERE SalesOrderID = 43676
    ) AS P
    WHERE NOT EXISTS (
        SELECT *
        FROM SalesOrderDetail AS OD2
        WHERE OD.SalesOrderID = OD2.SalesOrderID
        AND OD2.ProductID = P.ProductID
    )
);
