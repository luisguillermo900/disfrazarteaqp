<?php

require_once "../controladores/categorias.controlador.php";
require_once "../modelos/categorias.modelo.php";

class AjaxCategorias{


    public function ajaxListarCategorias(){

        $categorias = CategoriasControlador::ctrListarCategorias();

        echo json_encode($categorias, JSON_UNESCAPED_UNICODE);
    }

    public function ajaxListarCategoriasAll(){

        $categoriasAll = CategoriasControlador::ctrListarCategoriasAll();

        echo json_encode($categoriasAll, JSON_UNESCAPED_UNICODE);
    }
}



if (isset($_POST['accion']) && $_POST['accion'] == 1) { // parametro para listar todas las categorías

    $categoriasAll = new AjaxCategorias();
    $categoriasAll->ajaxListarCategoriasAll();
}else{
    $categorias = new AjaxCategorias();
    $categorias -> ajaxListarCategorias();
}