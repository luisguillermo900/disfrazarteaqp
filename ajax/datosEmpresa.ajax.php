<?php

require_once "../controladores/empresa.controlador.php";
require_once "../modelos/empresa.modelo.php";

class ajaxEmpresas
{
    public $id_empresa;
    public $empresa; 
    public $ruc;
    public $igv;
    public $direccion;
    public $email;
    public $decripcion;
    public $serie_boleta;
    public $nro_correlativo_venta;

    public function ajaxListarEmpresas()
    {

        $empresas = EmpresaControlador::ctrListarEmpresas();

        echo json_encode($empresas);
    }

    public function ajaxActualizarEmpresas()
    {

        $empresas = EmpresaControlador::ctrActualizarEmpresas(
            $this->id_empresa,
            $this->empresa,
            $this->ruc,
            $this->igv,
            $this->direccion,
            $this->email,
            $this->decripcion,
            $this->serie_boleta,
            $this->nro_correlativo_venta
        );
        echo json_encode($empresas, JSON_UNESCAPED_UNICODE);
    }
}

if (isset($_POST['accion']) && $_POST['accion'] == 1) { // parametro para listar empresas

    $empresas = new ajaxEmpresas();
    $empresas->ajaxListarEmpresas();

}else if (isset($_POST['accion']) && $_POST['accion'] == 2) { // ACTUALIZAR LA EMPRESA

    $actualizarEmpresa = new ajaxEmpresas();

    $actualizarEmpresa->id_empresa = $_POST["id_empresa"];
    $actualizarEmpresa->empresa = $_POST["empresa"];
    $actualizarEmpresa->ruc = $_POST["ruc"];
    $actualizarEmpresa->igv = $_POST["IGV"];
    $actualizarEmpresa->direccion = $_POST["direccion"];
    $actualizarEmpresa->email = $_POST["email"];
    $actualizarEmpresa->decripcion = $_POST["descripcion"];
    $actualizarEmpresa->serie_boleta = $_POST["serie_boleta"];
    $actualizarEmpresa->nro_correlativo_venta = $_POST["nro_correlativo_venta"];

    $actualizarEmpresa->ajaxActualizarEmpresas();
}