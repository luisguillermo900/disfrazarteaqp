<?php


class EmpresaControlador
{

    static public function ctrListarEmpresas()
    {

        $empresas = EmpresaModelo::mdlListarEmpresas();

        return $empresas;
    }

    static public function ctrActualizarEmpresas(
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