-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-10-2023 a las 11:10:26
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `disfrazarteaqp`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `FillCodigosDisponibles` ()   BEGIN
    DECLARE counter INT DEFAULT 1;
    
    WHILE counter <= 1500 DO
        INSERT INTO codigos_disponibles (codigo_producto_codigoDisponible)
        VALUES (counter);
        
        SET counter = counter + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ActualizarDetalleVenta` (IN `p_codigo_producto` VARCHAR(20), IN `p_cantidad` FLOAT, IN `p_id` INT)   BEGIN

 declare v_nro_boleta varchar(20);
 declare v_total_venta float;

/*
ACTUALIZAR EL STOCK DEL PRODUCTO QUE SEA MODIFICADO
......
.....
.......
*/

/*
ACTULIZAR CODIGO, CANTIDAD Y TOTAL DEL ITEM MODIFICADO
*/

 UPDATE venta_detalle 
 SET codigo_producto = p_codigo_producto, 
 cantidad = p_cantidad, 
 total_venta = (p_cantidad * (select precio_venta_producto from productos where codigo_producto = p_codigo_producto))
 WHERE id = p_id;
 
 set v_nro_boleta = (select nro_boleta from venta_detalle where id = p_id);
 set v_total_venta = (select sum(total_venta) from venta_detalle where nro_boleta = v_nro_boleta);
 
 update venta_cabecera
   set total_venta = v_total_venta
 where nro_boleta = v_nro_boleta;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_eliminar_venta` (IN `p_nro_boleta` VARCHAR(8))   BEGIN

DECLARE v_codigo VARCHAR(20);
DECLARE v_cantidad FLOAT;
DECLARE done INT DEFAULT FALSE;

DECLARE cursor_i CURSOR FOR 
SELECT codigo_producto,cantidad 
FROM venta_detalle 
where CAST(nro_boleta AS CHAR CHARACTER SET utf8)  = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_i;
read_loop: LOOP
FETCH cursor_i INTO v_codigo, v_cantidad;

	IF done THEN
	  LEAVE read_loop;
	END IF;
    
    UPDATE PRODUCTOS 
       SET stock_producto = stock_producto + v_cantidad
    WHERE CAST(codigo_producto AS CHAR CHARACTER SET utf8) = CAST(v_codigo AS CHAR CHARACTER SET utf8);
    
END LOOP;
CLOSE cursor_i;

DELETE FROM VENTA_DETALLE WHERE CAST(nro_boleta AS CHAR CHARACTER SET utf8) = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;
DELETE FROM VENTA_CABECERA WHERE CAST(nro_boleta AS CHAR CHARACTER SET utf8)  = CAST(p_nro_boleta AS CHAR CHARACTER SET utf8) ;

SELECT 'Se eliminó correctamente la venta';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarCategorias` ()   BEGIN
select * from categorias;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductos` ()   SELECT
    '' as detalles,
    p.codigo_producto,
    c.nombre_categoria,
    p.nombre_producto,
    p.talla_producto,
    p.stock_producto,
    CASE
        WHEN p.precio_compra_producto = 0 THEN '-'
        ELSE p.precio_compra_producto
    END as precio_compra_producto,
    CASE
        WHEN p.precio_venta_producto = 0 THEN '-'
        ELSE p.precio_venta_producto
    END as precio_venta_producto,
    CASE
        WHEN p.precio_alquiler_estreno_producto = 0 THEN '-'
        ELSE p.precio_alquiler_estreno_producto
    END as precio_alquiler_estreno_producto,
    CASE
        WHEN p.precio_alquiler_simple_producto = 0 THEN '-'
        ELSE p.precio_alquiler_simple_producto
    END as precio_alquiler_simple_producto,
    p.modalidad,
    p.estado_producto,
    p.fecha_creacion_producto,
    '' as acciones,
    p.descripcion_producto,
    p.incluye_producto,
    p.numero_piezas_producto,
    p.precio_compra_producto,
    p.marca_producto,
    p.no_incluye_producto,
    p.utilidad_venta_producto,
    p.utilidad_alquiler_estreno_producto,
    p.utilidad_alquiler_simple_producto
    
FROM productos p
INNER JOIN categorias c ON p.id_categoria_producto = c.id_categoria
ORDER BY p.id_producto DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosMasVendidos` ()  NO SQL BEGIN

SELECT  p.codigo_producto,
        categorias.nombre_categoria,
        p.nombre_producto,
        SUM(vd.cantidad) AS cantidad,
        SUM(ROUND(vd.total_venta, 2)) AS total_venta
FROM venta_detalle vd
INNER JOIN productos p ON vd.codigo_producto = p.codigo_producto
INNER JOIN categorias ON p.id_categoria_producto = categorias.id_categoria
GROUP BY p.codigo_producto,
         categorias.nombre_categoria,
         p.nombre_producto
ORDER BY SUM(ROUND(vd.total_venta, 2)) DESC
LIMIT 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ListarProductosPocoStock` ()  NO SQL BEGIN
    SELECT p.codigo_producto,
           ca.nombre_categoria,
           p.nombre_producto,
           p.stock_producto
    FROM productos p
    INNER JOIN categorias ca ON p.id_categoria_producto = ca.id_categoria
    WHERE p.stock_producto <= p.minimo_stock_producto
    ORDER BY p.stock_producto ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerDatosDashboard` ()  NO SQL BEGIN
  DECLARE totalProductos int;
  DECLARE totalCompras float;
  DECLARE totalVentas float;
  DECLARE ganancias float;
  DECLARE productosPocoStock int;
  DECLARE ventasHoy float;

  SET totalProductos = (SELECT
      COUNT(*)
    FROM productos p);
  SET totalCompras = (SELECT
      SUM(p.precio_compra_producto)
    FROM productos p);
  
  SET totalVentas = (SELECT
      SUM(vc.total_venta)
    FROM venta_cabecera vc);
  
  SET ganancias = (SELECT
      SUM(vd.cantidad * vd.precio_unitario_venta) - SUM(vd.cantidad * vd.costo_unitario_venta)
    FROM venta_detalle VD);
  SET productosPocoStock = (SELECT
      COUNT(1)
    FROM productos p
    WHERE p.stock_producto <= 0);
  SET ventasHoy = (SELECT
      SUM(vc.total_venta)
    FROM venta_cabecera vc
    WHERE DATE(vc.fecha_venta) = CURDATE());

  SELECT
    IFNULL(totalProductos, 0) AS totalProductos,
    IFNULL(CONCAT('S./ ', FORMAT(totalCompras, 2)), 0) AS totalCompras,
    IFNULL(CONCAT('S./ ', FORMAT(totalVentas, 2)), 0) AS totalVentas,
    IFNULL(CONCAT('S./ ', FORMAT(ganancias, 2)), 0) AS ganancias,
    IFNULL(productosPocoStock, 0) AS productosPocoStock,
    IFNULL(CONCAT('S./ ', FORMAT(ventasHoy, 2)), 0) AS ventasHoy;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_obtenerNroBoleta` ()  NO SQL select serie_boleta,
		IFNULL(LPAD(max(c.nro_correlativo_venta)+1,8,'0'),'00000001') nro_venta 
from empresa c$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerVentasMesActual` ()  NO SQL BEGIN
SELECT date(vc.fecha_venta) as fecha_venta,
		sum(round(vc.total_venta,2)) as total_venta,
        (SELECT sum(round(vc1.total_venta,2))
			FROM venta_cabecera vc1
		where date(vc1.fecha_venta) >= date(last_day(now() - INTERVAL 2 month) + INTERVAL 1 day)
		and date(vc1.fecha_venta) <= last_day(last_day(now() - INTERVAL 2 month) + INTERVAL 1 day)
        and date(vc1.fecha_venta) = DATE_ADD(vc.fecha_venta, INTERVAL -1 MONTH)
		group by date(vc1.fecha_venta)) as total_venta_ant
FROM venta_cabecera vc
where date(vc.fecha_venta) >= date(last_day(now() - INTERVAL 1 month) + INTERVAL 1 day)
and date(vc.fecha_venta) <= last_day(date(CURRENT_DATE))
group by date(vc.fecha_venta);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_ObtenerVentasMesAnterior` ()  NO SQL BEGIN
SELECT date(vc.fecha_venta) as fecha_venta,
		sum(round(vc.total_venta,2)) as total_venta,
        sum(round(vc.total_venta,2)) as total_venta_ant
