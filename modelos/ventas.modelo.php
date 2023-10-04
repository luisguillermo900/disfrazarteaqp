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

    static public function mdlRegistrarVenta($datos, $nro_boleta, $total_venta, $descripcion_venta)
    {

        $stmt = Conexion::conectar()->prepare("INSERT INTO venta_cabecera(nro_boleta,descripcion,total_venta)         
                                                VALUES(:nro_boleta,:descripcion,:total_venta)");

        $stmt->bindParam(":nro_boleta", $nro_boleta, PDO::PARAM_STR);
        $stmt->bindParam(":descripcion", $descripcion_venta, PDO::PARAM_STR);
        $stmt->bindParam(":total_venta", $total_venta, PDO::PARAM_STR);


        if ($stmt->execute()) {

            $stmt = null;

            $stmt = Conexion::conectar()->prepare("UPDATE empresa SET nro_correlativo_venta = LPAD(nro_correlativo_venta + 1,8,'0')");

            if ($stmt->execute()) {

                $listaProductos = [];

                for ($i = 0; $i < count($datos); ++$i) {

                    $listaProductos = explode(",", $datos[$i]);

                    $stmt = Conexion::conectar()->prepare("INSERT INTO venta_detalle(nro_boleta,codigo_producto, cantidad, total_venta) 
                                                        VALUES(:nro_boleta,:codigo_producto,:cantidad,:total_venta)");

                    $stmt->bindParam(":nro_boleta", $nro_boleta, PDO::PARAM_STR);
                    $stmt->bindParam(":codigo_producto", $listaProductos[0], PDO::PARAM_STR);
                    $stmt->bindParam(":cantidad", $listaProductos[1], PDO::PARAM_STR);
                    $stmt->bindParam(":total_venta", $listaProductos[2], PDO::PARAM_STR);



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
}
