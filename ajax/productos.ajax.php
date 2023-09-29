<?php

require_once "../controladores/productos.controlador.php";
require_once "../modelos/productos.modelo.php";

class ajaxProductos
{


    public $codigo_producto;
    public $id_categoria_producto;
    public $nombre_producto;
    public $incluye_producto;
    public $no_incluye_producto;
    public $numero_piezas_producto;
    public $stock_producto;
    public $precio_compra_producto;
    public $precio_venta_producto;
    public $utilidad_venta_producto;
    public $precio_alquiler_estreno_producto;
    public $utilidad_alquiler_estreno_producto;
    public $precio_alquiler_simple_producto;
    public $utilidad_alquiler_simple_producto;
    public $talla_producto;
    public $marca_producto;
    public $modalidad;
    public $estado_producto;

    public function ajaxListarProductos()
    {

        $productos = ProductosControlador::ctrListarProductos();

        echo json_encode($productos);
    }
    public function ajaxListarTallasProductos()
    {

        $productosTallas = ProductosControlador::ctrListarTallasProductos();

        echo json_encode($productosTallas, JSON_UNESCAPED_UNICODE);
    }

    public function ajaxRegistrarProducto()
    {

        $producto = ProductosControlador::ctrRegistrarProducto(
            $this->id_categoria_producto,
            $this->nombre_producto,
            $this->incluye_producto,
            $this->no_incluye_producto,
            $this->numero_piezas_producto,
            $this->stock_producto,
            $this->precio_compra_producto,
            $this->precio_venta_producto,
            $this->utilidad_venta_producto,
            $this->precio_alquiler_estreno_producto,
            $this->utilidad_alquiler_estreno_producto,
            $this->precio_alquiler_simple_producto,
            $this->utilidad_alquiler_simple_producto,
            $this->talla_producto,
            $this->marca_producto,
            $this->modalidad,
            $this->estado_producto
        );

        echo json_encode($producto);
    }
}

if (isset($_POST['accion']) && $_POST['accion'] == 1) { // parametro para listar productos

    $productos = new ajaxProductos();
    $productos->ajaxListarProductos();

} else if (isset($_POST['accion']) && $_POST['accion'] == 2) { // parametro para registrar productos

    $registrarProducto = new AjaxProductos();
    
    $registrarProducto->id_categoria_producto = $_POST["id_categoria_producto"];
    $registrarProducto->nombre_producto = $_POST["nombre_producto"];
    $registrarProducto->incluye_producto = $_POST["incluye_producto"];
    $registrarProducto->no_incluye_producto = $_POST["no_incluye_producto"];
    $registrarProducto->numero_piezas_producto = $_POST["numero_piezas_producto"];
    $registrarProducto->stock_producto = $_POST["stock_producto"];
    $registrarProducto->precio_compra_producto = $_POST["precio_compra_producto"];
    $registrarProducto->precio_venta_producto = $_POST["precio_venta_producto"];

    $registrarProducto->utilidad_venta_producto = $_POST["utilidad_venta_producto"];
    $registrarProducto->precio_alquiler_estreno_producto = $_POST["precio_alquiler_estreno_producto"];
    $registrarProducto->utilidad_alquiler_estreno_producto = $_POST["utilidad_alquiler_estreno_producto"];
    $registrarProducto->precio_alquiler_simple_producto = $_POST["precio_alquiler_simple_producto"];
    $registrarProducto->utilidad_alquiler_simple_producto = $_POST["utilidad_alquiler_simple_producto"];

    $registrarProducto->talla_producto = $_POST["talla_producto"];
    $registrarProducto->marca_producto = $_POST["marca_producto"];
    $registrarProducto->modalidad = $_POST["modalidad"];
    $registrarProducto->estado_producto = $_POST["estado_producto"];

    $registrarProducto->ajaxRegistrarProducto();
    
} else if (isset($_POST['accion']) && $_POST['accion'] == 3) { // parametro para listar tallas
    $productosTallas = new ajaxProductos();
    $productosTallas->ajaxListarTallasProductos();
}
