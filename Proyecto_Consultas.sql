use AdventureWorks2019

/*Equipo 7 
Gonzalez San Juan Alexis
Alfredo Reyes Luis
Abrahah Gurriez
*/
/*
A) Determinar el total de las ventas de los productos con la categoría que se proveade argumento de entrada en la consulta,
para cada uno de los territorios registradosen la base de datos.
*/

CREATE or ALTER PROCEDURE TotalVentas @cat int
as
begin

	SELECT soh.TerritoryID, SUM(sod.lineTotal) as total_Ventas FROM  AdventureWorks2019.Sales.SalesOrderDetail sod
inner join AdventureWorks2019.Sales.SalesOrderHeader soh
ON sod.SalesOrderID = soh.SalesOrderID
WHERE sod.ProductID in (SELECT ProductID
		FROM AdventureWorks2019.Production.Product
		WHERE ProductSubcategoryID in (SELECT ProductSubcategoryID
				FROM AdventureWorks2019.Production.ProductSubcategory
				WHERE ProductCategoryID = @cat)) GROUP BY soh.TerritoryID

				end

execute TotalVentas @cat = 1

/*B) Determinar el producto más solicitado para la región (atributo group de salesterritory)y en que territorio de la región tiene mayordemanda.*/
CREATE or alter PROCEDURE TotalVentas @Territory nvarchar(50) AS
BEGIN 
SELECT
	TOP 1 SUM(Tabla.lineTotal) as total_ventas, Prod.Name as Nombre, Prod.ProductID
FROM AdventureWorks2019.Production.Product Prod
inner join(SELECT ProductID, lineTotal FROM  AdventureWorks2019.Sales.SalesOrderDetail sod
	WHERE SalesOrderID in( SELECT SalesOrderID FROM  AdventureWorks2019.Sales.SalesOrderHeader soh
		WHERE TerritoryID in( SELECT TerritoryID FROM  AdventureWorks2019.Sales.SalesTerritory st
			WHERE [Group] = @Territory))) as Tabla
	on
	Prod.ProductID = Tabla.ProductID GROUP BY Prod.Name, Prod.ProductID ORDER by
	total_ventas DESC
END
execute TotalVentas @Territory='North America'



/*C) Actualizar el stock disponible en un 5% de los productos de la categoría que se  
provea como argumento de entrada en una localidad que se provea como entrada en 
 la instrucción de actualización..
*/
/**/
CREATE or ALTER PROCEDURE ActualizarStock @loc int, @cat int
as
begin
	update AdventureWorks2019.Production.ProductInventory 
	set Quantity = Quantity*1.05 
	WHERE locationId = @loc
	and productId in (select ProductId
		FROM AdventureWorks2019.Production.Product
		WHERE ProductSubcategoryID in (SELECT productSubcategoryId
				FROM AdventureWorks2019.Production.productSubcategory
				WHERE ProductCategoryID = @cat))

				end


execute ActualizarStock @cat = 1, @loc = 1

/* D) Determinar si hay clientes que realizan ordenes en
territorios diferentes al que se encuentran. */
DECLARE @cliente int
SET @cliente = 3
SELECT distinct TerritoryID
FROM AdventureWorks2019.Sales.SalesOrderHeader
WHERE CustomerID = @cliente and TerritoryID in (SELECT TerritoryID
	FROM AdventureWorks2019.Sales.Customer
	WHERE CustomerID = @cliente)


/*e) Actualizar  la  cantidad  de  productos  de  una  orden que  se provea
como argumento en la instrucción de actualización.*/
CREATE or alter PROCEDURE sp_ActualizarCant @SALES_OID int, @SO_Cant int
AS
BEGIN
	IF EXISTS (SELECT sod.OrderQty as Cantidad_Productos, Prod.Name as Nombre_Producto, sod.SalesOrderID
	FROM  AdventureWorks2019.Sales.SalesOrderDetail sod
	inner join AdventureWorks2019.Production.Product Prod 
	on sod.ProductID = Prod.ProductID and sod.SalesOrderID = @SALES_OID) 

	update  AdventureWorks2019.Sales.SalesOrderDetail 
	set OrderQty = @SO_Cant 
	where SalesOrderID = @SALES_OID
	ELSE 
	PRINT 'NO Actualizado'
