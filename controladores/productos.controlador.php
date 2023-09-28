<?php


class ProductosControlador{
    static public function ctrListarProductos(){
    
        $productos = ProductosModelo::mdlListarProductos();
    
        return $productos;
    
    }

    static public function ctrListarTallasProductos(){
        
        $listarTallasProductos = ProductosModelo::mdlListarTallasProductos();

        return $listarTallasProductos;

    }
}