<?php

require_once "conexion.php";

class VentasModelo
{

    public $resultado;

    static public function mdlObtenerNroBoleta()
    {

        $stmt = Conexion::conectar()->prepare("call prc_obtenerNroBoleta()");

        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_OBJ);
    }

    static public function mdlRegistrarVenta($datos, $nro_boleta, $descripcion_venta, $sub_total_venta, $igv_venta, $total_venta)
    {

        $stmt = Conexion::conectar()->prepare("INSERT INTO venta_cabecera(
                                                nro_boleta, 
                                                descripcion, 
                                                subtotal, 
                                                igv, 
                                                total_venta)         
                                                VALUES(
                                                    :nro_boleta,
                                                    :descripcion, 
                                                    :subtotal, 
                                                    :igv, 
                                                    :total_venta)");

        $stmt->bindParam(":nro_boleta", $nro_boleta, PDO::PARAM_STR);
        $stmt->bindParam(":descripcion", $descripcion_venta, PDO::PARAM_STR);
        $stmt->bindParam(":subtotal", $sub_total_venta, PDO::PARAM_STR);
        $stmt->bindParam(":igv", $igv_venta, PDO::PARAM_STR);
        $stmt->bindParam(":total_venta", $total_venta, PDO::PARAM_STR);
        


        if ($stmt->execute()) {

            $stmt = null;

            $stmt = Conexion::conectar()->prepare("UPDATE empresa SET nro_correlativo_venta = LPAD(nro_correlativo_venta + 1,8,'0')");

            if ($stmt->execute()) {

                $listaProductos = [];

                for ($i = 0; $i < count($datos); ++$i) {

                    $listaProductos = explode(",", $datos[$i]);

                    $stmt = Conexion::conectar()->prepare("INSERT INTO venta_detalle(
                                                            nro_boleta,
                                                            codigo_producto, 
                                                            cantidad,
                                                            precio_unitario_venta, 
                                                            total_venta) 
                                                        
                                                        VALUES(
                                                            :nro_boleta,
                                                            :codigo_producto,
                                                            :cantidad, 
                                                            :precio_unitario_venta,
                                                            :total_venta)");

                    $stmt->bindParam(":nro_boleta", $nro_boleta, PDO::PARAM_STR);
                    $stmt->bindParam(":codigo_producto", $listaProductos[0], PDO::PARAM_STR);
                    $stmt->bindParam(":cantidad", $listaProductos[1], PDO::PARAM_STR);
                    $stmt->bindParam(":precio_unitario_venta", $listaProductos[2], PDO::PARAM_STR);
                    $stmt->bindParam(":total_venta", $listaProductos[3], PDO::PARAM_STR);



                    if ($stmt->execute()) {

                        $stmt = null;

                        $stmt = Conexion::conectar()->prepare("UPDATE productos SET stock_producto = stock_producto - :cantidad, numero_ventas_producto = numero_ventas_producto + :cantidad
                                                                WHERE codigo_producto = :codigo_producto");

                        $stmt->bindParam(":codigo_producto", $listaProductos[0], PDO::PARAM_STR);
                        $stmt->bindParam(":cantidad", $listaProductos[1], PDO::PARAM_STR);

                        if ($stmt->execute()) {
                            $resultado = "Se registró la venta correctamente.";
                        } else {
                            $resultado = "Error al actualizar el stock";
                        }
                    } else {
                        $resultado = "Error al registrar la venta";
                    }
                }


                return $resultado;

                $stmt = null;
            }
        }
    }
/*
SELECT Concat('Boleta Nro: ',v.nro_boleta,' - Total Venta: S./ ',Round(vc.total_venta,2)) as nro_boleta,
                v.codigo_producto,
                c.nombre_categoria,
                p.nombre_producto,
                v.cantidad as cantidad,                            
                concat('S./ ',round(v.total_venta,2)) as total_venta,
                v.fecha_venta
                FROM venta_detalle v inner join productos p on v.codigo_producto = p.codigo_producto
                                    inner join venta_cabecera vc on cast(vc.nro_boleta as integer) = cast(v.nro_boleta as integer)
                                    inner join categorias c on c.id_categoria = p.id_categoria_producto
        where DATE(v.fecha_venta) >= date(:fechaDesde) and DATE(v.fecha_venta) <= date(:fechaHasta)
        order by v.nro_boleta asc
*/


    static public function mdlListarVentas($fechaDesde,$fechaHasta){

        try {
            
            $stmt = Conexion::conectar()->prepare("SELECT 
            CONCAT('Boleta Nro: ', v.nro_boleta, ' - Total Venta: S./ ', ROUND(vc.total_venta, 2)) AS boleta_info,
            v.codigo_producto,
            c.nombre_categoria,
            p.nombre_producto,
            v.cantidad,
            CONCAT('S./ ', ROUND(v.total_venta, 2)) AS total_venta,
            vc.fecha_venta
        FROM 
            venta_detalle v
        INNER JOIN 
            productos p ON v.codigo_producto = p.codigo_producto
        INNER JOIN 
            venta_cabecera vc ON CAST(vc.nro_boleta AS INTEGER) = CAST(v.nro_boleta AS INTEGER)
        INNER JOIN 
            categorias c ON c.id_categoria = p.id_categoria_producto
        WHERE 
            DATE(vc.fecha_venta) BETWEEN :fechaDesde AND :fechaHasta  -- Rango de fechas
        ORDER BY 
            vc.nro_boleta ASC;
        ");

            $stmt -> bindParam(":fechaDesde",$fechaDesde,PDO::PARAM_STR);
            $stmt -> bindParam(":fechaHasta",$fechaHasta,PDO::PARAM_STR);

            $stmt -> execute();

            return $stmt->fetchAll();
            
        } catch (Exception $e) {
            return 'Excepción capturada: '.  $e->getMessage(). "\n";
        }
        

        $stmt = null;
    }

    static public function mdlObtenerDetalleVenta($nro_boleta){

        try {
            
            $stmt = Conexion::conectar()->prepare("select concat('B001-',vc.nro_boleta) as nro_boleta,
                                                        vc.total_venta,
                                                        vc.fecha_venta,
                                                        vd.codigo_producto,
                                                        upper(p.descripcion_producto) as descripcion_producto,
                                                        vd.cantidad,
                                                        vd.precio_unitario_venta,
                                                        vd.total_venta
                                                from venta_cabecera vc inner join venta_detalle vd on vc.nro_boleta = vd.nro_boleta
                                                                        inner join productos p on p.codigo_producto = vd.codigo_producto
                                                where vc.nro_boleta =  :nro_boleta");

            $stmt -> bindParam(":nro_boleta",$nro_boleta,PDO::PARAM_STR);

            $stmt -> execute();

            return $stmt->fetchAll();
            
        } catch (Exception $e) {
            return 'Excepción capturada: '.  $e->getMessage(). "\n";
        }

    }
}