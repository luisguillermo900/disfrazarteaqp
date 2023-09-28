<?php

require_once "conexion.php";

class ProductosModelo{
    /*===================================================================
    OBTENER LISTADO TOTAL DE PRODUCTOS PARA EL DATATABLE
    ====================================================================*/
    static public function mdlListarProductos(){
    
        $stmt = Conexion::conectar()->prepare('call prc_ListarProductos');
    
        $stmt->execute();
    
        return $stmt->fetchAll();
    }

    /*===================================================================
    BUSCAR EL ID DE UNA CATEGORIA POR EL NOMBRE DE LA CATEGORIA
    ====================================================================*/
    static public function mdlBuscarIdCategoria($nombreCategoria){

        $stmt = Conexion::conectar()->prepare("select id_categoria from categorias where nombre_categoria = :nombreCategoria");
        $stmt -> bindParam(":nombreCategoria", $nombreCategoria,PDO::PARAM_STR);
        $stmt->execute();

        return $stmt->fetch();

    }

    /*===================================================================
    REGISTRAR PRODUCTOS UNO A UNO DESDE EL FORMULARIO DEL INVENTARIO
    ====================================================================*/
    static public function mdlRegistrarProducto($codigo_producto, $id_categoria_producto,$descripcion_producto,$precio_compra_producto,
                                                $precio_venta_producto,$utilidad,$stock_producto,$minimo_stock_producto,$ventas_producto){        

        try{

            $fecha = date('Y-m-d');

            $stmt = Conexion::conectar()->prepare("INSERT INTO PRODUCTOS(codigo_producto, 
                                                                        id_categoria_producto, 
                                                                        descripcion_producto, 
                                                                        precio_compra_producto, 
                                                                        precio_venta_producto, 
                                                                        utilidad, 
                                                                        stock_producto, 
                                                                        minimo_stock_producto, 
                                                                        ventas_producto,
                                                                        fecha_creacion_producto,
                                                                        fecha_actualizacion_producto) 
                                                VALUES (:codigo_producto, 
                                                        :id_categoria_producto, 
                                                        :descripcion_producto, 
                                                        :precio_compra_producto, 
                                                        :precio_venta_producto, 
                                                        :utilidad, 
                                                        :stock_producto, 
                                                        :minimo_stock_producto, 
                                                        :ventas_producto,
                                                        :fecha_creacion_producto,
                                                        :fecha_actualizacion_producto)");      
                                                        
            $stmt -> bindParam(":codigo_producto", $codigo_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":id_categoria_producto", $id_categoria_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":descripcion_producto", $descripcion_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":precio_compra_producto", $precio_compra_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":precio_venta_producto", $precio_venta_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":utilidad", $utilidad , PDO::PARAM_STR);
            $stmt -> bindParam(":stock_producto", $stock_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":minimo_stock_producto", $minimo_stock_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":ventas_producto", $ventas_producto , PDO::PARAM_STR);                                                    
            $stmt -> bindParam(":fecha_creacion_producto", $fecha , PDO::PARAM_STR);
            $stmt -> bindParam(":fecha_actualizacion_producto", $fecha , PDO::PARAM_STR);
        
            if($stmt -> execute()){
                $resultado = "ok";
            }else{
                $resultado = "error";
            }  
        }catch (Exception $e) {
            $resultado = 'Excepción capturada: '.  $e->getMessage(). "\n";
        }
        
        return $resultado;

        $stmt = null;

    }
}
?>