<?php

class CategoriasControlador{

    static public function ctrListarCategorias(){
        
        $categorias = CategoriasModelo::mdlListarCategorias();

        return $categorias;

    }

    static public function ctrListarCategoriasAll(){
        
        $categorias = CategoriasModelo::mdlListarCategoriasAll();

        return $categorias;

    }
}