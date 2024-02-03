<?php

require_once "conexion.php";

class EmpresaModelo{

    /*===================================================================
    OBTENER EL LISTADO DE LAS EMPRESAS PARA EL DATATABLE
    ====================================================================*/
    static public function mdlListarEmpresas()
    {

        $stmt = Conexion::conectar()->prepare('call ObtenerDatosEmpresa');

        $stmt->execute();

        return $stmt->fetchAll();
    }

    /*===================================================================
    ACTUALIZAR LA LISTA DE LA EMPRESA EN EL DATATABLE
    ====================================================================*/
    static public function mdlActualizarEmpresas(
        $empresa, 
        $ruc,
        $igv,
        $direccion,
        $email,
        $decripcion,
        $serie_boleta,
        $nro_correlativo_venta
    ){
        try {
            $stmt = Conexion::conectar()->prepare("UPDATE empresa SET
            empresa = :empresa,
            ruc = :ruc,
            IGV = :igv,
            direccion = :direccion,
            email = :email,
            descripcion = :descripcion,
            serie_boleta = :serie_boleta,
            nro_correlativo_venta = :nro_correlativo_venta
            WHERE id_empresa = :id_empresa");

            // Vincular los valores de los parámetros
            $stmt->bindParam(":empresa", $empresa, PDO::PARAM_STR);
            $stmt->bindParam(":ruc", $ruc, PDO::PARAM_STR);
            $stmt->bindParam(":igv", $igv, PDO::PARAM_STR);
            $stmt->bindParam(":direccion", $direccion, PDO::PARAM_STR);
            $stmt->bindParam(":email", $email, PDO::PARAM_STR);
            $stmt->bindParam(":descripcion", $decripcion, PDO::PARAM_STR);
            $stmt->bindParam(":serie_boleta", $serie_boleta, PDO::PARAM_STR);
            $stmt->bindParam(":nro_correlativo_venta", $nro_correlativo_venta, PDO::PARAM_STR);


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
}