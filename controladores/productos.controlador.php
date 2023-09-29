<?php


class ProductosControlador
{
    static public function ctrListarProductos()
    {

        $productos = ProductosModelo::mdlListarProductos();

        return $productos;
    }

    static public function ctrListarTallasProductos()
    {

        $listarTallasProductos = ProductosModelo::mdlListarTallasProductos();

        return $listarTallasProductos;
    }

    static public function ctrRegistrarProducto(
        $id_categoria_producto,
        $nombre_producto,
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
        $estado_producto
    ) {

        $registroProducto = ProductosModelo::mdlRegistrarProducto(
           
            $id_categoria_producto,
            $nombre_producto,
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
            $estado_producto
        );

        return $registroProducto;
    }
}
