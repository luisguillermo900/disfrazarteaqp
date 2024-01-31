<?php

require_once "../controladores/ventas.controlador.php";
require_once "../modelos/ventas.modelo.php";

class AjaxVentas
{

    public function ajaxObtenerNroBoleta()
    {

        $nroBoleta = VentasControlador::ctrObtenerNroBoleta();

        echo json_encode($nroBoleta, JSON_UNESCAPED_UNICODE);
    }

    public function ajaxRegistrarVenta($datos, $nro_boleta, $descripcion_venta, $sub_total_venta, $igv_venta, $total_venta)
    {

        $registroVenta = VentasControlador::ctrRegistrarVenta($datos, $nro_boleta, $descripcion_venta, $sub_total_venta, $igv_venta, $total_venta);
        echo json_encode($registroVenta, JSON_UNESCAPED_UNICODE);
    }
    public function ajaxListarVentas($fechaDesde, $fechaHasta)
    {

        $ventas = VentasControlador::ctrListarVentas($fechaDesde, $fechaHasta);

        echo json_encode($ventas, JSON_UNESCAPED_UNICODE);
    }

    public function AjaxGenerarTicketVenta($nro_boleta)
    {
        require('../vistas/assets/plugins/fpdf/fpdf.php');

        $pdf = new FPDF($orientation = 'P', $unit = 'mm', array(90, 200));
        $pdf->AddPage();
        $pdf->setMargins(10, 10, 10);

        // Nombre del negocio
        $pdf->SetFont('Arial', 'B', 12);

        $pdf->Image('../vistas/assets/dist/img/AdminLTELogo.png', 15, 2, 45);


        



        $pdf->Cell(70, 6, 'Disfrazarte AQP | El arte del disfraz', 0, 0, 'C');

        $pdf->Ln();
        $pdf->SetFont('Arial', '', 9);
        $pdf->Cell(70, 6, "RUC 1234567891 Avenida Brasil 1347", 0, 0, 'C');

        $pdf->Ln();
        $pdf->Cell(70, 6, utf8_decode("Cerro Colorado - Arequipa"), 0, 0, 'C');

        $pdf->Ln();

        $pdf->SetFont('Arial', 'B', 9);
        $pdf->Cell(70, 6, utf8_decode("TICKET DE VENTA"), 0, 0, 'C');

        $pdf->Ln();

        $pdf->SetFont('Arial', '', 9);
        $pdf->Cell(70, 4, utf8_decode("B001 - " . $nro_boleta), 0, 0, 'C');

        $pdf->Ln();
        //$pdf->Cell(60, 6, utf8_decode("________________________________"), 0, 0, 'C');
        //$pdf->Ln();

        $pdf->Cell(60, 5, '----------------------------------------------------------------', 0, 1, 'L');

        $pdf->Cell(15, 4, mb_convert_encoding('Artículo', 'ISO-8859-1', 'UTF-8'), 0, 0, 'L');
        $pdf->Cell(10, 4, 'Cant.', 0, 0, 'L');
        $pdf->Cell(15, 4, 'Precio', 0, 0, 'L');
        $pdf->Cell(10, 4, 'Dcto1', 0, 0, 'C');
        $pdf->Cell(10, 4, 'Dcto2', 0, 0, 'C');
        $pdf->Cell(10, 4, 'Total', 0, 1, 'C');

        $pdf->Cell(60, 2, '----------------------------------------------------------------', 0, 1, 'L');

        $total = 0;

        $productos = VentasControlador::ctrObtenerDetalleVenta($nro_boleta);

        $pdf->SetFont('Arial', '', 8);

        foreach ($productos as $pro) {
            // Verificar si la clave "nombre_producto" existe en $pro
            if (isset($pro["nro_boleta"])) {
                $pdf->Cell(22, 4, $pro["codigo_producto"]);
                $pdf->Cell(35, 4, utf8_decode(strtoupper(substr($pro["codigo_producto"], 0, 20))));
                $pdf->Ln();

                $pdf->Cell(15, 4, $pro["cantidad"], 0, 0, 'R');
                $pdf->Cell(5, 4, "X", 0, 0, 'R');
                $pdf->Cell(15, 4, "S. " . number_format($pro["precio_unitario_venta"], 2, ".", ","), 0, 0, 'R');
                $pdf->Cell(25, 5, "S./ " . number_format($pro["cantidad"] * $pro["precio_unitario_venta"], 2, ".", ","), 0, 0, "R");
                $pdf->Ln();

                $total += $pro["cantidad"] * $pro["precio_unitario_venta"];
            }
        }

        $pdf->Ln();
        $pdf->Cell(20, 4, "OP. GRAVADA:");
        $pdf->Cell(50, 4, "S./ " . number_format(ROUND($total, 2) - ROUND($total * 0.18, 2), 2, ".", ","), 0, 0, 'R');
        $pdf->Ln();

        $pdf->Cell(20, 4, "OP. INAFECTA:");
        $pdf->Cell(50, 4, "S./ " . number_format(0.00, 2, ".", ","), 0, 0, 'R');
        $pdf->Ln();

        $pdf->Cell(20, 4, "I.G.V.:");
        $pdf->Cell(50, 4, "S./ " . number_format(ROUND($total * 0.18, 2), 2, ".", ","), 0, 0, 'R');
        $pdf->Ln();

        $pdf->Cell(20, 4, "TOTAL A PAGAR: ");
        $pdf->Cell(50, 4, "S./ " . number_format(ROUND($total, 2), 2, ".", ","), 0, 0, 'R');
        $pdf->Ln();

        // Asegúrate de que no haya salida de datos antes de esta línea

        $pdf->Output();
    }
}

if (isset($_POST["accion"]) && $_POST["accion"] == 1) {

    $nroBoleta = new AjaxVentas();
    $nroBoleta->ajaxObtenerNroBoleta();
} else if (isset($_POST["accion"]) && $_POST["accion"] == 2) { // LISTADO DE VENTAS POR RANGO DE FECHAS

    $ventas = new AjaxVentas();
    $ventas->ajaxListarVentas($_POST["fechaDesde"], $_POST["fechaHasta"]);
} else {
    if ((isset($_POST["arr"]))) {

        $registrar = new AjaxVentas();
        $registrar->ajaxRegistrarVenta( $_POST["arr"], 
                                        $_POST['nro_boleta'], 
                                        $_POST['descripcion_venta'],
                                        $_POST['sub_total_venta'],
                                        $_POST['igv_venta'], 
                                        $_POST['total_venta']);
    }
}

if (isset($_GET["nro_boleta"])) {

    $ventas = new AjaxVentas;
    $ventas->AjaxGenerarTicketVenta($_GET["nro_boleta"]);
}
