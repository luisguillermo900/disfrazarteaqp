<?php

require_once "conexion.php";

class ProductosModelo
{
    /*===================================================================
    OBTENER LISTADO TOTAL DE PRODUCTOS PARA EL DATATABLE
    ====================================================================*/
    static public function mdlListarProductos()
    {

        $stmt = Conexion::conectar()->prepare('call prc_ListarProductos');

        $stmt->execute();

        return $stmt->fetchAll();
    }

    /*===================================================================
    BUSCAR EL ID DE UNA CATEGORIA POR EL NOMBRE DE LA CATEGORIA
    ====================================================================*/
    static public function mdlBuscarIdCategoria($nombreCategoria)
    {

        $stmt = Conexion::conectar()->prepare("select id_categoria from categorias where nombre_categoria = :nombreCategoria");
        $stmt->bindParam(":nombreCategoria", $nombreCategoria, PDO::PARAM_STR);
        $stmt->execute();

        return $stmt->fetch();
    }
    /*===================================================================
    LISTA LAS TALLAS DE PRODUCTOS
    ====================================================================*/
    static public function mdlListarTallasProductos()
    {

        $stmt = Conexion::conectar()->prepare("SELECT talla_producto FROM productos");

        $stmt->execute();

        return $stmt->fetchAll();
    }

