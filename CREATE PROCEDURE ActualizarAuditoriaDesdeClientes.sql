DELIMITER //
-- se trasladan los saldos iniciales al momento de la migracion, despues de esto el trigger Audi_after_insert_venta actualizara los saldos
-- el SP_Registro_Ventas 2 por cada venta ingresa el registro a la tabla auditoria y actualiza el Stock en Productos y el Saldo en Clientes
CREATE PROCEDURE ActualizarAuditoriaDesdeClientes()
BEGIN
	DECLARE v_Existencia INT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_ClienteID INT;
    DECLARE v_NombreCliente VARCHAR(100);
    DECLARE v_Saldo DECIMAL(10, 2);
    DECLARE cur CURSOR FOR SELECT ClientelD, NombreCliente, Saldo FROM Clientes;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_ClienteID, v_NombreCliente, v_Saldo;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Verificar si el ClienteID ya existe en la tabla Auditoria
       
        SELECT COUNT(*) INTO v_Existencia FROM Auditoria WHERE ClienteID = v_ClienteID;

        IF v_Existencia > 0 THEN
            -- Actualizar el registro existente en la tabla Auditoria
            UPDATE Auditoria
            SET NombreCliente = v_NombreCliente,
                Saldo = v_Saldo
            WHERE ClienteID = v_ClienteID;
        ELSE
            -- Insertar un nuevo registro en la tabla Auditoria
            INSERT INTO Auditoria (ClienteID, NombreCliente, Saldo)
            VALUES (v_ClienteID, v_NombreCliente, v_Saldo);
        END IF;
    END LOOP;
    CLOSE cur;
END;
//

DELIMITER ;
CALL InsertarNuevaVenta('2024-03-21', 3, 3, 3, 20.00);

call ActualizarAuditoriaDesdeClientes;
select * from ventas;
select *from clientes;
select * from auditoria;
