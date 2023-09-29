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
    LISTA LAS TALLAS DE PRODUCTOS
    ====================================================================*/
    static public function mdlListarTallasProductos(){

        $stmt = Conexion::conectar()->prepare("SELECT talla_producto FROM productos");

        $stmt -> execute();

        return $stmt->fetchAll();
    }

    /*===================================================================
    REGISTRAR PRODUCTOS UNO A UNO DESDE EL FORMULARIO DEL INVENTARIO
    ====================================================================*/
    static public function mdlRegistrarProducto($id_categoria_producto,$nombre_producto,$incluye_producto,
                                                $no_incluye_producto,$numero_piezas_producto,$stock_producto,$precio_compra_producto,$precio_venta_producto,
                                                $utilidad_venta_producto,$precio_alquiler_estreno_producto,$utilidad_alquiler_estreno_producto,$precio_alquiler_simple_producto,$utilidad_alquiler_simple_producto,
                                                $talla_producto,$marca_producto,$modalidad,$estado_producto){        

        try{

            $fecha = date('Y-m-d');

                
            $stmt = Conexion::conectar()->prepare("
            SET @genero_disponible = (SELECT categorias.genero_categoria FROM categorias WHERE categorias.id_categoria = :id_categoria_producto);
            SET @codigo_disponible = obtener_y_marcar_codigo_disponible(@genero_disponible);
                                                INSERT INTO PRODUCTOS(
                                                                        codigo_producto,
                                                                        id_categoria_producto, 
                                                                        nombre_producto,
                                                                        incluye_producto,
                                                                        no_incluye_producto,
                                                                        numero_piezas_producto,
                                                                        stock_producto,
                                                                        precio_compra_producto,
                                                                        precio_venta_producto,
                                                                        utilidad_venta_producto,
                                                                        precio_alquiler_estreno_producto,
                                                                        utilidad_alquiler_estreno_producto,
                                                                        precio_alquiler_simple_producto,
                                                                        utilidad_alquiler_simple_producto,
                                                                        talla_producto,
                                                                        marca_producto,
                                                                        modalidad,
                                                                        estado_producto,
                                                                        fecha_creacion_producto,
                                                                        fecha_actualizacion_producto) 
                                                VALUES ( 
                                                        @codigo_disponible,
                                                        :id_categoria_producto, 
                                                        :nombre_producto, 
                                                        :incluye_producto, 
                                                        :no_incluye_producto, 
                                                        :numero_piezas_producto, 
                                                        :stock_producto, 
                                                        :precio_compra_producto, 
                                                        :precio_venta_producto,
                                                        :utilidad_venta_producto,
                                                        :precio_alquiler_estreno_producto,
                                                        :utilidad_alquiler_estreno_producto,
                                                        :precio_alquiler_simple_producto,
                                                        :utilidad_alquiler_simple_producto,
                                                        :talla_producto,
                                                        :marca_producto,
                                                        :modalidad,
                                                        :estado_producto,
                                                        :fecha_creacion_producto,
                                                        :fecha_actualizacion_producto)");      
                                                        
            
            $stmt -> bindParam(":id_categoria_producto", $id_categoria_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":nombre_producto", $nombre_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":incluye_producto", $incluye_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":no_incluye_producto", $no_incluye_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":numero_piezas_producto", $numero_piezas_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":stock_producto", $stock_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":precio_compra_producto", $precio_compra_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":precio_venta_producto", $precio_venta_producto , PDO::PARAM_STR);                                                    
            $stmt -> bindParam(":utilidad_venta_producto", $utilidad_venta_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":precio_alquiler_estreno_producto", $precio_alquiler_estreno_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":utilidad_alquiler_estreno_producto", $utilidad_alquiler_estreno_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":precio_alquiler_simple_producto", $precio_alquiler_simple_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":utilidad_alquiler_simple_producto", $utilidad_alquiler_simple_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":talla_producto", $talla_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":marca_producto", $marca_producto , PDO::PARAM_STR);
            $stmt -> bindParam(":modalidad", $modalidad , PDO::PARAM_STR);
            $stmt -> bindParam(":estado_producto", $estado_producto , PDO::PARAM_STR);
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