FROM venta_cabecera vc
where date(vc.fecha_venta) >= date(last_day(now() - INTERVAL 2 month) + INTERVAL 1 day)
and date(vc.fecha_venta) <= last_day(last_day(now() - INTERVAL 2 month) + INTERVAL 1 day)
group by date(vc.fecha_venta);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_registrar_kardex_bono` (IN `p_codigo_producto` VARCHAR(20), IN `p_concepto` VARCHAR(100), IN `p_nuevo_stock` FLOAT)   BEGIN

	declare v_unidades_ex float;
	declare v_costo_unitario_ex float;    
	declare v_costo_total_ex float;
    
    declare v_unidades_in float;
	declare v_costo_unitario_in float;    
	declare v_costo_total_in float;
    
	/*OBTENEMOS LAS ULTIMAS EXISTENCIAS DEL PRODUCTO*/
    
    SELECT k.ex_costo_unitario , k.ex_unidades, k.ex_costo_total
    into v_costo_unitario_ex, v_unidades_ex, v_costo_total_ex
    FROM KARDEX K
    WHERE K.CODIGO_PRODUCTO = p_codigo_producto
    ORDER BY ID DESC
    LIMIT 1;
    
    /*SETEAMOS LOS VALORES PARA EL REGISTRO DE INGRESO*/
    SET v_unidades_in = p_nuevo_stock;
    SET v_costo_unitario_in = 0;
    SET v_costo_total_in = v_unidades_in * v_costo_unitario_in;
    
    /*SETEAMOS LAS EXISTENCIAS ACTUALES*/
    SET v_unidades_ex = ROUND(v_unidades_in,2);    
    SET v_costo_total_ex = ROUND(v_costo_total_ex + v_costo_total_in,2);
    
    IF(v_costo_total_ex > 0) THEN
		SET v_costo_unitario_ex = ROUND(v_costo_total_ex/v_unidades_ex,2);
	else
		SET v_costo_unitario_ex = ROUND(0,2);
    END IF;
    
        
	INSERT INTO KARDEX(codigo_producto,
						fecha,
                        concepto,
                        comprobante,
                        in_unidades,
                        in_costo_unitario,
                        in_costo_total,
                        ex_unidades,
                        ex_costo_unitario,
                        ex_costo_total)
				VALUES(p_codigo_producto,
						curdate(),
                        p_concepto,
                        '',
                        v_unidades_in,
                        v_costo_unitario_in,
                        v_costo_total_in,
                        v_unidades_ex,
                        v_costo_unitario_ex,
                        v_costo_total_ex);

	/*ACTUALIZAMOS EL STOCK, EL NRO DE VENTAS DEL PRODUCTO*/
	UPDATE PRODUCTOS 
	SET stock_producto = v_unidades_ex, 
        precio_compra_producto = v_costo_unitario_ex,
        costo_total_producto = v_costo_total_ex
	WHERE codigo_producto = p_codigo_producto ;                      

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_registrar_kardex_existencias` (IN `p_codigo_producto` VARCHAR(25), IN `p_concepto` VARCHAR(100), IN `p_comprobante` VARCHAR(100), IN `p_unidades` FLOAT, IN `p_costo_unitario` FLOAT, IN `p_costo_total` FLOAT)   BEGIN
  INSERT INTO KARDEX (codigo_producto, fecha, concepto, comprobante, ex_unidades, ex_costo_unitario, ex_costo_total)
    VALUES (p_codigo_producto, CURDATE(), p_concepto, p_comprobante, p_unidades, p_costo_unitario, p_costo_total);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_registrar_kardex_vencido` (IN `p_codigo_producto` VARCHAR(20), IN `p_concepto` VARCHAR(100), IN `p_nuevo_stock` FLOAT)   BEGIN

	declare v_unidades_ex float;
	declare v_costo_unitario_ex float;    
	declare v_costo_total_ex float;
    
    declare v_unidades_out float;
	declare v_costo_unitario_out float;    
	declare v_costo_total_out float;
    
	/*OBTENEMOS LAS ULTIMAS EXISTENCIAS DEL PRODUCTO*/    
    SELECT k.ex_costo_unitario , k.ex_unidades, k.ex_costo_total
    into v_costo_unitario_ex, v_unidades_ex, v_costo_total_ex
    FROM KARDEX K
    WHERE K.CODIGO_PRODUCTO = p_codigo_producto
    ORDER BY ID DESC
    LIMIT 1;
    
    /*SETEAMOS LOS VALORES PARA EL REGISTRO DE SALIDA*/
    SET v_unidades_out = p_nuevo_stock;
    SET v_costo_unitario_out = 0;
    SET v_costo_total_out = v_unidades_out * v_costo_unitario_out;
    
    /*SETEAMOS LAS EXISTENCIAS ACTUALES*/
    SET v_unidades_ex = ROUND(v_unidades_out,2);    
    SET v_costo_total_ex = ROUND(v_costo_total_ex - v_costo_total_out,2);
    
    IF(v_costo_total_ex > 0) THEN
		SET v_costo_unitario_ex = ROUND(v_costo_total_ex/v_unidades_ex,2);
	else
		SET v_costo_unitario_ex = ROUND(0,2);
    END IF;
    
        
	INSERT INTO KARDEX(codigo_producto,
						fecha,
                        concepto,
                        comprobante,
                        out_unidades,
                        out_costo_unitario,
                        out_costo_total,
                        ex_unidades,
                        ex_costo_unitario,
                        ex_costo_total)
				VALUES(p_codigo_producto,
						curdate(),
                        p_concepto,
                        '',
                        v_unidades_out,
                        v_costo_unitario_out,
                        v_costo_total_out,
                        v_unidades_ex,
                        v_costo_unitario_ex,
                        v_costo_total_ex);

	/*ACTUALIZAMOS EL STOCK, EL NRO DE VENTAS DEL PRODUCTO*/
	UPDATE PRODUCTOS 
	SET stock_producto = v_unidades_ex, 
        precio_compra_producto = v_costo_unitario_ex,
        costo_total_producto = v_costo_total_ex
	WHERE codigo_producto = p_codigo_producto ;                      

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_registrar_kardex_venta` (IN `p_codigo_producto` VARCHAR(20), IN `p_fecha` DATE, IN `p_concepto` VARCHAR(100), IN `p_comprobante` VARCHAR(100), IN `p_unidades` FLOAT)   BEGIN

	declare v_unidades_ex float;
	declare v_costo_unitario_ex float;    
	declare v_costo_total_ex float;
    
    declare v_unidades_out float;
	declare v_costo_unitario_out float;    
	declare v_costo_total_out float;
    

	/*OBTENEMOS LAS ULTIMAS EXISTENCIAS DEL PRODUCTO*/
    
    SELECT k.ex_costo_unitario , k.ex_unidades, k.ex_costo_total
    into v_costo_unitario_ex, v_unidades_ex, v_costo_total_ex
    FROM KARDEX K
    WHERE K.CODIGO_PRODUCTO = p_codigo_producto
    ORDER BY ID DESC
    LIMIT 1;
    
    /*SETEAMOS LOS VALORES PARA EL REGISTRO DE SALIDA*/
    SET v_unidades_out = p_unidades;
    SET v_costo_unitario_out = v_costo_unitario_ex;
    SET v_costo_total_out = p_unidades * v_costo_unitario_ex;
    
    /*SETEAMOS LAS EXISTENCIAS ACTUALES*/
    SET v_unidades_ex = ROUND(v_unidades_ex - v_unidades_out,2);    
    SET v_costo_total_ex = ROUND(v_costo_total_ex -  v_costo_total_out,2);
    
    IF(v_costo_total_ex > 0) THEN
		SET v_costo_unitario_ex = ROUND(v_costo_total_ex/v_unidades_ex,2);
	else
		SET v_costo_unitario_ex = ROUND(0,2);
    END IF;
    
        
	INSERT INTO KARDEX(codigo_producto,
						fecha,
                        concepto,
                        comprobante,
                        out_unidades,
                        out_costo_unitario,
                        out_costo_total,
                        ex_unidades,
                        ex_costo_unitario,
                        ex_costo_total)
				VALUES(p_codigo_producto,
						p_fecha,
                        p_concepto,
                        p_comprobante,
                        v_unidades_out,
                        v_costo_unitario_out,
                        v_costo_total_out,
                        v_unidades_ex,
                        v_costo_unitario_ex,
                        v_costo_total_ex);

	/*ACTUALIZAMOS EL STOCK, EL NRO DE VENTAS DEL PRODUCTO*/
	UPDATE PRODUCTOS 
	SET stock_producto = v_unidades_ex, 
		ventas_producto = ventas_producto + v_unidades_out,
        precio_compra_producto = v_costo_unitario_ex,
        costo_total_producto = v_costo_total_ex
	WHERE codigo_producto = p_codigo_producto ;                      

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_registrar_venta_detalle` (IN `p_nro_boleta` VARCHAR(8), IN `p_codigo_producto` VARCHAR(20), IN `p_cantidad` FLOAT, IN `p_total_venta` FLOAT)   BEGIN
declare v_precio_compra float;
declare v_precio_venta float;

SELECT p.precio_compra_producto,p.precio_venta_producto
into v_precio_compra, v_precio_venta
FROM productos p
WHERE p.codigo_producto  = p_codigo_producto;
    
INSERT INTO venta_detalle(nro_boleta,codigo_producto, cantidad, costo_unitario_venta,precio_unitario_venta,total_venta, fecha_venta) 
VALUES(p_nro_boleta,p_codigo_producto,p_cantidad, v_precio_compra, v_precio_venta,p_total_venta,curdate());
                                                        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `prc_top_ventas_categorias` ()   BEGIN

select cast(sum(vd.total_venta)  AS DECIMAL(8,2)) as y, c.nombre_categoria as label
    from venta_detalle vd inner join productos p on vd.codigo_producto = p.codigo_producto
                        inner join categorias c on c.id_categoria = p.id_categoria_producto
    group by c.nombre_categoria
    LIMIT 10;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `obtener_y_marcar_codigo_disponible` (`categoria_param` VARCHAR(255)) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE codigo_completo VARCHAR(255);
    DECLARE codigo_numero INT;
    
    -- Busca el código mínimo disponible en la categoría especificada
    SET codigo_numero = NULL;
    
    IF categoria_param = 'BA' THEN
        -- Busca el siguiente código disponible en BA y marca como no disponible
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE BA = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET BA = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'BO' THEN
        -- Repite esto para la categoría BO
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE BO = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET BO = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'A' THEN
        -- Repite esto para la categoría A
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE A = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET A = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'O' THEN
        -- Repite esto para la categoría O
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE O = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET O = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'M' THEN
        -- Repite esto para la categoría M
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE M = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET M = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'H' THEN
        -- Repite esto para la categoría H
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE H = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET H = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'BAC' THEN
        -- Repite esto para la categoría BAC
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE BAC = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET BAC = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'BOC' THEN
        -- Repite esto para la categoría BOC
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE BOC = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET BOC = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'AC' THEN
        -- Repite esto para la categoría AC
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE AC = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET AC = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'OC' THEN
        -- Repite esto para la categoría OC
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE OC = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET OC = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'MC' THEN
        -- Repite esto para la categoría MC
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE MC = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET MC = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    ELSEIF categoria_param = 'HC' THEN
        -- Repite esto para la categoría HC
        SELECT codigo_producto_codigoDisponible INTO codigo_numero
        FROM codigos_disponibles
        WHERE HC = 1 LIMIT 1;
        
        IF codigo_numero IS NOT NULL THEN
            UPDATE codigos_disponibles SET HC = 0 WHERE codigo_producto_codigoDisponible = codigo_numero;
        END IF;
    END IF;
    
    -- Si no se encontró un código en la categoría, crea uno nuevo
    IF codigo_numero IS NULL THEN
        SELECT MAX(SUBSTRING_INDEX(codigo_producto_codigoDisponible, '-', -1)) INTO codigo_numero
        FROM codigos_disponibles
        WHERE codigo_producto_codigoDisponible LIKE CONCAT(categoria_param, '-%');
        
        IF codigo_numero IS NOT NULL THEN
            SET codigo_numero = codigo_numero + 1;
        ELSE
            SET codigo_numero = 1; -- Si no hay registros anteriores, comienza desde 1
        END IF;
        
        -- Inserta el nuevo código
        INSERT INTO codigos_disponibles (codigo_producto_codigoDisponible, BA, BO, A, O, M, H, BAC, BOC, AC, OC, MC, HC)
        VALUES (CONCAT(categoria_param, '-', codigo_numero), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    END IF;
    
    -- Concatena la categoría y el número
    SET codigo_completo = CONCAT(categoria_param, '-', codigo_numero);
    RETURN codigo_completo;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `arqueo_caja`
--

CREATE TABLE `arqueo_caja` (
  `id` int(11) NOT NULL,
  `id_caja` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_inicio` datetime DEFAULT NULL,
  `fecha_fin` datetime DEFAULT NULL,
  `monto_inicial` float DEFAULT NULL,
  `ingresos` float DEFAULT NULL,
  `devoluciones` float DEFAULT NULL,
  `gastos` float DEFAULT NULL,
  `monto_final` float DEFAULT NULL,
  `status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cajas`
--

CREATE TABLE `cajas` (
  `id` int(11) NOT NULL,
  `numero_caja` int(11) NOT NULL,
  `nombre_caja` varchar(100) NOT NULL,
  `estado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre_categoria` varchar(255) DEFAULT NULL,
  `genero_categoria` varchar(10) NOT NULL,
  `fecha_creacion_categoria` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_actualizacion_categoria` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`, `genero_categoria`, `fecha_creacion_categoria`, `fecha_actualizacion_categoria`) VALUES
