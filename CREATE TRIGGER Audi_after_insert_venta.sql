DELIMITER //
-- drop trigger Audi_after_insert_venta;
-- este es el paso 3
CREATE TRIGGER Audi_after_insert_venta
AFTER INSERT ON Ventas
FOR EACH ROW
BEGIN
    -- Verificar si el cliente ya existe en la tabla de auditoría
    IF EXISTS (SELECT 1 FROM Auditoria WHERE ClienteID = NEW.ClientelD) THEN
        -- Actualizar el saldo del cliente en la tabla de auditoría
        UPDATE Auditoria
        SET Saldo = Saldo + NEW.Total
        WHERE ClienteID = NEW.ClientelD;
    ELSE
        -- Insertar un nuevo registro para el cliente en la tabla de auditoría
        INSERT INTO Auditoria (ClienteID, NombreCliente, Saldo)
        VALUES (NEW.ClientelD, (SELECT NombreCliente FROM Clientes WHERE ClientelD = NEW.ClientelD), -NEW.Total);
    END IF;
END;
//

DELIMITER ;



