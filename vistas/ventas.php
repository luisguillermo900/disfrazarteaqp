<!-- Content Header (Page header) -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0">Venta/Alquiler</h1>
            </div><!-- /.col -->
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                    <li class="breadcrumb-item active">Venta/Alquiler</li>
                </ol>
            </div><!-- /.col -->
        </div><!-- /.row -->
    </div><!-- /.container-fluid -->
</div>
<!-- /.content-header -->

<!-- Main content -->
<div class="content">

    <div class="container-fluid">
        <!-- row para criterios de busqueda -->
        <div class="row">

            <div class="col-lg-12">

                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title">COMPROBANTE DE PAGO</h3>
                        <div class="card-tools">
                        </div> <!-- ./ end card-tools -->
                    </div> <!-- ./ end card-header -->
                    <div class="card-body">

                        <div class="row">

                            <!-- NOMBRE DE LA EMPRESA - VENTA-->
                            <div class="d-none d-md-flex col-md-9 pb-3">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptNombreEmpresaVenta" style="margin: 0;">Empresa Emisora</label>
                                    </div>
                                    <select id="iptNombreEmpresaVenta" class="form-control" data-index="2" disabled>
                                        <option value="">DisfrazarteAQP | El arte del disfraz</option>

                                    </select>
                                </div>
                            </div>

                            <!-- FECHA EMISIÓN -->
                            <div class="d-none d-md-flex col-md-3 pb-3">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptFechaEmisionVenta" style="margin: 0;">Fecha emisión</label>
                                    </div>
                                    <div class="input-group">
                                        <div class="input-group-prepend"><span class="input-group-text"><i
                                                    class="far fa-calendar-alt"></i></span></div>
                                        <input type="text" class="form-control" data-inputmask-alias="datetime"
                                            data-inputmask-inputformat="dd/mm/yyyy" id="iptFechaEmisionVenta">
                                    </div>
                                </div>
                            </div>

                            <!-- TIPO COMPROBANTE -->
                            <div class="d-none d-md-flex col-md-3 ">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="selDocumentoVenta" style="margin: 0;">Tipo de Comprobante</label>
                                    </div>
                                    <select id="selDocumentoVenta" class="form-control" data-index="2" disabled>
                                        <option value="">BOLETA</option>

                                    </select>
                                </div>
                            </div>

                            <!-- SERIE -->
                            <div class="d-none d-md-flex col-md-3 ">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptNroSerie" style="margin: 0;">Serie</label>
                                    </div>
                                    <input type="text" id="iptNroSerie" class="form-control" placeholder="Num. Serie"
                                        disabled>
                                </div>
                            </div>

                            <!-- NUMERO DE VENTA -->
                            <div class="d-none d-md-flex col-md-3 ">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptNroVenta" style="margin: 0;">Num. Venta</label>
                                    </div>
                                    <input type="text" id="iptNroVenta" class="form-control" placeholder="Num. Venta"
                                        disabled>
                                </div>
                            </div>

                            <!-- TIPO DE MONEDA -->
                            <div class="d-none d-md-flex col-md-3 ">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptMonedaVenta" style="margin: 0;">Moneda</label>
                                    </div>

                                    <select id="iptMonedaVenta" class="form-control" disabled>
                                        <option value="">PEN - SOLES</option>

                                    </select>
                                </div>
                            </div>

                        </div>

                    </div> <!-- ./ end card-body -->
                </div>

                <!--DATOS DEL CLIENTE-->
                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title">DATOS DEL CLIENTE</h3>
                        <div class="card-tools">
                        </div> <!-- ./ end card-tools -->
                    </div> <!-- ./ end card-header -->
                    <div class="card-body">

                        <div class="row">
                            <!-- TIPO DE DOCUMENTO -->
                            <div class="d-none d-md-flex col-md-4 pb-3 ">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptTipoDocumentoVenta" style="margin: 0;">Tipo Documento</label>
                                    </div>

                                    <select id="iptTipoDocumentoVenta" class="form-control" disabled>
                                        <option value="L.E / DNI">LIBRETA ELECTORAL O DNI</option>

                                    </select>
                                </div>
                            </div>

                            <!-- NÚMERO DE DOCUMENTO DEL CLIENTE -->
                            <div class="d-none d-md-flex col-md-4 pb-3">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptNumDocumentoVenta" style="margin: 0;">Num. Documento</label>
                                    </div>

                                    <input type="text" inputmode="numeric" pattern="[0-9]*" maxlength="8"
                                        class="form-control" id="iptNumDocumentoVenta" placeholder="12345678" required>
                                    <div class="invalid-feedback">Digite el Num. Documento</div>


                                </div>
                            </div>

                            <!-- NOMBRE DEL CLIENTE -->
                            <div class="d-none d-md-flex col-md-4 pb-3">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptNombreClienteVenta" style="margin: 0;">Nombre del cliente</label>
                                    </div>

                                    <input type="text" class="form-control" id="iptNombreClienteVenta"
                                        placeholder="Apellidos / Nombres" disabled>
                                    <div class="invalid-feedback"></div>

                                </div>
                            </div>

                            <!-- DIRECCIÓN DEL CLIENTE -->
                            <div class="d-none d-md-flex col-md-4 ">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptDireccionClienteVenta" style="margin: 0;">Dirección del
                                            cliente</label>
                                    </div>

                                    <input type="text" class="form-control" id="iptDireccionClienteVenta"
                                        placeholder="Av. Principal 123, Distrito, Ciudad" disabled>
                                    <div class="invalid-feedback"></div>

                                </div>
                            </div>


                            <!-- CELULAR DEL CLIENTE -->
                            <div class="d-none d-md-flex col-md-4 ">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptCelularClienteVenta" style="margin: 0;">Celular del
                                            Cliente</label>
                                    </div>

                                    <input type="text" class="form-control" id="iptCelularClienteVenta"
                                        placeholder="123-456-7890" disabled>
                                    <div class="invalid-feedback"></div>

                                </div>
                            </div>

                            <!-- CORREO ELECTRÓNICO DEL CLIENTE -->
                            <div class="d-none d-md-flex col-md-4">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptCorreoClienteVenta" style="margin: 0;">Correo Electrónico del
                                            Cliente</label>
                                    </div>
                                    <input type="email" class="form-control" id="iptCorreoClienteVenta"
                                        placeholder="correo@example.com" disabled>
                                    <div class="invalid-feedback">Debe ingresar un correo electrónico válido.</div>
                                </div>
                            </div>

                        </div>

                    </div> <!-- ./ end card-body -->
                </div>


                <!--DATOS DEL LISTADO DE PRODUCTO -->
                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title">LISTADO DE PRODUCTOS</h3>
                        <div class="card-tools">
                        </div> <!-- ./ end card-tools -->
                    </div> <!-- ./ end card-header -->
                    <div class="card-body">

                        <div class="row">

                            <!-- INPUT PARA INGRESO DEL CODIGO DE BARRAS O DESCRIPCION DEL PRODUCTO -->
                            <div class="d-none d-md-flex col-md-12 pb-3">
                                <div style="width: 100%;" class="form-floating mx-1 mb-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptCodigoVenta" style="margin: 0;">Productos</label>
                                    </div>
                                    <input type="text" class="form-control" id="iptCodigoVenta"
                                        placeholder="Ingrese el código del producto">
                                </div>
                            </div>


                            <!-- ETIQUETA QUE MUESTRA LA SUMA TOTAL DE LOS PRODUCTOS AGREGADOS AL LISTADO -->
                            <div class="d-none d-md-flex col-md-6 mt-4">
                                <div style="width: 100%;" class="form-floating mx-1">
                                    <div class="form-control text-light bg-dark"
                                        style="display: flex; align-items: center;">
                                        <h3>Total de Venta: S./ <span id="totalVenta">0.00</span></h3>
                                    </div>
                                </div>
                            </div>

                            <!-- SELECCIONAR FORMA DE PAGO -->
                            <div class="d-none d-md-flex col-md-2 pb-3 ">
                                <div style="width: 100%;" class="form-floating mx-1 mb-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="selTipoPago" style="margin: 0;">Forma de Pago</label>
                                    </div>
                                    <select class="form-control" id="selTipoPago">
                                        <option value="1" selected="true">Contado</option>
                                        <option value="2">Yape</option>
                                        <option value="3">Plin</option>
                                        <option value="4">Transferencia</option>
                                    </select>
                                </div>
                            </div>

                            <!-- INPUT DE EFECTIVO ENTREGADO -->
                            <div class="d-none d-md-flex col-md-2 pb-3 ">
                                <div style="width: 100%;" class="form-floating mx-1 mb-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="iptEfectivoRecibido" style="margin: 0;">Efectivo recibido</label>
                                    </div>
                                    <input type="number" min="0" name="iptEfectivo" id="iptEfectivoRecibido"
                                        class="form-control" placeholder="Cantidad de efectivo recibida">
                                    <!-- INPUT CHECK DE EFECTIVO EXACTO -->
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" value="" id="chkEfectivoExacto">
                                        <label class="form-check-label" for="chkEfectivoExacto">
                                            Efectivo Exacto
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <!-- MOSTRAR EL VUELTO -->

                            <div class="d-none d-md-flex col-md-2">
                                <div style="width: 100%;" class="form-floating mx-1 mb-1">
                                    <div style="display: flex; align-items: left; justify-content: left;">
                                        <label for="Vuelto" style="margin: 0;">Vuelto</label>
                                    </div>


                                    <div class="form-control">
                                        <h6 class="text-start text-danger fw-bold"><span id="Vuelto">0.00</span>
                                        </h6>
                                    </div>



                                </div>
                            </div>

                            <!-- LISTADO QUE CONTIENE LOS PRODUCTOS QUE SE VAN AGREGANDO PARA LA COMPRA -->
                            <div class="col-md-12">

                                <table id="lstProductosVenta" class="display nowrap table-striped w-100 shadow ">
                                    <thead class="bg-info text-left fs-6">
                                        <tr>
                                            <th>Código</th>
                                            <th>Categoría</th>
                                            <th>Nombre</th>
                                            <th>Talla</th>
                                            <th>P.Venta</th>
                                            <th>P.Alq.Estreno</th>
                                            <th>P.Alq.Normal</th>
                                            <th>Cantidad</th>
                                            <th>Pre.Unit</th>
                                            <th>Total</th>
                                            <th class="text-center">Opciones</th>
                                            <th>Modalidad</th>
                                        </tr>
                                    </thead>
                                    <tbody class="small text-left fs-6">
                                    </tbody>
                                </table>
                                <!-- / table -->
                            </div>
                            <!-- /.col -->
                        </div>

                    </div> <!-- ./ end card-body -->
                </div>

            </div>

        </div>


        <div class="row mb-3 justify-content-end align-items-end">

            <div class="col-md-3">

                <div class="card shadow">

                    <h5 class="card-header py-1 bg-primary text-white text-center">
                        Total de venta: S./ <span id="totalVentaRegistrar">0.00</span>
                        <!--DERECHA-->
                    </h5>

                    <div class="card-body p-2">

                        <!-- MOSTRAR MONTO EFECTIVO ENTREGADO Y EL VUELTO -->
                        <div class="row mt-2">

                            <div class="col-12">
                                <h6 class="text-start fw-bold">Monto Efectivo: S./ <span
                                        id="EfectivoEntregado">0.00</span></h6>
                            </div>

                            <!--<div class="col-12">
                                <h6 class="text-start text-danger fw-bold">Vuelto: S./ <span id="Vuelto">0.00</span>
                                </h6>
                            </div>-->

                        </div>
                        <!-- MOSTRAR EL SUBTOTAL, IGV Y TOTAL DE LA VENTA -->
                        <div class="row">
                            <div class="col-md-7">
                                <span>SUBTOTAL</span>
                            </div>
                            <div class="col-md-5 text-right">
                                S./ <span class="" id="boleta_subtotal">0.00</span>
                            </div>

                            <div class="col-md-7">
                                <span>IGV (18%)</span>
                            </div>
                            <div class="col-md-5 text-right">
                                S./ <span class="" id="boleta_igv">0.00</span>
                            </div>

                            <div class="col-md-7">
                                <span>TOTAL</span>
                            </div>
                            <div class="col-md-5 text-right">
                                S./ <span class="" id="boleta_total">0.00</span>
                            </div>
                        </div>

                    </div><!-- ./ CARD BODY -->
                    <!-- BOTONES PARA VACIAR LISTADO Y COMPLETAR LA VENTA -->
                    <div class="row mt-2">
                        <div class="col-md-6 text-center pb-3">
                            <button class="btn btn-primary" id="btnIniciarVenta">
                                <i class="fas fa-shopping-cart"></i> Realizar Venta
                            </button>
                        </div>
                        <div class="col-md-6 text-center pb-3">
                            <button class="btn btn-danger" id="btnVaciarListado">
                                <i class="far fa-trash-alt"></i> Vaciar Listado
                            </button>
                        </div>
                    </div>
                </div><!-- ./ CARD -->

            </div>

        </div>
    </div>

</div>

<script src="vistas/assets/dist/js/ventas/ventas.js"></script>