    /*===================================================================
    REGISTRAR PRODUCTOS UNO A UNO DESDE EL FORMULARIO DEL INVENTARIO
    ====================================================================*/
    static public function mdlRegistrarProducto(
        $id_categoria_producto,
        $nombre_producto,
        $descripcion_producto,
        $incluye_producto,
        $no_incluye_producto,
        $numero_piezas_producto,
        $stock_producto,
        $precio_compra_producto,
        $precio_venta_producto,
        $utilidad_venta_producto,
        $precio_alquiler_estreno_producto,
        $utilidad_alquiler_estreno_producto,
        $precio_alquiler_simple_producto,
        $utilidad_alquiler_simple_producto,
        $talla_producto,
        $marca_producto,
        $modalidad,
        $estado_producto,
        $imagen_producto
    ) {

        try {

            $fecha = date('Y-m-d');


            $stmt = Conexion::conectar()->prepare("
            SET @genero_disponible = (SELECT categorias.genero_categoria FROM categorias WHERE categorias.id_categoria = :id_categoria_producto);
            SET @codigo_disponible = obtener_y_marcar_codigo_disponible(@genero_disponible);
                                                INSERT INTO PRODUCTOS(
                                                                        codigo_producto,
                                                                        id_categoria_producto, 
                                                                        nombre_producto,
                                                                        descripcion_producto,
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
                                                                        imagen_producto,
                                                                        fecha_creacion_producto,
                                                                        fecha_actualizacion_producto) 
                                                VALUES ( 
                                                        @codigo_disponible,
                                                        :id_categoria_producto, 
                                                        :nombre_producto, 
                                                        :descripcion_producto,
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
                                                        :imagen_producto,
                                                        :fecha_creacion_producto,
                                                        :fecha_actualizacion_producto)");


            $stmt->bindParam(":id_categoria_producto", $id_categoria_producto, PDO::PARAM_STR);
            $stmt->bindParam(":nombre_producto", $nombre_producto, PDO::PARAM_STR);
            $stmt->bindParam(":descripcion_producto", $descripcion_producto, PDO::PARAM_STR);
            $stmt->bindParam(":incluye_producto", $incluye_producto, PDO::PARAM_STR);
            $stmt->bindParam(":no_incluye_producto", $no_incluye_producto, PDO::PARAM_STR);
            $stmt->bindParam(":numero_piezas_producto", $numero_piezas_producto, PDO::PARAM_STR);
            $stmt->bindParam(":stock_producto", $stock_producto, PDO::PARAM_STR);
            $stmt->bindParam(":precio_compra_producto", $precio_compra_producto, PDO::PARAM_STR);
            $stmt->bindParam(":precio_venta_producto", $precio_venta_producto, PDO::PARAM_STR);
            $stmt->bindParam(":utilidad_venta_producto", $utilidad_venta_producto, PDO::PARAM_STR);
            $stmt->bindParam(":precio_alquiler_estreno_producto", $precio_alquiler_estreno_producto, PDO::PARAM_STR);
            $stmt->bindParam(":utilidad_alquiler_estreno_producto", $utilidad_alquiler_estreno_producto, PDO::PARAM_STR);
            $stmt->bindParam(":precio_alquiler_simple_producto", $precio_alquiler_simple_producto, PDO::PARAM_STR);
            $stmt->bindParam(":utilidad_alquiler_simple_producto", $utilidad_alquiler_simple_producto, PDO::PARAM_STR);
            $stmt->bindParam(":talla_producto", $talla_producto, PDO::PARAM_STR);
            $stmt->bindParam(":marca_producto", $marca_producto, PDO::PARAM_STR);
            $stmt->bindParam(":modalidad", $modalidad, PDO::PARAM_STR);
            $stmt->bindParam(":estado_producto", $estado_producto, PDO::PARAM_STR);
            $stmt->bindParam(":imagen_producto", $imagen_producto["nuevoNombre"], PDO::PARAM_STR);
            $stmt->bindParam(":fecha_creacion_producto", $fecha, PDO::PARAM_STR);
            $stmt->bindParam(":fecha_actualizacion_producto", $fecha, PDO::PARAM_STR);

            if ($stmt->execute()) {

                //GUARDAMOS LA IMAGEN EN LA CARPETA
                if ($imagen_producto) {

                    $guardarImagen = new ProductosModelo();

                    $guardarImagen->guardarImagen($imagen_producto["folder"], $imagen_producto["ubicacionTemporal"], $imagen_producto["nuevoNombre"]);
                }else {
                    // Manejo de error: No se proporcionó una imagen válida
                    $resultado = "error";
                    $mensajeError = "No se proporcionó una imagen válida.";
                    
                }

                if ($stmt->execute()) {
                    $resultado = "ok";
                } else {
                    $resultado = "error";
                }
            } else {
                $resultado = "error";
            }
        } catch (Exception $e) {
            $resultado = 'Excepción capturada: ' .  $e->getMessage() . "\n";
        }

        return $resultado;

        $stmt = null;
    }

    static public function mdlActualizarInformacion(
        $codigo_producto,
        $nombre_producto,
        $id_categoria_producto,
        $descripcion_producto,
        $numero_piezas_producto,
        $stock_producto,
        $talla_producto,
        $incluye_producto,
        $no_incluye_producto,
        $marca_producto,
        $estado_producto,
        $modalidad,
        $precio_compra_producto,
        $precio_venta_producto,
        $utilidad_venta_producto,
        $precio_alquiler_estreno_producto,
        $utilidad_alquiler_estreno_producto,
        $precio_alquiler_simple_producto,
        $utilidad_alquiler_simple_producto
    ) {
        try {
            $stmt = Conexion::conectar()->prepare("UPDATE productos SET
            nombre_producto = :nombre_producto,
            id_categoria_producto = :id_categoria_producto,
            descripcion_producto = :descripcion_producto,
            numero_piezas_producto = :numero_piezas_producto,
            stock_producto = :stock_producto,
            talla_producto = :talla_producto,
            incluye_producto = :incluye_producto,
            no_incluye_producto = :no_incluye_producto,
            marca_producto = :marca_producto,
            estado_producto = :estado_producto,
            modalidad = :modalidad,
            precio_compra_producto = :precio_compra_producto,
            precio_venta_producto = :precio_venta_producto,
            utilidad_venta_producto = :utilidad_venta_producto,
            precio_alquiler_estreno_producto = :precio_alquiler_estreno_producto,
            utilidad_alquiler_estreno_producto = :utilidad_alquiler_estreno_producto,
            precio_alquiler_simple_producto = :precio_alquiler_simple_producto,
            utilidad_alquiler_simple_producto = :utilidad_alquiler_simple_producto
            WHERE codigo_producto = :codigo_producto");

            // Vincular los valores de los parámetros
            $stmt->bindParam(":codigo_producto", $codigo_producto, PDO::PARAM_STR);
            $stmt->bindParam(":nombre_producto", $nombre_producto, PDO::PARAM_STR);
            $stmt->bindParam(":id_categoria_producto", $id_categoria_producto, PDO::PARAM_INT);
            $stmt->bindParam(":descripcion_producto", $descripcion_producto, PDO::PARAM_STR);
            $stmt->bindParam(":numero_piezas_producto", $numero_piezas_producto, PDO::PARAM_INT);
            $stmt->bindParam(":stock_producto", $stock_producto, PDO::PARAM_STR);
            $stmt->bindParam(":talla_producto", $talla_producto, PDO::PARAM_STR);
            $stmt->bindParam(":incluye_producto", $incluye_producto, PDO::PARAM_STR);
            $stmt->bindParam(":no_incluye_producto", $no_incluye_producto, PDO::PARAM_STR);
            $stmt->bindParam(":marca_producto", $marca_producto, PDO::PARAM_STR);
            $stmt->bindParam(":estado_producto", $estado_producto, PDO::PARAM_STR);
            $stmt->bindParam(":modalidad", $modalidad, PDO::PARAM_STR);

            $stmt->bindParam(":precio_compra_producto", $precio_compra_producto, PDO::PARAM_STR);
            $stmt->bindParam(":precio_venta_producto", $precio_venta_producto, PDO::PARAM_STR);
            $stmt->bindParam(":utilidad_venta_producto", $utilidad_venta_producto, PDO::PARAM_STR);
            $stmt->bindParam(":precio_alquiler_estreno_producto", $precio_alquiler_estreno_producto, PDO::PARAM_STR);
            $stmt->bindParam(":utilidad_alquiler_estreno_producto", $utilidad_alquiler_estreno_producto, PDO::PARAM_STR);
            $stmt->bindParam(":precio_alquiler_simple_producto", $precio_alquiler_simple_producto, PDO::PARAM_STR);
            $stmt->bindParam(":utilidad_alquiler_simple_producto", $utilidad_alquiler_simple_producto, PDO::PARAM_STR);

            if ($stmt->execute()) {
                $resultado = "ok";
            } else {
                $resultado = "error";
            }
        } catch (Exception $e) {
            echo 'Excepción capturada: ' . $e->getMessage() . "\n";
        }
        return $resultado;

        $stmt = null;
    }

    /*=============================================
    Peticion DELETE para eliminar datos
    =============================================*/

    static public function mdlEliminarInformacion($codigo_producto)
    {

        $stmt = Conexion::conectar()->prepare("DELETE FROM productos WHERE codigo_producto = :codigo_producto");

        $stmt->bindParam(":codigo_producto", $codigo_producto, PDO::PARAM_STR);


        if ($stmt->execute()) {

            return "ok";;
        } else {

            return Conexion::conectar()->errorInfo();
        }
    }

    /*===================================================================
    LISTAR NOMBRE DE PRODUCTOS PARA INPUT DE AUTO COMPLETADO
    SELECT Concat(codigo_producto , ' - ' ,c.nombre_categoria,' - ',nombre_producto
                                                , ' - S./ ' , p.precio_venta_producto
                                                , ' - S./ ' , p.precio_alquiler_estreno_producto
                                                , ' - S./ ' , p.precio_alquiler_simple_producto)  as descripcion_producto
                                                FROM productos p inner join categorias c on p.id_categoria_producto = c.id_categoria
    ====================================================================*/
    static public function mdlListarNombreProductos()
    {

        $stmt = Conexion::conectar()->prepare("SELECT codigo_producto as descripcion_producto
                                                FROM productos");

        $stmt->execute();

        return $stmt->fetchAll();
    }

    /*===================================================================
    BUSCAR PRODUCTO POR SU CODIGO DE BARRAS
    CONCAT('S./ ', CONVERT(ROUND(precio_alquiler_estreno_producto, 2), CHAR)) as precio_alquiler_estreno_producto,
    CONCAT('S./ ', CONVERT(ROUND(1 * precio_alquiler_estreno_producto, 2), CHAR)) as total_alquiler_estreno_producto,
    CONCAT('S./ ', CONVERT(ROUND(precio_alquiler_simple_producto, 2), CHAR)) as precio_alquiler_simple_producto,
    CONCAT('S./ ', CONVERT(ROUND(1 * precio_alquiler_simple_producto, 2), CHAR)) as total_alquiler_simple_producto,
    ====================================================================*/
    static public function mdlGetDatosProducto($codigoProducto)
    {

        $stmt = Conexion::conectar()->prepare("
        
        SELECT   
            codigo_producto,                                        
            c.nombre_categoria,
            nombre_producto,
            talla_producto,
            CONCAT('S./ ', CONVERT(ROUND(precio_venta_producto, 2), CHAR)) as precio_venta_producto,
            CONCAT('S./ ', CONVERT(ROUND(precio_alquiler_estreno_producto, 2), CHAR)) as precio_alquiler_estreno_producto,
            CONCAT('S./ ', CONVERT(ROUND(precio_alquiler_simple_producto, 2), CHAR)) as precio_alquiler_simple_producto,
            '1' as cantidad,
            'S./ 0.00' as precio_unitario,
            CASE 
                WHEN p.modalidad = 'venta' THEN CONCAT('S./ ', CONVERT(ROUND(1*precio_venta_producto, 2), CHAR))
                WHEN p.modalidad = 'Alq. Normal' THEN CONCAT('S./ ', CONVERT(ROUND(1*precio_alquiler_simple_producto, 2), CHAR))
                ELSE 'S./ 0.00'
            END as total,
            '' as acciones,
            p.modalidad
        FROM productos p 
        INNER JOIN categorias c ON p.id_categoria_producto = c.id_categoria
        WHERE codigo_producto = :codigoProducto
        AND p.stock_producto > 0 AND p.modalidad != 'Sin modalidad'");

        $stmt->bindParam(":codigoProducto", $codigoProducto, PDO::PARAM_STR);

        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_OBJ);
    }

    static public function mdlVerificaStockProducto($codigo_producto, $cantidad_a_comprar)
    {

        $stmt = Conexion::conectar()->prepare("SELECT   count(*) as existe
                                                FROM productos p 
                                                WHERE p.codigo_producto = :codigo_producto
                                                AND p.stock_producto > :cantidad_a_comprar");

        $stmt->bindParam(":codigo_producto", $codigo_producto, PDO::PARAM_STR);
        $stmt->bindParam(":cantidad_a_comprar", $cantidad_a_comprar, PDO::PARAM_STR);

        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_OBJ);
    }


    public function guardarImagen($folder, $ubicacionTemporal, $nuevoNombre){
        file_put_contents(strtolower($folder.$nuevoNombre), file_get_contents($ubicacionTemporal));
    }
}
