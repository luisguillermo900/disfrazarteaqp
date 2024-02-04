<?php


class EmpresaControlador
{

    static public function ctrListarEmpresas()
    {

        $empresas = EmpresaModelo::mdlListarEmpresas();

        return $empresas;
    }

    static public function ctrActualizarEmpresas(
        $id_empresa,
        $empresa, 
        $ruc,
        $igv,
        $direccion,
        $email,
        $decripcion,
        $serie_boleta,
        $nro_correlativo_venta
        ){ //CONTROLADOR ACTUALIZAR PRODUCTO
        
            $actualizarEmpresa = EmpresaModelo::mdlActualizarEmpresas(
                $id_empresa,
                $empresa, 
                $ruc,
                $igv,
                $direccion,
                $email,
                $decripcion,
                $serie_boleta,
                $nro_correlativo_venta
            );
            return $actualizarEmpresa;
    }

}