(1, 'BEBÉ NIÑA', 'BA', '2023-09-25 21:36:10', NULL),
(2, 'BEBÉ NIÑO', 'BO', '2023-09-25 21:36:10', NULL),
(3, 'NIÑA', 'A', '2023-09-25 21:36:47', NULL),
(4, 'NIÑO', 'O', '2023-09-25 21:36:47', NULL),
(5, 'MUJER', 'M', '2023-09-25 21:37:32', NULL),
(6, 'HOMBRE', 'H', '2023-09-25 21:37:32', NULL),
(7, 'USA-CHINA: BEBÉ NIÑA', 'BAC', '2023-09-25 21:39:10', NULL),
(8, 'USA-CHINA: BEBÉ NIÑO', 'BOC', '2023-09-25 21:39:10', NULL),
(9, 'USA-CHINA: NIÑA', 'AC', '2023-09-25 21:40:19', NULL),
(10, 'USA-CHINA: NIÑO', 'OC', '2023-09-25 21:40:19', NULL),
(11, 'USA-CHINA: MUJER', 'MC', '2023-09-25 21:41:33', NULL),
(12, 'USA-CHINA: HOMBRE', 'HC', '2023-09-25 21:41:33', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `codigos_disponibles`
--

CREATE TABLE `codigos_disponibles` (
  `id` int(11) NOT NULL,
  `codigo_producto_codigoDisponible` varchar(255) DEFAULT NULL,
  `BA` tinyint(1) DEFAULT 1,
  `BO` tinyint(1) DEFAULT 1,
  `A` tinyint(1) DEFAULT 1,
  `O` tinyint(1) DEFAULT 1,
  `M` tinyint(1) DEFAULT 1,
  `H` tinyint(1) DEFAULT 1,
  `BAC` tinyint(1) DEFAULT 1,
  `BOC` tinyint(1) DEFAULT 1,
  `AC` tinyint(1) DEFAULT 1,
  `OC` tinyint(1) DEFAULT 1,
  `MC` tinyint(1) DEFAULT 1,
  `HC` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `codigos_disponibles`
--

INSERT INTO `codigos_disponibles` (`id`, `codigo_producto_codigoDisponible`, `BA`, `BO`, `A`, `O`, `M`, `H`, `BAC`, `BOC`, `AC`, `OC`, `MC`, `HC`) VALUES
(1, '1', 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1),
(2, '2', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(3, '3', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(4, '4', 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1),
(5, '5', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(6, '6', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(7, '7', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(8, '8', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(9, '9', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(10, '10', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(11, '11', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(12, '12', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(13, '13', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(14, '14', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(15, '15', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(16, '16', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(17, '17', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(18, '18', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(19, '19', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(20, '20', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(21, '21', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(22, '22', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(23, '23', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(24, '24', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(25, '25', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(26, '26', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(27, '27', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(28, '28', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(29, '29', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(30, '30', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(31, '31', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(32, '32', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(33, '33', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(34, '34', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(35, '35', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(36, '36', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(37, '37', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(38, '38', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(39, '39', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(40, '40', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(41, '41', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(42, '42', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(43, '43', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(44, '44', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(45, '45', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(46, '46', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(47, '47', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(48, '48', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(49, '49', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(50, '50', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(51, '51', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(52, '52', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(53, '53', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(54, '54', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(55, '55', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(56, '56', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(57, '57', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(58, '58', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(59, '59', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(60, '60', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(61, '61', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(62, '62', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(63, '63', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(64, '64', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(65, '65', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(66, '66', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(67, '67', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(68, '68', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(69, '69', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(70, '70', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(71, '71', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(72, '72', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(73, '73', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(74, '74', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(75, '75', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(76, '76', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(77, '77', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(78, '78', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(79, '79', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(80, '80', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(81, '81', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(82, '82', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(83, '83', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(84, '84', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(85, '85', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(86, '86', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(87, '87', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(88, '88', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(89, '89', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(90, '90', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(91, '91', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(92, '92', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(93, '93', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(94, '94', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(95, '95', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(96, '96', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(97, '97', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(98, '98', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(99, '99', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(100, '100', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(101, '101', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(102, '102', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(103, '103', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(104, '104', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(105, '105', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(106, '106', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(107, '107', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(108, '108', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(109, '109', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(110, '110', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(111, '111', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(112, '112', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(113, '113', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(114, '114', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(115, '115', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(116, '116', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(117, '117', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(118, '118', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(119, '119', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(120, '120', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(121, '121', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(122, '122', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(123, '123', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(124, '124', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(125, '125', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(126, '126', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(127, '127', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(128, '128', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(129, '129', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(130, '130', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(131, '131', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(132, '132', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(133, '133', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(134, '134', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(135, '135', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(136, '136', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(137, '137', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(138, '138', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(139, '139', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(140, '140', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(141, '141', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(142, '142', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(143, '143', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(144, '144', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(145, '145', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(146, '146', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(147, '147', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(148, '148', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(149, '149', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(150, '150', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(151, '151', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(152, '152', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(153, '153', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(154, '154', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(155, '155', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(156, '156', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(157, '157', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(158, '158', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(159, '159', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(160, '160', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(161, '161', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(162, '162', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(163, '163', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(164, '164', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(165, '165', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(166, '166', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(167, '167', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(168, '168', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(169, '169', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(170, '170', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(171, '171', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(172, '172', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(173, '173', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(174, '174', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(175, '175', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(176, '176', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(177, '177', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(178, '178', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(179, '179', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(180, '180', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(181, '181', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(182, '182', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(183, '183', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(184, '184', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(185, '185', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(186, '186', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(187, '187', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(188, '188', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(189, '189', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(190, '190', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(191, '191', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(192, '192', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(193, '193', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(194, '194', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(195, '195', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(196, '196', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(197, '197', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(198, '198', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(199, '199', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(200, '200', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(201, '201', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(202, '202', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(203, '203', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(204, '204', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(205, '205', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(206, '206', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(207, '207', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(208, '208', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(209, '209', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(210, '210', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(211, '211', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(212, '212', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(213, '213', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(214, '214', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(215, '215', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(216, '216', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(217, '217', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(218, '218', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(219, '219', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(220, '220', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(221, '221', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(222, '222', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(223, '223', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(224, '224', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(225, '225', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(226, '226', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(227, '227', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(228, '228', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(229, '229', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(230, '230', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(231, '231', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(232, '232', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(233, '233', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(234, '234', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(235, '235', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(236, '236', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(237, '237', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(238, '238', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(239, '239', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(240, '240', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(241, '241', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(242, '242', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(243, '243', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(244, '244', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(245, '245', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(246, '246', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(247, '247', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(248, '248', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(249, '249', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(250, '250', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(251, '251', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(252, '252', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(253, '253', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(254, '254', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(255, '255', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(256, '256', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(257, '257', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(258, '258', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(259, '259', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(260, '260', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(261, '261', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(262, '262', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(263, '263', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(264, '264', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(265, '265', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(266, '266', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(267, '267', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(268, '268', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(269, '269', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(270, '270', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(271, '271', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(272, '272', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(273, '273', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(274, '274', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(275, '275', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(276, '276', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(277, '277', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(278, '278', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(279, '279', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(280, '280', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(281, '281', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(282, '282', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(283, '283', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(284, '284', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(285, '285', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(286, '286', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(287, '287', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(288, '288', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(289, '289', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(290, '290', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(291, '291', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(292, '292', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(293, '293', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(294, '294', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(295, '295', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(296, '296', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(297, '297', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(298, '298', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(299, '299', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(300, '300', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(301, '301', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(302, '302', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(303, '303', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(304, '304', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(305, '305', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(306, '306', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(307, '307', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(308, '308', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(309, '309', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(310, '310', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(311, '311', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(312, '312', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(313, '313', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(314, '314', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(315, '315', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(316, '316', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(317, '317', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(318, '318', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(319, '319', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(320, '320', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(321, '321', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(322, '322', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(323, '323', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(324, '324', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(325, '325', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(326, '326', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(327, '327', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(328, '328', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(329, '329', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(330, '330', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(331, '331', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(332, '332', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(333, '333', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(334, '334', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(335, '335', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(336, '336', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(337, '337', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(338, '338', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(339, '339', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(340, '340', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(341, '341', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(342, '342', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(343, '343', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(344, '344', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(345, '345', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(346, '346', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(347, '347', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(348, '348', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(349, '349', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(350, '350', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(351, '351', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(352, '352', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(353, '353', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(354, '354', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(355, '355', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(356, '356', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(357, '357', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(358, '358', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(359, '359', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(360, '360', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(361, '361', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(362, '362', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(363, '363', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(364, '364', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(365, '365', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(366, '366', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(367, '367', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(368, '368', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(369, '369', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(370, '370', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(371, '371', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(372, '372', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(373, '373', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(374, '374', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(375, '375', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(376, '376', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(377, '377', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(378, '378', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(379, '379', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(380, '380', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(381, '381', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(382, '382', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(383, '383', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(384, '384', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(385, '385', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(386, '386', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(387, '387', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(388, '388', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(389, '389', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(390, '390', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(391, '391', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(392, '392', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(393, '393', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(394, '394', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(395, '395', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(396, '396', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(397, '397', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(398, '398', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(399, '399', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(400, '400', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(401, '401', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(402, '402', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(403, '403', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(404, '404', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(405, '405', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(406, '406', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(407, '407', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(408, '408', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(409, '409', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(410, '410', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(411, '411', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(412, '412', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(413, '413', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(414, '414', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(415, '415', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(416, '416', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(417, '417', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(418, '418', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(419, '419', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(420, '420', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(421, '421', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(422, '422', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(423, '423', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(424, '424', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(425, '425', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(426, '426', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(427, '427', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(428, '428', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(429, '429', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(430, '430', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(431, '431', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(432, '432', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(433, '433', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(434, '434', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(435, '435', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(436, '436', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(437, '437', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(438, '438', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(439, '439', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(440, '440', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(441, '441', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(442, '442', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(443, '443', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(444, '444', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(445, '445', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(446, '446', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(447, '447', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(448, '448', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(449, '449', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(450, '450', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(451, '451', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(452, '452', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(453, '453', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(454, '454', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(455, '455', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(456, '456', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(457, '457', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(458, '458', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(459, '459', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(460, '460', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(461, '461', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(462, '462', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(463, '463', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(464, '464', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(465, '465', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(466, '466', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(467, '467', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(468, '468', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(469, '469', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(470, '470', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(471, '471', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(472, '472', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(473, '473', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(474, '474', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(475, '475', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(476, '476', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(477, '477', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(478, '478', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(479, '479', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(480, '480', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(481, '481', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(482, '482', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(483, '483', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(484, '484', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(485, '485', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(486, '486', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(487, '487', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(488, '488', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(489, '489', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(490, '490', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(491, '491', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(492, '492', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(493, '493', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(494, '494', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(495, '495', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(496, '496', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(497, '497', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(498, '498', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(499, '499', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(500, '500', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(501, '501', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(502, '502', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(503, '503', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(504, '504', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(505, '505', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(506, '506', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(507, '507', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(508, '508', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(509, '509', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(510, '510', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(511, '511', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(512, '512', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(513, '513', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(514, '514', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(515, '515', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(516, '516', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(517, '517', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(518, '518', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(519, '519', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(520, '520', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(521, '521', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(522, '522', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(523, '523', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(524, '524', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(525, '525', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(526, '526', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(527, '527', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(528, '528', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(529, '529', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(530, '530', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(531, '531', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(532, '532', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(533, '533', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(534, '534', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(535, '535', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(536, '536', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(537, '537', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(538, '538', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(539, '539', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(540, '540', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(541, '541', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(542, '542', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(543, '543', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(544, '544', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(545, '545', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(546, '546', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(547, '547', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(548, '548', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(549, '549', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(550, '550', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(551, '551', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(552, '552', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(553, '553', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(554, '554', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(555, '555', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(556, '556', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(557, '557', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(558, '558', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(559, '559', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(560, '560', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(561, '561', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(562, '562', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(563, '563', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(564, '564', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(565, '565', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(566, '566', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(567, '567', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(568, '568', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(569, '569', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(570, '570', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(571, '571', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(572, '572', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(573, '573', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(574, '574', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(575, '575', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(576, '576', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(577, '577', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(578, '578', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(579, '579', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(580, '580', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(581, '581', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(582, '582', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(583, '583', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(584, '584', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(585, '585', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(586, '586', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(587, '587', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(588, '588', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(589, '589', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(590, '590', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(591, '591', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(592, '592', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(593, '593', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(594, '594', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(595, '595', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(596, '596', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(597, '597', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(598, '598', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(599, '599', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(600, '600', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(601, '601', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(602, '602', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(603, '603', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(604, '604', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(605, '605', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(606, '606', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(607, '607', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(608, '608', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(609, '609', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(610, '610', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(611, '611', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(612, '612', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(613, '613', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(614, '614', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(615, '615', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(616, '616', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(617, '617', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(618, '618', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(619, '619', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(620, '620', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(621, '621', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(622, '622', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(623, '623', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(624, '624', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(625, '625', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(626, '626', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(627, '627', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(628, '628', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(629, '629', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(630, '630', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(631, '631', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(632, '632', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(633, '633', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(634, '634', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(635, '635', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(636, '636', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(637, '637', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(638, '638', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(639, '639', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(640, '640', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(641, '641', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(642, '642', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(643, '643', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(644, '644', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(645, '645', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(646, '646', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(647, '647', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(648, '648', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(649, '649', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(650, '650', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(651, '651', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(652, '652', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(653, '653', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(654, '654', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(655, '655', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(656, '656', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(657, '657', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(658, '658', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(659, '659', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(660, '660', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(661, '661', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(662, '662', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(663, '663', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(664, '664', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(665, '665', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(666, '666', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(667, '667', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(668, '668', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(669, '669', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(670, '670', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(671, '671', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(672, '672', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(673, '673', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(674, '674', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(675, '675', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(676, '676', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(677, '677', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(678, '678', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(679, '679', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(680, '680', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(681, '681', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(682, '682', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(683, '683', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(684, '684', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(685, '685', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(686, '686', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(687, '687', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(688, '688', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(689, '689', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(690, '690', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(691, '691', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(692, '692', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(693, '693', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(694, '694', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(695, '695', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(696, '696', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(697, '697', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(698, '698', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(699, '699', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(700, '700', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(701, '701', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(702, '702', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(703, '703', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(704, '704', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(705, '705', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(706, '706', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(707, '707', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(708, '708', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(709, '709', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(710, '710', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(711, '711', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(712, '712', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(713, '713', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(714, '714', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(715, '715', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(716, '716', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(717, '717', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(718, '718', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(719, '719', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(720, '720', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(721, '721', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(722, '722', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(723, '723', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(724, '724', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(725, '725', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(726, '726', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(727, '727', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(728, '728', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(729, '729', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(730, '730', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(731, '731', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(732, '732', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(733, '733', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(734, '734', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(735, '735', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(736, '736', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(737, '737', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(738, '738', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(739, '739', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(740, '740', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(741, '741', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(742, '742', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(743, '743', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(744, '744', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(745, '745', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(746, '746', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(747, '747', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(748, '748', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(749, '749', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(750, '750', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(751, '751', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(752, '752', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(753, '753', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(754, '754', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(755, '755', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(756, '756', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(757, '757', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(758, '758', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(759, '759', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(760, '760', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(761, '761', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(762, '762', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(763, '763', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(764, '764', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(765, '765', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(766, '766', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(767, '767', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(768, '768', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(769, '769', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(770, '770', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(771, '771', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(772, '772', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(773, '773', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(774, '774', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(775, '775', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(776, '776', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(777, '777', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(778, '778', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(779, '779', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(780, '780', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(781, '781', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(782, '782', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(783, '783', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(784, '784', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(785, '785', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(786, '786', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(787, '787', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(788, '788', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(789, '789', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(790, '790', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(791, '791', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(792, '792', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(793, '793', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(794, '794', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(795, '795', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(796, '796', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(797, '797', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(798, '798', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(799, '799', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(800, '800', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(801, '801', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(802, '802', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(803, '803', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(804, '804', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(805, '805', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(806, '806', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(807, '807', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(808, '808', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(809, '809', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(810, '810', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(811, '811', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(812, '812', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(813, '813', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(814, '814', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(815, '815', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(816, '816', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(817, '817', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(818, '818', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(819, '819', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(820, '820', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(821, '821', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(822, '822', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(823, '823', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(824, '824', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(825, '825', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(826, '826', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(827, '827', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(828, '828', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(829, '829', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(830, '830', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(831, '831', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(832, '832', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(833, '833', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(834, '834', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(835, '835', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(836, '836', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(837, '837', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(838, '838', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(839, '839', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(840, '840', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(841, '841', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(842, '842', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(843, '843', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(844, '844', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(845, '845', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(846, '846', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(847, '847', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(848, '848', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(849, '849', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(850, '850', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(851, '851', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(852, '852', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(853, '853', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(854, '854', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(855, '855', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(856, '856', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(857, '857', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(858, '858', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(859, '859', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(860, '860', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(861, '861', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(862, '862', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(863, '863', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(864, '864', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(865, '865', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(866, '866', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(867, '867', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(868, '868', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(869, '869', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(870, '870', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(871, '871', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(872, '872', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(873, '873', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(874, '874', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(875, '875', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(876, '876', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(877, '877', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(878, '878', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(879, '879', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(880, '880', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(881, '881', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(882, '882', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(883, '883', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(884, '884', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(885, '885', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(886, '886', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(887, '887', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(888, '888', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(889, '889', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(890, '890', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(891, '891', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(892, '892', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(893, '893', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(894, '894', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(895, '895', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(896, '896', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(897, '897', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(898, '898', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(899, '899', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(900, '900', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(901, '901', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(902, '902', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(903, '903', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(904, '904', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(905, '905', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(906, '906', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(907, '907', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(908, '908', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(909, '909', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(910, '910', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(911, '911', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(912, '912', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(913, '913', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(914, '914', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(915, '915', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(916, '916', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(917, '917', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(918, '918', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(919, '919', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(920, '920', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(921, '921', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(922, '922', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(923, '923', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(924, '924', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(925, '925', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(926, '926', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(927, '927', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(928, '928', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(929, '929', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(930, '930', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(931, '931', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(932, '932', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(933, '933', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(934, '934', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(935, '935', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(936, '936', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(937, '937', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(938, '938', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(939, '939', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(940, '940', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(941, '941', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(942, '942', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(943, '943', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(944, '944', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(945, '945', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(946, '946', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(947, '947', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(948, '948', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(949, '949', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(950, '950', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(951, '951', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(952, '952', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(953, '953', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(954, '954', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(955, '955', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(956, '956', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(957, '957', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(958, '958', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(959, '959', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(960, '960', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(961, '961', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(962, '962', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(963, '963', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(964, '964', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(965, '965', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(966, '966', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(967, '967', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(968, '968', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(969, '969', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(970, '970', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(971, '971', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(972, '972', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(973, '973', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(974, '974', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(975, '975', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(976, '976', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(977, '977', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(978, '978', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(979, '979', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(980, '980', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(981, '981', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(982, '982', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(983, '983', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(984, '984', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(985, '985', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(986, '986', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(987, '987', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(988, '988', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(989, '989', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(990, '990', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(991, '991', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(992, '992', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(993, '993', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(994, '994', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(995, '995', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(996, '996', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(997, '997', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(998, '998', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(999, '999', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1000, '1000', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1001, '1001', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1002, '1002', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1003, '1003', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1004, '1004', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1005, '1005', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1006, '1006', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1007, '1007', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1008, '1008', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1009, '1009', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1010, '1010', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1011, '1011', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1012, '1012', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1013, '1013', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1014, '1014', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1015, '1015', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1016, '1016', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1017, '1017', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1018, '1018', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1019, '1019', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1020, '1020', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1021, '1021', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1022, '1022', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1023, '1023', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1024, '1024', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1025, '1025', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1026, '1026', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1027, '1027', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1028, '1028', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1029, '1029', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1030, '1030', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1031, '1031', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1032, '1032', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1033, '1033', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1034, '1034', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1035, '1035', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1036, '1036', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1037, '1037', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1038, '1038', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1039, '1039', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1040, '1040', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1041, '1041', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO `codigos_disponibles` (`id`, `codigo_producto_codigoDisponible`, `BA`, `BO`, `A`, `O`, `M`, `H`, `BAC`, `BOC`, `AC`, `OC`, `MC`, `HC`) VALUES
(1042, '1042', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1043, '1043', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1044, '1044', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1045, '1045', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1046, '1046', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1047, '1047', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1048, '1048', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1049, '1049', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1050, '1050', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1051, '1051', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1052, '1052', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1053, '1053', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1054, '1054', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1055, '1055', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1056, '1056', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1057, '1057', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1058, '1058', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1059, '1059', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1060, '1060', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1061, '1061', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1062, '1062', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1063, '1063', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1064, '1064', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1065, '1065', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1066, '1066', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1067, '1067', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1068, '1068', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1069, '1069', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1070, '1070', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1071, '1071', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1072, '1072', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1073, '1073', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1074, '1074', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1075, '1075', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1076, '1076', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1077, '1077', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1078, '1078', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1079, '1079', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1080, '1080', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1081, '1081', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1082, '1082', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1083, '1083', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1084, '1084', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1085, '1085', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1086, '1086', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1087, '1087', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1088, '1088', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1089, '1089', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1090, '1090', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1091, '1091', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1092, '1092', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1093, '1093', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1094, '1094', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1095, '1095', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1096, '1096', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1097, '1097', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1098, '1098', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1099, '1099', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1100, '1100', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1101, '1101', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1102, '1102', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1103, '1103', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1104, '1104', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1105, '1105', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1106, '1106', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1107, '1107', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1108, '1108', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1109, '1109', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1110, '1110', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1111, '1111', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1112, '1112', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1113, '1113', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1114, '1114', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1115, '1115', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1116, '1116', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1117, '1117', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1118, '1118', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1119, '1119', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1120, '1120', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1121, '1121', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1122, '1122', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1123, '1123', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1124, '1124', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1125, '1125', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1126, '1126', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1127, '1127', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1128, '1128', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1129, '1129', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1130, '1130', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1131, '1131', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1132, '1132', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1133, '1133', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1134, '1134', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1135, '1135', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1136, '1136', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1137, '1137', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1138, '1138', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1139, '1139', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1140, '1140', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1141, '1141', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1142, '1142', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1143, '1143', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1144, '1144', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1145, '1145', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1146, '1146', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1147, '1147', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1148, '1148', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1149, '1149', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1150, '1150', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1151, '1151', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1152, '1152', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1153, '1153', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1154, '1154', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1155, '1155', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1156, '1156', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1157, '1157', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1158, '1158', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1159, '1159', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1160, '1160', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1161, '1161', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1162, '1162', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1163, '1163', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1164, '1164', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1165, '1165', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1166, '1166', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1167, '1167', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1168, '1168', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1169, '1169', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1170, '1170', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1171, '1171', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1172, '1172', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1173, '1173', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1174, '1174', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1175, '1175', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1176, '1176', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1177, '1177', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1178, '1178', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1179, '1179', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1180, '1180', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1181, '1181', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1182, '1182', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1183, '1183', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1184, '1184', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1185, '1185', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1186, '1186', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1187, '1187', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1188, '1188', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1189, '1189', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1190, '1190', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1191, '1191', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1192, '1192', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1193, '1193', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1194, '1194', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1195, '1195', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1196, '1196', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1197, '1197', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1198, '1198', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1199, '1199', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1200, '1200', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1201, '1201', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1202, '1202', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1203, '1203', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1204, '1204', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1205, '1205', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1206, '1206', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1207, '1207', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1208, '1208', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1209, '1209', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1210, '1210', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1211, '1211', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1212, '1212', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1213, '1213', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1214, '1214', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1215, '1215', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1216, '1216', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1217, '1217', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1218, '1218', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1219, '1219', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1220, '1220', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1221, '1221', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1222, '1222', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1223, '1223', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1224, '1224', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1225, '1225', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1226, '1226', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1227, '1227', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1228, '1228', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1229, '1229', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1230, '1230', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1231, '1231', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1232, '1232', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1233, '1233', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1234, '1234', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1235, '1235', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1236, '1236', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1237, '1237', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1238, '1238', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1239, '1239', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1240, '1240', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1241, '1241', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1242, '1242', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1243, '1243', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1244, '1244', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1245, '1245', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1246, '1246', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1247, '1247', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1248, '1248', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1249, '1249', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1250, '1250', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1251, '1251', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1252, '1252', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1253, '1253', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1254, '1254', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1255, '1255', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1256, '1256', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1257, '1257', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1258, '1258', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1259, '1259', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1260, '1260', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1261, '1261', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1262, '1262', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1263, '1263', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1264, '1264', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1265, '1265', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1266, '1266', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1267, '1267', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1268, '1268', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1269, '1269', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1270, '1270', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1271, '1271', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1272, '1272', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1273, '1273', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1274, '1274', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1275, '1275', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1276, '1276', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1277, '1277', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1278, '1278', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1279, '1279', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1280, '1280', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1281, '1281', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1282, '1282', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1283, '1283', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1284, '1284', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1285, '1285', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1286, '1286', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1287, '1287', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1288, '1288', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1289, '1289', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1290, '1290', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1291, '1291', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1292, '1292', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1293, '1293', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1294, '1294', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1295, '1295', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1296, '1296', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1297, '1297', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1298, '1298', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1299, '1299', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1300, '1300', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1301, '1301', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1302, '1302', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1303, '1303', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1304, '1304', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1305, '1305', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1306, '1306', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1307, '1307', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1308, '1308', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1309, '1309', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1310, '1310', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1311, '1311', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1312, '1312', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1313, '1313', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1314, '1314', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1315, '1315', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1316, '1316', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1317, '1317', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1318, '1318', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1319, '1319', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1320, '1320', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1321, '1321', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1322, '1322', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1323, '1323', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1324, '1324', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1325, '1325', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1326, '1326', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1327, '1327', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1328, '1328', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1329, '1329', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1330, '1330', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1331, '1331', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1332, '1332', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1333, '1333', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1334, '1334', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1335, '1335', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1336, '1336', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1337, '1337', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1338, '1338', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1339, '1339', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1340, '1340', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1341, '1341', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1342, '1342', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1343, '1343', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1344, '1344', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1345, '1345', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1346, '1346', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1347, '1347', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1348, '1348', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1349, '1349', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1350, '1350', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1351, '1351', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1352, '1352', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1353, '1353', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1354, '1354', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1355, '1355', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1356, '1356', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1357, '1357', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1358, '1358', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1359, '1359', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1360, '1360', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1361, '1361', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1362, '1362', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1363, '1363', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1364, '1364', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1365, '1365', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1366, '1366', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1367, '1367', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1368, '1368', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1369, '1369', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1370, '1370', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1371, '1371', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1372, '1372', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1373, '1373', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1374, '1374', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1375, '1375', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1376, '1376', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1377, '1377', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1378, '1378', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1379, '1379', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1380, '1380', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1381, '1381', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1382, '1382', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1383, '1383', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1384, '1384', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1385, '1385', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1386, '1386', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1387, '1387', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1388, '1388', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1389, '1389', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1390, '1390', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1391, '1391', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1392, '1392', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1393, '1393', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1394, '1394', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1395, '1395', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1396, '1396', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1397, '1397', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1398, '1398', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1399, '1399', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1400, '1400', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1401, '1401', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1402, '1402', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1403, '1403', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1404, '1404', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1405, '1405', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1406, '1406', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1407, '1407', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1408, '1408', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1409, '1409', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1410, '1410', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1411, '1411', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1412, '1412', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1413, '1413', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1414, '1414', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1415, '1415', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1416, '1416', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1417, '1417', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1418, '1418', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1419, '1419', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1420, '1420', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1421, '1421', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1422, '1422', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1423, '1423', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1424, '1424', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1425, '1425', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1426, '1426', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1427, '1427', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1428, '1428', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1429, '1429', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1430, '1430', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1431, '1431', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1432, '1432', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1433, '1433', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1434, '1434', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1435, '1435', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1436, '1436', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1437, '1437', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1438, '1438', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1439, '1439', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1440, '1440', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1441, '1441', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1442, '1442', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1443, '1443', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1444, '1444', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1445, '1445', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1446, '1446', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1447, '1447', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1448, '1448', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1449, '1449', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1450, '1450', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1451, '1451', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1452, '1452', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1453, '1453', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1454, '1454', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1455, '1455', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1456, '1456', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1457, '1457', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1458, '1458', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1459, '1459', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1460, '1460', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1461, '1461', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1462, '1462', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1463, '1463', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1464, '1464', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1465, '1465', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1466, '1466', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1467, '1467', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1468, '1468', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1469, '1469', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1470, '1470', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1471, '1471', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1472, '1472', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1473, '1473', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1474, '1474', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1475, '1475', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1476, '1476', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1477, '1477', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1478, '1478', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1479, '1479', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1480, '1480', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1481, '1481', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1482, '1482', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1483, '1483', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1484, '1484', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1485, '1485', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1486, '1486', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1487, '1487', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1488, '1488', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1489, '1489', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1490, '1490', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1491, '1491', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1492, '1492', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1493, '1493', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1494, '1494', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1495, '1495', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1496, '1496', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1497, '1497', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1498, '1498', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1499, '1499', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1500, '1500', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(1501, '4-1', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1502, '4-2', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1503, '2-1', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1504, '2-2', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1505, '2-3', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1506, '2-4', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1507, '5-1', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1508, '2-5', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1509, '4-3', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1510, 'SELECT categorias.genero_categoria FROM categorias WHERE categorias.id_categoria=1;-1', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1511, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1512, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1513, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1514, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1515, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1516, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1517, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1518, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(1519, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id` int(11) NOT NULL,
  `id_proveedor` int(11) DEFAULT NULL,
  `id_tipo_comprobante` varchar(3) DEFAULT NULL,
  `serie_comprobante` varchar(10) DEFAULT NULL,
  `nro_comprobante` varchar(20) DEFAULT NULL,
  `fecha_comprobante` datetime DEFAULT NULL,
  `id_moneda_comprobante` int(11) DEFAULT NULL,
  `ope_exonerada` float DEFAULT NULL,
  `ope_inafecta` float DEFAULT NULL,
  `ope_gravada` float DEFAULT NULL,
  `igv` float DEFAULT NULL,
  `total_compra` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compra`
--

CREATE TABLE `detalle_compra` (
  `id` int(11) NOT NULL,
  `id_compra` int(11) DEFAULT NULL,
  `codigo_producto` varchar(20) DEFAULT NULL,
  `cantidad` float DEFAULT NULL,
  `costo_unitario` float DEFAULT NULL,
  `descuento` float DEFAULT NULL,
  `subtotal` float DEFAULT NULL,
  `impuesto` float DEFAULT NULL,
  `total` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `id_empresa` int(11) NOT NULL,
  `razon_social` text NOT NULL,
  `ruc` bigint(20) NOT NULL,
  `direccion` text NOT NULL,
  `marca` text NOT NULL,
  `serie_boleta` varchar(4) NOT NULL,
  `nro_correlativo_venta` varchar(8) NOT NULL,
  `email` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`id_empresa`, `razon_social`, `ruc`, `direccion`, `marca`, `serie_boleta`, `nro_correlativo_venta`, `email`) VALUES
(1, 'Disfrazarte AQP | El arte del disfraz', 12345678912, 'Avenida Brasil 1347-Cerro Colorado', 'Disfrazarte AQP | El arte del disfraz', 'B001', '00000012', 'disfrazarteAQP@gmail.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `kardex`
--

CREATE TABLE `kardex` (
  `id` int(11) NOT NULL,
  `codigo_producto` varchar(20) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `concepto` varchar(100) DEFAULT NULL,
  `comprobante` varchar(50) DEFAULT NULL,
  `in_unidades` float DEFAULT NULL,
  `in_costo_unitario` float DEFAULT NULL,
  `in_costo_total` float DEFAULT NULL,
  `out_unidades` float DEFAULT NULL,
  `out_costo_unitario` float DEFAULT NULL,
  `out_costo_total` float DEFAULT NULL,
  `ex_unidades` float DEFAULT NULL,
  `ex_costo_unitario` float DEFAULT NULL,
  `ex_costo_total` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `kardex`
--

INSERT INTO `kardex` (`id`, `codigo_producto`, `fecha`, `concepto`, `comprobante`, `in_unidades`, `in_costo_unitario`, `in_costo_total`, `out_unidades`, `out_costo_unitario`, `out_costo_total`, `ex_unidades`, `ex_costo_unitario`, `ex_costo_total`) VALUES
(5290, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 5.9, 141.6),
(5291, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 12.1, 278.3),
(5292, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 12.4, 359.6),
(5293, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 26, 3.25, 84.5),
(5294, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 5.15, 118.45),
(5295, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 9.8, 284.2),
(5296, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 7.49, 202.23),
(5297, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 26, 8, 208),
(5298, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 26, 10, 260),
(5299, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 3.79, 79.59),
(5300, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 3.99, 99.75),
(5301, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 1.29, 34.83),
(5302, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 1, 27),
(5303, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 1.9, 47.5),
(5304, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 2.8, 75.6),
(5305, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 20, 4.4, 88),
(5306, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 3.79, 87.17),
(5307, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 26, 3.79, 98.54),
(5308, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 3.65, 87.6),
(5309, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 20, 3.5, 70),
(5310, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 3.17, 85.59),
(5311, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 30, 5.17, 155.1),
(5312, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 4.58, 128.24),
(5313, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 5, 110),
(5314, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 4.66, 125.82),
(5315, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 4.65, 106.95),
(5316, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 4.63, 97.23),
(5317, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 5.7, 153.9),
(5318, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 6.08, 164.16),
(5319, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 5.9, 129.8),
(5320, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 5.9, 165.2),
(5321, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 5.9, 171.1),
(5322, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 5.08, 106.68),
(5323, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 5.63, 163.27),
(5324, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 5.9, 171.1),
(5325, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 5.9, 159.3),
(5326, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 5.33, 117.26),
(5327, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 8.9, 186.9),
(5328, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 5.7, 119.7),
(5329, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 18.29, 384.09),
(5330, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 2.8, 78.4),
(5331, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 20, 1, 20),
(5332, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 3.25, 68.25),
(5333, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 30, 3.1, 93),
(5334, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 3.39, 71.19),
(5335, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 20, 1.3, 26),
(5336, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 1.99, 55.72),
(5337, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 1, 29),
(5338, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 5.4, 124.2),
(5339, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 0.53, 13.25),
(5340, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 0.9, 20.7),
(5341, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 0.9, 22.5),
(5342, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 30, 0.67, 20.1),
(5343, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 1.39, 30.58),
(5344, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 30, 1.39, 41.7),
(5345, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 1.39, 29.19),
(5346, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 1.39, 34.75),
(5347, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 2.8, 58.8),
(5348, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 2.6, 57.2),
(5349, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 2.6, 62.4),
(5350, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 2.19, 52.56),
(5351, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 2.19, 61.32),
(5352, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 3.4, 85),
(5353, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 0.5, 14),
(5354, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 0.88, 21.12),
(5355, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 1.5, 36),
(5356, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 0.37, 10.73),
(5357, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 0.68, 14.28),
(5358, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 0.52, 12.48),
(5359, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 20, 0.52, 10.4),
(5360, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 0.52, 11.96),
(5361, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 0.47, 12.69),
(5362, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 0.47, 11.28),
(5363, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 0.47, 13.63),
(5364, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 0.9, 26.1),
(5365, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 24, 0.62, 14.88),
(5366, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 0.56, 12.32),
(5367, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 0.5, 12.5),
(5368, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 1.8, 50.4),
(5369, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 3.69, 81.18),
(5370, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 27, 2.8, 75.6),
(5371, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 0.33, 7.26),
(5372, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 20, 0.43, 8.6),
(5373, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 29, 0.75, 21.75),
(5374, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 28, 0.6, 16.8),
(5375, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 0.85, 17.85),
(5376, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 26, 0.92, 23.92),
(5377, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 1.06, 24.38),
(5378, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 26, 1.5, 39),
(5379, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 1.5, 31.5),
(5380, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 23, 2.6, 59.8),
(5381, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 3, 63),
(5382, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 26, 3.2, 83.2),
(5383, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 25, 2.89, 72.25),
(5384, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 21, 0.57, 11.97),
(5385, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 22, 0.53, 11.66),
(5386, NULL, '2022-12-10 00:00:00', 'VENTA', '00000218', NULL, NULL, NULL, 3, 3.25, 9.75, 18, 3.25, 58.5),
(5387, NULL, '2022-12-10 00:00:00', 'VENTA', '00000219', NULL, NULL, NULL, 1, 0.62, 0.62, 23, 0.62, 14.26),
(5388, NULL, '2022-12-10 00:00:00', 'VENTA', '00000219', NULL, NULL, NULL, 1, 9.8, 9.8, 28, 9.8, 274.4),
(5389, NULL, '2022-12-10 00:00:00', 'VENTA', '00000219', NULL, NULL, NULL, 1, 1, 1, 19, 1, 19),
(5390, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 10, 3.5, 35),
(5391, NULL, '2022-12-10 00:00:00', 'VENTA', '00000220', NULL, NULL, NULL, 0.5, 3.5, 1.75, 9.5, 3.5, 33.25),
(5392, NULL, '2022-12-09 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 5, 2, 10),
(5393, NULL, '2022-12-10 00:00:00', 'VENTA', '00000221', NULL, NULL, NULL, 0.25, 3.5, 0.875, 9.25, 3.5, 32.38),
(5394, NULL, '2022-12-10 00:00:00', 'VENTA', '00000222', NULL, NULL, NULL, 1, 3.4, 3.4, 24, 3.4, 81.6),
(5395, NULL, '2022-12-10 00:00:00', 'VENTA', '00000222', NULL, NULL, NULL, 1, 9.8, 9.8, 27, 9.8, 264.6),
(5396, NULL, '2022-12-10 00:00:00', 'VENTA', '00000222', NULL, NULL, NULL, 1, 3.5, 3.5, 8.25, 3.5, 28.88),
(5397, NULL, '2022-12-11 00:00:00', 'VENTA', '00000223', NULL, NULL, NULL, 3, 0.67, 2.01, 27, 0.67, 18.09),
(5398, NULL, '2022-12-11 00:00:00', 'VENTA', '00000224', NULL, NULL, NULL, 1, 3.5, 3.5, 7.25, 3.5, 25.38),
(5399, NULL, '2022-12-11 00:00:00', 'VENTA', '00000225', NULL, NULL, NULL, 1, 0.67, 0.67, 26, 0.67, 17.42),
(5400, NULL, '2022-12-12 00:00:00', 'VENTA', '00000226', NULL, NULL, NULL, 1, 3.5, 3.5, 6.25, 3.5, 21.88),
(5401, NULL, '2022-12-12 00:00:00', 'VENTA', '00000226', NULL, NULL, NULL, 1, 3.25, 3.25, 17, 3.25, 55.25),
(5402, NULL, '2022-12-12 00:00:00', 'VENTA', '00000227', NULL, NULL, NULL, 5, 18.29, 91.45, 16, 18.29, 292.64),
(5403, NULL, '2022-12-12 00:00:00', 'VENTA', '00000228', NULL, NULL, NULL, 10, 1.06, 10.6, 13, 1.06, 13.78),
(5404, NULL, '2022-12-11 00:00:00', 'INVENTARIO INICIAL', '', NULL, NULL, NULL, NULL, NULL, NULL, 10, 3, 30),
(5405, NULL, '2022-12-12 00:00:00', 'VENTA', '00000229', NULL, NULL, NULL, 0.25, 3, 0.75, 9.75, 3, 29.25),
(5406, NULL, '2022-12-12 00:00:00', 'VENTA', '00000230', NULL, NULL, NULL, 1, 5.9, 5.9, 26, 5.9, 153.4),
(5407, NULL, '2022-12-12 00:00:00', 'VENTA', '00000230', NULL, NULL, NULL, 1, 2.6, 2.6, 22, 2.6, 57.2),
(5408, NULL, '2022-12-12 00:00:00', 'VENTA', '00000230', NULL, NULL, NULL, 1, 9.8, 9.8, 26, 9.8, 254.8),
(5409, NULL, '2022-12-12 00:00:00', 'VENTA', '00000231', NULL, NULL, NULL, 3, 3.5, 10.5, 17, 3.5, 59.5),
(5410, NULL, '2022-12-12 00:00:00', 'VENTA', '00000231', NULL, NULL, NULL, 1, 3.65, 3.65, 23, 3.65, 83.95),
(5411, NULL, '2022-12-12 00:00:00', 'VENTA', '00000231', NULL, NULL, NULL, 1, 3.25, 3.25, 16, 3.25, 52),
(5412, NULL, '2022-12-13 00:00:00', 'VENTA', '00000232', NULL, NULL, NULL, 1, 3.25, 3.25, 15, 3.25, 48.75),
(5413, NULL, '2022-12-15 00:00:00', 'VENTA', '00000233', NULL, NULL, NULL, 1, 0.5, 0.5, 24, 0.5, 12),
(5414, NULL, '2022-12-15 00:00:00', 'VENTA', '00000233', NULL, NULL, NULL, 1, 0.33, 0.33, 21, 0.33, 6.93),
(5415, NULL, '2022-12-15 00:00:00', 'VENTA', '00000233', NULL, NULL, NULL, 1, 5.9, 5.9, 25, 5.9, 147.5),
(5416, NULL, '2022-12-15 00:00:00', 'VENTA', '00000233', NULL, NULL, NULL, 1, 3.25, 3.25, 14, 3.25, 45.5),
(5417, NULL, '2022-12-15 00:00:00', 'VENTA', '00000233', NULL, NULL, NULL, 1, 9.8, 9.8, 25, 9.8, 245),
(5418, NULL, '2022-12-15 00:00:00', 'VENTA', '00000234', NULL, NULL, NULL, 1, 18.29, 18.29, 15, 18.29, 274.35),
(5419, NULL, '2022-12-15 00:00:00', 'VENTA', '00000234', NULL, NULL, NULL, 1, 0.47, 0.47, 26, 0.47, 12.22),
(5420, NULL, '2022-12-15 00:00:00', 'VENTA', '00000234', NULL, NULL, NULL, 1, 3.4, 3.4, 23, 3.4, 78.2),
(5421, NULL, '2022-12-15 00:00:00', 'VENTA', '00000234', NULL, NULL, NULL, 1, 1.5, 1.5, 25, 1.5, 37.5),
(5422, NULL, '2022-12-17 00:00:00', 'VENTA', '00000235', NULL, NULL, NULL, 1, 9.8, 9.8, 24, 9.8, 235.2),
(5423, NULL, '2022-12-17 00:00:00', 'VENTA', '00000235', NULL, NULL, NULL, 1, 3.25, 3.25, 13, 3.25, 42.25),
(5424, NULL, '2022-12-17 00:00:00', 'VENTA', '00000235', NULL, NULL, NULL, 1, 1, 1, 18, 1, 18),
(5425, NULL, '2022-12-17 00:00:00', 'VENTA', '00000235', NULL, NULL, NULL, 1, 2.6, 2.6, 21, 2.6, 54.6),
(5426, NULL, '2022-12-17 00:00:00', 'VENTA', '00000235', NULL, NULL, NULL, 1, 2, 2, 4, 2, 8),
(5427, NULL, '2022-12-17 00:00:00', 'VENTA', '00000236', NULL, NULL, NULL, 5, 1.5, 7.5, 20, 1.5, 30),
(5428, NULL, '2022-12-17 00:00:00', 'VENTA', '00000236', NULL, NULL, NULL, 5, 0.9, 4.5, 18, 0.9, 16.2),
(5429, NULL, '2022-12-17 00:00:00', 'VENTA', '00000237', NULL, NULL, NULL, 1, 3.25, 3.25, 12, 3.25, 39),
(5430, NULL, '2022-12-17 00:00:00', 'VENTA', '00000237', NULL, NULL, NULL, 1, 3.4, 3.4, 22, 3.4, 74.8),
(5431, NULL, '2022-12-17 00:00:00', 'VENTA', '00000238', NULL, NULL, NULL, 1, 3, 3, 20, 3, 60),
(5432, NULL, '2022-12-17 00:00:00', 'VENTA', '00000238', NULL, NULL, NULL, 0.25, 2, 0.5, 3.75, 2, 7.5),
(5433, NULL, '2022-12-17 00:00:00', 'BONO / REGALO', '', 18, 0, 0, NULL, NULL, NULL, 18, 0.77, 13.78),
(5434, NULL, '2022-12-20 00:00:00', 'VENTA', '00000239', NULL, NULL, NULL, 6, 5.9, 35.4, 22, 5.9, 129.8),
(5435, NULL, '2022-12-20 00:00:00', 'VENTA', '00000239', NULL, NULL, NULL, 1, 3.25, 3.25, 11, 3.25, 35.75),
(5436, NULL, '2022-12-20 00:00:00', 'VENTA', '00000239', NULL, NULL, NULL, 5, 3.2, 16, 21, 3.2, 67.2),
(5437, NULL, '2022-12-20 00:00:00', 'VENTA', '00000239', NULL, NULL, NULL, 1, 1.5, 1.5, 23, 1.5, 34.5),
(5438, NULL, '2022-12-21 00:00:00', 'VENTA', '00000240', NULL, NULL, NULL, 4, 18.29, 73.16, 11, 18.29, 201.19),
(5439, NULL, '2022-12-21 00:00:00', 'VENTA', '00000241', NULL, NULL, NULL, 2, 5.9, 11.8, 23, 5.9, 135.7),
(5440, NULL, '2022-12-22 00:00:00', 'VENTA', '00000242', NULL, NULL, NULL, 10, 0.53, 5.3, 15, 0.53, 7.95),
(5441, NULL, '2022-12-22 00:00:00', 'VENTA', '00000242', NULL, NULL, NULL, 10, 0.56, 5.6, 12, 0.56, 6.72),
(5442, NULL, '2022-12-22 00:00:00', 'VENTA', '00000242', NULL, NULL, NULL, 10, 0.47, 4.7, 14, 0.47, 6.58),
(5443, NULL, '2022-12-22 00:00:00', 'VENTA', '00000242', NULL, NULL, NULL, 10, 0.37, 3.7, 19, 0.37, 7.03),
(5444, NULL, '2022-12-22 00:00:00', 'VENTA', '00000242', NULL, NULL, NULL, 10, 0.33, 3.3, 11, 0.33, 3.63),
(5445, NULL, '2022-12-22 00:00:00', 'VENTA', '00000243', NULL, NULL, NULL, 3, 8.9, 26.7, 18, 8.9, 160.2),
(5446, NULL, '2022-12-22 00:00:00', 'VENTA', '00000243', NULL, NULL, NULL, 3, 18.29, 54.87, 8, 18.29, 146.32),
(5447, NULL, '2022-12-22 00:00:00', 'VENTA', '00000243', NULL, NULL, NULL, 3, 9.8, 29.4, 21, 9.8, 205.8),
(5448, NULL, '2022-12-22 00:00:00', 'VENTA', '00000244', NULL, NULL, NULL, 10, 2.6, 26, 12, 2.6, 31.2),
(5449, NULL, '2022-12-22 00:00:00', 'BONO / REGALO', '', 11, 0, 0, NULL, NULL, NULL, 11, 13.3, 146.32),
(5450, NULL, '2022-12-22 00:00:00', 'VENCIMIENTO', '', NULL, NULL, NULL, 8, 0, 0, 8, 18.29, 146.32),
(5451, NULL, '2022-12-22 00:00:00', 'BONO / REGALO', '', 13, 0, 0, NULL, NULL, NULL, 13, 11.26, 146.32),
(5452, NULL, '2022-12-22 00:00:00', 'VENCIMIENTO', '', NULL, NULL, NULL, 8, 0, 0, 8, 18.29, 146.32),
(5453, NULL, '2022-12-22 00:00:00', 'BONO / REGALO', '', 12, 0, 0, NULL, NULL, NULL, 12, 12.19, 146.32),
(5454, NULL, '2022-12-23 00:00:00', 'VENTA', '00000245', NULL, NULL, NULL, 15, 10, 150, 11, 10, 110),
(5455, NULL, '2022-12-23 00:00:00', 'VENTA', '00000246', NULL, NULL, NULL, 7, 12.19, 85.33, 5, 12.2, 60.99),
(5456, NULL, '2022-12-26 00:00:00', 'VENTA', '00000247', NULL, NULL, NULL, 10, 0.77, 7.7, 8, 0.76, 6.08),
(5457, NULL, '2022-12-26 00:00:00', 'VENTA', '00000247', NULL, NULL, NULL, 10, 0.92, 9.2, 16, 0.92, 14.72),
(5458, NULL, '2022-12-26 00:00:00', 'VENTA', '00000247', NULL, NULL, NULL, 10, 1.8, 18, 18, 1.8, 32.4),
(5459, NULL, '2022-12-26 00:00:00', 'VENTA', '00000248', NULL, NULL, NULL, 1, 3.25, 3.25, 10, 3.25, 32.5),
(5460, NULL, '2022-12-26 00:00:00', 'VENTA', '00000249', NULL, NULL, NULL, 1, 0.76, 0.76, 7, 0.76, 5.32),
(5461, NULL, '2022-12-29 00:00:00', 'VENTA', '00000250', NULL, NULL, NULL, 0.25, 2, 0.5, 3.5, 2, 7),
(5462, NULL, '2022-12-29 00:00:00', 'VENTA', '00000250', NULL, NULL, NULL, 10, 2.6, 26, 2, 2.6, 5.2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `modulos`
--

CREATE TABLE `modulos` (
  `id` int(11) NOT NULL,
  `modulo` varchar(45) DEFAULT NULL,
  `padre_id` int(11) DEFAULT NULL,
  `vista` varchar(45) DEFAULT NULL,
  `icon_menu` varchar(45) DEFAULT NULL,
  `orden` int(11) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT NULL,
  `fecha_actualizacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `modulos`
--

INSERT INTO `modulos` (`id`, `modulo`, `padre_id`, `vista`, `icon_menu`, `orden`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 'Tablero Principal', 0, 'dashboard.php', 'fas fa-tachometer-alt', 0, NULL, NULL),
(2, 'Comprobantes', 0, '', 'fas fa-store-alt', 1, NULL, NULL),
(3, 'Emitir Boleta', 2, 'ventas.php', 'far fa-circle', 2, NULL, NULL),
(4, 'Resumen de Boletas', 2, 'administrar_ventas.php', 'far fa-circle', 3, NULL, NULL),
(5, 'Productos', 0, NULL, 'fas fa-cart-plus', 4, NULL, NULL),
(6, 'Inventario', 5, 'productos.php', 'far fa-circle', 5, NULL, NULL),
(7, 'Carga Masiva', 5, 'carga_masiva_productos.php', 'far fa-circle', 6, NULL, NULL),
(8, 'Categorías', 5, 'categorias.php', 'far fa-circle', 7, NULL, NULL),
(9, 'Compras', 0, 'compras.php', 'fas fa-dolly', 9, NULL, NULL),
(10, 'Reportes', 0, 'reportes.php', 'fas fa-chart-line', 10, NULL, NULL),
(11, 'Configuración', 0, 'configuracion.php', 'fas fa-cogs', 11, NULL, NULL),
(12, 'Usuarios', 0, 'usuarios.php', 'fas fa-users', 12, NULL, NULL),
(13, 'Roles y Perfiles', 0, 'modulos_perfiles.php', 'fas fa-tablet-alt', 13, NULL, NULL),
(15, 'Caja', 0, 'caja.php', 'fas fa-cash-register', 8, '2022-12-05 09:44:08', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `monedas`
--

CREATE TABLE `monedas` (
  `id` int(11) NOT NULL,
  `descripcion` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfiles`
--

CREATE TABLE `perfiles` (
  `id_perfil` int(11) NOT NULL,
  `descripcion` varchar(45) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT NULL,
  `fecha_actualizacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `perfiles`
--

INSERT INTO `perfiles` (`id_perfil`, `descripcion`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, 'Administrador', 1, NULL, NULL),
(2, 'Vendedor', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil_modulo`
--

CREATE TABLE `perfil_modulo` (
  `idperfil_modulo` int(11) NOT NULL,
  `id_perfil` int(11) DEFAULT NULL,
  `id_modulo` int(11) DEFAULT NULL,
  `vista_inicio` tinyint(4) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `perfil_modulo`
--

INSERT INTO `perfil_modulo` (`idperfil_modulo`, `id_perfil`, `id_modulo`, `vista_inicio`, `estado`) VALUES
(13, 1, 13, NULL, 1),
(79, 2, 1, 0, 1),
(80, 2, 3, 1, 1),
(81, 2, 2, 0, 1),
(82, 2, 4, 0, 1),
(83, 2, 10, 0, 1),
(84, 2, 15, 0, 1),
(97, 1, 1, 1, 1),
(98, 1, 3, 0, 1),
(99, 1, 2, 0, 1),
(100, 1, 4, 0, 1),
(101, 1, 6, 0, 1),
(102, 1, 5, 0, 1),
(104, 1, 8, 0, 1),
(105, 1, 9, 0, 1),
(106, 1, 10, 0, 1),
(107, 1, 11, 0, 1),
(108, 1, 12, 0, 1),
(109, 1, 15, 0, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id_producto` int(11) NOT NULL,
  `codigo_producto` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `id_categoria_producto` int(11) NOT NULL,
  `nombre_producto` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `descripcion_producto` text CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT 'Sin descripción',
  `incluye_producto` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `no_incluye_producto` text CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT 'Sin datos',
  `numero_piezas_producto` int(11) NOT NULL DEFAULT 0,
  `stock_producto` int(11) NOT NULL DEFAULT 0,
  `minimo_stock_producto` int(11) DEFAULT 0,
  `precio_compra_producto` float DEFAULT 0,
  `precio_venta_producto` float DEFAULT 0,
  `utilidad_venta_producto` float NOT NULL DEFAULT 0,
  `precio_alquiler_estreno_producto` float DEFAULT 0,
  `utilidad_alquiler_estreno_producto` float NOT NULL DEFAULT 0,
  `precio_alquiler_simple_producto` float DEFAULT 0,
  `utilidad_alquiler_simple_producto` float NOT NULL DEFAULT 0,
  `numero_ventas_producto` float DEFAULT 0,
  `costo_total_producto` float DEFAULT 0,
  `talla_producto` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT 'Sin talla',
  `marca_producto` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT 'Sin marca',
  `modalidad` enum('Venta','Alq. Normal','Venta/Alq. Estreno','Sin modalidad') NOT NULL DEFAULT 'Sin modalidad',
  `estado_producto` enum('Disponible','No disponible') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'Disponible',
  `imagen_producto` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT 'Sin imagen',
  `fecha_creacion_producto` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_actualizacion_producto` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `codigo_producto`, `id_categoria_producto`, `nombre_producto`, `descripcion_producto`, `incluye_producto`, `no_incluye_producto`, `numero_piezas_producto`, `stock_producto`, `minimo_stock_producto`, `precio_compra_producto`, `precio_venta_producto`, `utilidad_venta_producto`, `precio_alquiler_estreno_producto`, `utilidad_alquiler_estreno_producto`, `precio_alquiler_simple_producto`, `utilidad_alquiler_simple_producto`, `numero_ventas_producto`, `costo_total_producto`, `talla_producto`, `marca_producto`, `modalidad`, `estado_producto`, `imagen_producto`, `fecha_creacion_producto`, `fecha_actualizacion_producto`) VALUES
(9, 'M-4', 12, 'GUILLE', '', '2 mangas', '', 2, 0, 0, 12, 11, 0, 11, 0, 11, 0, 0, 0, 'S', '', 'Alq. Normal', 'No disponible', 'Sin imagen', '2023-10-03 04:32:55', '2023-09-29'),
(10, 'MC-1', 12, 'GUILLE', '', '2 mangas', '', 2, 2, 0, 12, 11, 0, 11, 0, 11, 0, 0, 0, 'S', '', 'Sin modalidad', 'Disponible', 'Sin imagen', '2023-10-03 04:34:26', '2023-09-29'),
(16, 'BAC-1', 1, 'GUILLE', '', '2 mangas', '', 2, 0, 0, 12, 11, 0, 11, 0, 11, 0, 2, 0, 'S', '', 'Alq. Normal', 'No disponible', 'Sin imagen', '2023-10-06 00:55:13', '2023-10-01'),
(17, 'AC-1', 12, 'GUILLE', '', '2 mangas', '', 2, 0, 0, 12, 11, 0, 16, 0, 0, 0, 2, 0, 'S', '', 'Venta/Alq. Estreno', 'No disponible', 'Sin imagen', '2023-10-06 00:55:13', '2023-10-01'),
(20, 'O-1', 12, 'GUILLE', '', '2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas, 2 mangas,2 mangas, 2 mangas,', '', 20, 0, 0, 12, 12, 0, 0, 0, 0, 0, 4, 0, 'S', '', 'Venta', 'No disponible', 'Sin imagen', '2023-10-08 09:07:19', '2023-10-02'),
(25, 'BA-1', 1, 'rosa', '', '1 manoplas', '', 1, 0, 0, 12, 12, 0, 0, 0, 0, 0, 1, 0, 'M', '', 'Venta', 'No disponible', 'Sin imagen', '2023-10-05 00:39:07', '2023-10-03'),
(26, 'A-1', 3, 'Alejandra te amo', '', '2 manoplas, 1 calzon', 'c ondones', 2, 0, 0, 12, 1, 0, 2, 0, 0, 0, 8, 0, 'M', '', 'Venta/Alq. Estreno', 'No disponible', 'Sin imagen', '2023-10-08 08:37:53', '2023-10-03');

--
-- Disparadores `productos`
--
DELIMITER $$
CREATE TRIGGER `actualizar_codigo_disponible_despues_de_eliminar_producto` AFTER DELETE ON `productos` FOR EACH ROW BEGIN
    DECLARE categoria_producto VARCHAR(10);
    DECLARE codigo_numero INT;
    
    -- Desglosa el código del producto eliminado
    SET categoria_producto = SUBSTRING_INDEX(OLD.codigo_producto, '-', 1);
    SET codigo_numero = CAST(SUBSTRING_INDEX(OLD.codigo_producto, '-', -1) AS UNSIGNED);
    
    -- Actualiza la columna correspondiente en la tabla codigos_disponibles
    CASE categoria_producto
        WHEN 'BA' THEN
            UPDATE codigos_disponibles SET BA = 1 WHERE id = codigo_numero;
        WHEN 'BO' THEN
            UPDATE codigos_disponibles SET BO = 1 WHERE id = codigo_numero;
        WHEN 'A' THEN
            UPDATE codigos_disponibles SET A = 1 WHERE id = codigo_numero;
        WHEN 'O' THEN
            UPDATE codigos_disponibles SET O = 1 WHERE id = codigo_numero;
        WHEN 'M' THEN
            UPDATE codigos_disponibles SET M = 1 WHERE id = codigo_numero;
        WHEN 'H' THEN
            UPDATE codigos_disponibles SET H = 1 WHERE id = codigo_numero;
        WHEN 'BAC' THEN
            UPDATE codigos_disponibles SET BAC = 1 WHERE id = codigo_numero;
        WHEN 'BOC' THEN
            UPDATE codigos_disponibles SET BOC = 1 WHERE id = codigo_numero;
        WHEN 'AC' THEN
            UPDATE codigos_disponibles SET AC = 1 WHERE id = codigo_numero;
        WHEN 'OC' THEN
            UPDATE codigos_disponibles SET OC = 1 WHERE id = codigo_numero;
        WHEN 'MC' THEN
            UPDATE codigos_disponibles SET MC = 1 WHERE id = codigo_numero;
        WHEN 'HC' THEN
            UPDATE codigos_disponibles SET HC = 1 WHERE id = codigo_numero;
        -- Agrega más casos para otras categorías aquí
    END CASE;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_before_insert_productos` BEFORE INSERT ON `productos` FOR EACH ROW BEGIN
    IF NEW.stock_producto = 0 THEN
        SET NEW.estado_producto = 'No disponible';
    ELSE
        SET NEW.estado_producto = 'Disponible';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_before_update_productos` BEFORE UPDATE ON `productos` FOR EACH ROW BEGIN
    IF NEW.stock_producto = 0 THEN
        SET NEW.estado_producto = 'No disponible';
    ELSE
        SET NEW.estado_producto = 'Disponible';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id` int(11) NOT NULL,
  `ruc` varchar(45) DEFAULT NULL,
  `razon_social` varchar(100) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_comprobante`
--

CREATE TABLE `tipo_comprobante` (
  `id` varchar(3) NOT NULL,
  `descripcion` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(100) DEFAULT NULL,
  `apellido_usuario` varchar(100) DEFAULT NULL,
  `usuario` varchar(100) DEFAULT NULL,
  `clave` text DEFAULT NULL,
  `id_perfil_usuario` int(11) DEFAULT NULL,
  `estado` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_usuario`, `apellido_usuario`, `usuario`, `clave`, `id_perfil_usuario`, `estado`) VALUES
(1, 'disfrazarte', 'aqp', 'disfrazarteaqp', '$2a$07$azybxcags23425sdg23sde36WtGucVJqykwP7FyAA8gbfE8IuJ3xu', 1, 1),
(2, 'luis', 'chirinos', 'lgchirinos', '$2a$07$azybxcags23425sdg23sdeQu0jQUbyv3xLPhyzSEtCEyD/tL2/eKy', 2, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_cabecera`
--

CREATE TABLE `venta_cabecera` (
  `nro_boleta` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `subtotal` float NOT NULL,
  `igv` float NOT NULL,
  `total_venta` float DEFAULT NULL,
  `fecha_venta` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `venta_cabecera`
--

INSERT INTO `venta_cabecera` (`nro_boleta`, `descripcion`, `subtotal`, `igv`, `total_venta`, `fecha_venta`) VALUES
('00000003', 'Venta realizada con Nro Boleta: 00000003', 0, 0, 4, '2023-10-04 08:07:09'),
('00000004', 'Venta realizada con Nro Boleta: 00000004', 0, 0, 12, '2023-10-05 00:39:07'),
('00000005', 'Venta realizada con Nro Boleta: 00000005', 0, 0, 24, '2023-10-05 23:06:50'),
('00000006', 'Venta realizada con Nro Boleta: 00000006', 0, 0, 12, '2023-10-05 23:07:15'),
('00000007', 'Venta realizada con Nro Boleta: 00000007', 0, 0, 3, '2023-10-06 00:27:58'),
('00000008', 'Venta realizada con Nro Boleta: 00000008', 0, 0, 27, '2023-10-06 00:54:24'),
('00000009', 'Venta realizada con Nro Boleta: 00000009', 0, 0, 22, '2023-10-06 00:55:13'),
('00000010', 'Venta realizada con Nro Boleta: 00000010', 0, 0, 2, '2023-10-06 21:43:51'),
('00000011', 'Venta realizada con Nro Boleta: 00000011', 0, 0, 2, '2023-10-08 08:37:53'),
('00000012', 'Venta realizada con Nro Boleta: 00000012', 0, 0, 12, '2023-10-08 09:07:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle`
--

CREATE TABLE `venta_detalle` (
  `id` int(11) NOT NULL,
  `nro_boleta` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `codigo_producto` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `cantidad` float NOT NULL,
  `costo_unitario_venta` float DEFAULT NULL,
  `precio_unitario_venta` float DEFAULT NULL,
  `total_venta` float NOT NULL,
  `fecha_venta` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `venta_detalle`
--

INSERT INTO `venta_detalle` (`id`, `nro_boleta`, `codigo_producto`, `cantidad`, `costo_unitario_venta`, `precio_unitario_venta`, `total_venta`, `fecha_venta`) VALUES
(73, '00000218', NULL, 3, 3.25, 4.0625, 12.18, '2022-12-09'),
(74, '00000219', NULL, 1, 0.62, 0.775, 0.77, '2022-12-09'),
(75, '00000219', NULL, 1, 9.8, 12.25, 12.25, '2022-12-09'),
(76, '00000219', NULL, 1, 1, 1.25, 1.25, '2022-12-09'),
(77, '00000220', NULL, 0.5, 3.5, 4.7, 2.35, '2022-12-09'),
(78, '00000221', NULL, 0.25, 3.5, 4.7, 1.18, '2022-12-09'),
(79, '00000222', NULL, 1, 3.4, 4.25, 4.25, '2022-12-10'),
(80, '00000222', NULL, 1, 9.8, 12.25, 12.25, '2022-12-10'),
(81, '00000222', NULL, 1, 3.5, 4.7, 4.7, '2022-12-10'),
(82, '00000223', NULL, 3, 0.67, 0.8375, 2.52, '2022-12-10'),
(83, '00000224', NULL, 1, 3.5, 4.7, 4.7, '2022-12-10'),
(84, '00000225', NULL, 1, 0.67, 0.8375, 0.84, '2022-12-10'),
(85, '00000226', NULL, 1, 3.5, 4.7, 4.7, '2022-12-11'),
(86, '00000226', NULL, 1, 3.25, 4.0625, 4.06, '2022-12-11'),
(87, '00000227', NULL, 5, 18.29, 22.8625, 114.3, '2022-12-11'),
(88, '00000228', NULL, 10, 1.06, 1.325, 13.3, '2022-12-11'),
(89, '00000229', NULL, 0.25, 3, 4.5, 1.13, '2022-12-11'),
(90, '00000230', NULL, 1, 5.9, 7.375, 7.38, '2022-12-12'),
(91, '00000230', NULL, 1, 2.6, 3.25, 3.25, '2022-12-12'),
(92, '00000230', NULL, 1, 9.8, 12.25, 12.25, '2022-12-12'),
(93, '00000231', NULL, 3, 3.5, 4.375, 13.14, '2022-12-12'),
(94, '00000231', NULL, 1, 3.65, 4.5625, 4.56, '2022-12-12'),
(95, '00000231', NULL, 1, 3.25, 4.0625, 4.06, '2022-12-12'),
(96, '00000232', NULL, 1, 3.25, 4.0625, 4.06, '2022-12-12'),
(97, '00000233', NULL, 1, 0.5, 0.625, 0.62, '2022-12-14'),
(98, '00000233', NULL, 1, 0.33, 0.4125, 0.41, '2022-12-14'),
(99, '00000233', NULL, 1, 5.9, 7.375, 7.38, '2022-12-14'),
(100, '00000233', NULL, 1, 3.25, 4.0625, 4.06, '2022-12-14'),
(101, '00000233', NULL, 1, 9.8, 12.25, 12.25, '2022-12-14'),
(102, '00000234', NULL, 1, 18.29, 22.8625, 22.86, '2022-12-14'),
(103, '00000234', NULL, 1, 0.47, 0.5875, 0.59, '2022-12-14'),
(104, '00000234', NULL, 1, 3.4, 4.25, 4.25, '2022-12-14'),
(105, '00000234', NULL, 1, 1.5, 1.875, 1.88, '2022-12-14'),
(106, '00000235', NULL, 1, 9.8, 12.25, 12.25, '2022-12-16'),
(107, '00000235', NULL, 1, 3.25, 4.0625, 4.06, '2022-12-16'),
(108, '00000235', NULL, 1, 1, 1.25, 1.25, '2022-12-16'),
(109, '00000235', NULL, 1, 2.6, 3.25, 3.25, '2022-12-16'),
(110, '00000235', NULL, 1, 2, 3.5, 3.5, '2022-12-16'),
(111, '00000236', NULL, 5, 1.5, 1.875, 9.4, '2022-12-16'),
(112, '00000236', NULL, 5, 0.9, 1.125, 5.6, '2022-12-16'),
(113, '00000237', NULL, 1, 3.25, 4.0625, 4.06, '2022-12-17'),
(114, '00000237', NULL, 1, 3.4, 4.25, 4.25, '2022-12-17'),
(115, '00000238', NULL, 1, 3, 3.75, 3.75, '2022-12-17'),
(116, '00000238', NULL, 0.25, 2, 3.5, 0.88, '2022-12-17'),
(117, '00000239', NULL, 6, 5.9, 7.375, 44.28, '2022-12-19'),
(118, '00000239', NULL, 1, 3.25, 4.0625, 4.06, '2022-12-19'),
(119, '00000239', NULL, 5, 3.2, 4, 20, '2022-12-19'),
(120, '00000239', NULL, 1, 1.5, 1.875, 1.88, '2022-12-19'),
(121, '00000240', NULL, 4, 18.29, 22.8625, 91.44, '2022-12-21'),
(122, '00000241', NULL, 2, 5.9, 7.375, 14.76, '2022-12-21'),
(142, '00000003', 'A-1', 2, NULL, NULL, 4, '0000-00-00'),
(143, '00000004', 'BA-1', 1, NULL, NULL, 12, '0000-00-00'),
(144, '00000005', 'O-1', 2, NULL, NULL, 24, '0000-00-00'),
(145, '00000006', 'O-1', 1, NULL, NULL, 12, '0000-00-00'),
(146, '00000007', 'A-1', 3, NULL, NULL, 3, '0000-00-00'),
(147, '00000008', 'BAC-1', 1, NULL, NULL, 11, '0000-00-00'),
(148, '00000008', 'AC-1', 1, NULL, NULL, 16, '0000-00-00'),
(149, '00000009', 'BAC-1', 1, NULL, NULL, 11, '0000-00-00'),
(150, '00000009', 'AC-1', 1, NULL, NULL, 11, '0000-00-00'),
(151, '00000010', 'A-1', 1, NULL, NULL, 2, '0000-00-00'),
(152, '00000011', 'A-1', 1, NULL, NULL, 2, '0000-00-00'),
(153, '00000012', 'O-1', 1, NULL, NULL, 12, '0000-00-00');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `arqueo_caja`
--
ALTER TABLE `arqueo_caja`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_id_caja_idx` (`id_caja`),
  ADD KEY `fk_id_usuario_idx` (`id_usuario`);

--
-- Indices de la tabla `cajas`
--
ALTER TABLE `cajas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `codigos_disponibles`
--
ALTER TABLE `codigos_disponibles`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_id_proveedor_idx` (`id_proveedor`),
  ADD KEY `fk_id_comprobante_idx` (`id_tipo_comprobante`),
  ADD KEY `fk_id_moneda_idx` (`id_moneda_comprobante`);

--
-- Indices de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_cod_producto_idx` (`codigo_producto`),
  ADD KEY `fk_id_compra_idx` (`id_compra`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`id_empresa`);

--
-- Indices de la tabla `kardex`
--
ALTER TABLE `kardex`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_id_producto_idx` (`codigo_producto`);

--
-- Indices de la tabla `modulos`
--
ALTER TABLE `modulos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `monedas`
--
ALTER TABLE `monedas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  ADD PRIMARY KEY (`id_perfil`);

--
-- Indices de la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  ADD PRIMARY KEY (`idperfil_modulo`),
  ADD KEY `id_perfil` (`id_perfil`),
  ADD KEY `id_modulo` (`id_modulo`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id_producto`),
  ADD UNIQUE KEY `codigo_producto_UNIQUE` (`codigo_producto`),
  ADD KEY `fk_id_categoria_idx` (`id_categoria_producto`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tipo_comprobante`
--
ALTER TABLE `tipo_comprobante`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `id_perfil_usuario` (`id_perfil_usuario`);

--
-- Indices de la tabla `venta_cabecera`
--
ALTER TABLE `venta_cabecera`
  ADD PRIMARY KEY (`nro_boleta`);

--
-- Indices de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_nro_boleta_idx` (`nro_boleta`),
  ADD KEY `fk_cod_producto_idx` (`codigo_producto`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `arqueo_caja`
--
ALTER TABLE `arqueo_caja`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cajas`
--
ALTER TABLE `cajas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3556;

--
-- AUTO_INCREMENT de la tabla `codigos_disponibles`
--
ALTER TABLE `codigos_disponibles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1520;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `id_empresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `kardex`
--
ALTER TABLE `kardex`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5463;

--
-- AUTO_INCREMENT de la tabla `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `monedas`
--
ALTER TABLE `monedas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `perfiles`
--
ALTER TABLE `perfiles`
  MODIFY `id_perfil` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  MODIFY `idperfil_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=154;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `arqueo_caja`
--
ALTER TABLE `arqueo_caja`
  ADD CONSTRAINT `fk_id_caja` FOREIGN KEY (`id_caja`) REFERENCES `cajas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_id_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `fk_id_comprobante` FOREIGN KEY (`id_tipo_comprobante`) REFERENCES `tipo_comprobante` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_id_moneda` FOREIGN KEY (`id_moneda_comprobante`) REFERENCES `monedas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_id_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD CONSTRAINT `fk_cod_producto` FOREIGN KEY (`codigo_producto`) REFERENCES `productos` (`codigo_producto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_id_compra` FOREIGN KEY (`id_compra`) REFERENCES `compras` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `kardex`
--
ALTER TABLE `kardex`
  ADD CONSTRAINT `fk_cod_producto_kardex` FOREIGN KEY (`codigo_producto`) REFERENCES `productos` (`codigo_producto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `perfil_modulo`
--
ALTER TABLE `perfil_modulo`
  ADD CONSTRAINT `id_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `id_perfil` FOREIGN KEY (`id_perfil`) REFERENCES `perfiles` (`id_perfil`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_perfil_usuario`) REFERENCES `perfiles` (`id_perfil`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
