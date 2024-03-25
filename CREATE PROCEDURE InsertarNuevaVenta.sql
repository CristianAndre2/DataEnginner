DELIMITER //

DROP PROCEDURE IF EXISTS InsertarNuevaVenta;

CREATE PROCEDURE InsertarNuevaVenta(
    IN p_FechaVenta DATE,
    IN p_ClientelD INT,
    IN p_ProductolD INT,
    IN p_Cantidad INT,
    IN p_PrecioTotal DECIMAL(10,2)
)
BEGIN
    DECLARE cliente_saldo DECIMAL(10, 2);
    DECLARE v_NombreDia VARCHAR(20);
    DECLARE v_Dia INT;
    DECLARE v_Mes INT;
    DECLARE v_Año INT;

    -- Obtener el nombre del día de la semana
    SET v_NombreDia = DAYNAME(p_FechaVenta);
    -- Obtener el día, mes y año
    SET v_Dia = DAY(p_FechaVenta);
    SET v_Mes = MONTH(p_FechaVenta);
    SET v_Año = YEAR(p_FechaVenta);
    
   
	-- Insertar en la tabla Tiempo, si la fechaVenta ya exixte en la tabla no la guarda, en tiempo
	-- el trigger after_insert_venta se encarga de manejar la tabla de auditoria.
	INSERT INTO Tiempo (FechaVenta, Día, Mes, Año, DíaSemana)
    SELECT p_FechaVenta, v_Dia, v_Mes, v_Año, v_NombreDia
    FROM dual
    WHERE NOT EXISTS (
        SELECT 1 FROM Tiempo WHERE FechaVenta = p_FechaVenta
    );
            
    -- Insertar la nueva venta en la tabla de hechos (Ventas)
     INSERT INTO Ventas (FechaVenta, ClientelD, ProductolD, Cantidad, Precio)
     VALUES (p_FechaVenta, p_ClientelD, p_ProductolD, p_Cantidad, p_PrecioTotal);
  
    -- Actualizar el stock en la tabla de productos
    UPDATE Productos
    SET Stock = Stock - p_Cantidad
    WHERE ProductolD = p_ProductolD;

    -- Obtener el saldo actual del cliente
    -- SELECT Saldo INTO cliente_saldo
    -- FROM Clientes
    -- WHERE ClientelD = p_ClientelD;
    
    -- Actualizar el saldo en la tabla de clientes para el cliente
    -- UPDATE Clientes
    -- SET Saldo = cliente_saldo - p_PrecioTotal
   --  WHERE ClientelD = p_ClientelD;
    
    -- Actualizar el saldo en la tabla de clientes para el cliente NUEVO
    UPDATE Clientes
    SET Saldo = Saldo + p_PrecioTotal * p_Cantidad -- original era Saldo - p_PrecioTotal
    WHERE ClientelD = p_ClientelD;
    
END;
//
    
DELIMITER ;
--                       (FechaVenta, ClientelD, ProductolD, Cantidad, Precio)
-- ejecute antes el query Trigger audi para q este listo 
CALL InsertarNuevaVenta('2024-03-23', 1, 1, 2, 50.00);
CALL InsertarNuevaVenta('2024-03-22', 2, 2, 1, 30.00);
CALL InsertarNuevaVenta('2024-03-24', 3, 3, 4, 60.00);
CALL InsertarNuevaVenta('2024-03-21', 3, 3, 3, 20.00);

select * from ventas; 
Select * from Clientes; 
Select * from Auditoria;

