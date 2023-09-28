<?php

require_once "../controladores/productos.controlador.php";
require_once "../modelos/productos.modelo.php";

class ajaxProductos{
    public function ajaxListarProductos(){
    
        $productos = ProductosControlador::ctrListarProductos();
    
        echo json_encode($productos);
    
    }
    public function ajaxListarTallasProductos(){

        $productosTallas = ProductosControlador::ctrListarTallasProductos();

        echo json_encode($productosTallas, JSON_UNESCAPED_UNICODE);
    }
}

if(isset($_POST['accion']) && $_POST['accion'] == 1){ // parametro para listar productos

    $productos = new ajaxProductos();
    $productos -> ajaxListarProductos();

}else if(isset($_POST['accion']) && $_POST['accion'] == 2){// parametro para listar tallas
    $productosTallas = new ajaxProductos();
    $productosTallas -> ajaxListarTallasProductos();
}