END
	
execute sp_ActualizarCant @SALES_OID = 43659, @SO_Cant = 6
/*f) Actualizar el método de envío de una orden que se reciba como argumento en la instrucción de actualización. */	
CREATE or alter PROCEDURE P_ActualizarMEnvio @SALES_OID int, @SHIP_ID int AS
BEGIN 
	IF EXISTS (SELECT MetEnv.Name as Metodo_Envio, MetEnv.ShipMethodID as ID_Metodo,
	soh.ShipMethodID as ID_Metodo_Seleccionado, soh.SalesOrderID
	FROM  AdventureWorks2019.Sales.SalesOrderHeader soh inner join AdventureWorks2019.Purchasing.ShipMethod MetEnv
	on soh.ShipMethodID = MetEnv.ShipMethodID
	where soh.SalesOrderID = @SALES_OID)


	UPDATE AdventureWorks2019.Sales.SalesOrderHeader 
	set ShipMethodID = @SHIP_ID 
	WHERE SalesOrderID = @SALES_OID
	ELSE 
		PRINT 'NO Actualizado'
END
execute P_ActualizarMEnvio @SALES_OID = 43659, @SHIP_ID = 2
/*g) Actualizar el correo electrónico de una cliente que se reciba como argumento en la instrucción de actualización. */

create or ALTER PROCEDURE P_ActualizarEmail @EmailAct nvarchar(50), @EmailNue nvarchar(50) AS 
BEGIN 
	IF EXISTS (
		SELECT Pers.FirstName as Nombre, Email.EmailAddress as Email
	FROM AdventureWorks2019.Person.Person Pers
	inner join AdventureWorks2019.Person.EmailAddress Email
	on Pers.BusinessEntityID = Email.BusinessEntityID 
	where Email.EmailAddress = @EmailAct
	)
	UPDATE AdventureWorks2019.Person.EmailAddress 
	set EmailAddress = @EmailNue  
	WHERE EmailAddress = @EmailAct
	ELSE 
		PRINT 'NO Actualizado'
	
END

execute P_ActualizarEmail @EmailAct = 'ken0@adventure-works.com', @EmailNue = 'ken0nuewvo@adventure-works.com'
	
	

/*i) Determinar paraun rango de fechas establecidas como argumento de entrada,  cual es el total de las ventasen cada una de las regiones*/
CREATE or ALTER PROCEDURE VentasTTerry @fechaEntrada date, @fechaSalida date
as
begin
SELECT TerritoryID, SUM(TotalDue) AS Total_Ventas 
FROM AdventureWorks2019.sales.SalesOrderHeader 
WHERE OrderDate BETWEEN @fechaEntrada AND @fechaSalida GROUP BY TerritoryID ORDER BY TerritoryID
END

execute VentasTTerry  @fechaEntrada = '2011-05-31', @fechaSalida = '2011-06-30'



	--correcion clase 
	CREATE or alter PROCEDURE TotalVentas @Territory nvarchar(50) AS
BEGIN 
SELECT
	TOP 1 SUM(Tabla.lineTotal) as total_ventas, Prod.Name as Nombre, Prod.ProductID
FROM AdventureWorks2019.Production.Product Prod
inner join(SELECT ProductID, lineTotal FROM  AdventureWorks2019.Sales.SalesOrderDetail sod
	WHERE SalesOrderID in( SELECT SalesOrderID FROM  AdventureWorks2019.Sales.SalesOrderHeader soh
		WHERE TerritoryID in( SELECT TerritoryID FROM  AdventureWorks2019.Sales.SalesTerritory st
			WHERE [Group] = @Territory))) as Tabla
	on
	Prod.ProductID = Tabla.ProductID GROUP BY Prod.Name, Prod.ProductID ORDER by
	total_ventas DESC
END

execute TotalVentas @Territory='North America'

