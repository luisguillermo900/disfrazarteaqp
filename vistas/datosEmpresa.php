<!-- Content Header (Page header) -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0">Datos de la Empresa</h1>
            </div><!-- /.col -->
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                    <li class="breadcrumb-item active">Datos de la Empresa</li>
                </ol>
            </div><!-- /.col -->
        </div><!-- /.row -->
    </div><!-- /.container-fluid -->
</div>
<!-- /.content-header -->


<!-- Main content -->
<div class="content">

    <div class="container-fluid">

        <div class="row mb-3">

            <div class="col-md-12">
                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title">Empresa</h3>

                    </div> <!-- ./ end card-header -->
                </div>
                <div class="row">

                    <!-- LISTADO QUE CONTIENE LAS EMPRESAS QUE SE VAN AGREGANDO -->
                    <div class="col-md-12">

                        <table id="lstDatosEmpresa" class="display nowrap table-striped w-100 shadow ">
                            <thead class="bg-info text-left fs-6">
                                <tr>
                                    <th>Id</th>
                                    <th>Empresa</th>
                                    <th>RUC</th>
                                    <th>IGV</th>
                                    <th class="text-center">Opciones</th>
                                    <th>Dirección</th>
                                    <th>Email</th>
                                    <th>Descripción</th>
                                    <th>Serie de Boleta</th>
                                    <th>Num. Correlativo Venta</th>

                                </tr>
                            </thead>
                            <tbody class="small text-left fs-6">
                            </tbody>
                        </table>
                        <!-- / table -->
                    </div>
                    <!-- /.col -->

                </div>

            </div>

        </div>
    </div>

</div>

<!-- Ventana Modal para actualizar empresa -->
<div class="modal fade" id="mdlGestionarEmpresa" role="dialog">

    <div class="modal-dialog modal-lg">

        <!-- contenido del modal -->
        <div class="modal-content">

            <!-- cabecera del modal -->
            <div class="modal-header bg-gray py-1 align-items-center ">

                <h5 class="modal-title">Actualizar Producto</h5>

                <button type="button" class="btn btn-outline-primary text-white border-0 fs-5" data-bs-dismiss="modal"
                    id="btnCerrarModal">
                    <i class="far fa-times-circle"></i>
                </button>

            </div>

            <!-- cuerpo del modal -->
            <div class="modal-body">
                <!--id="frm-datos-producto"-->
                <form class="needs-validation" novalidate>
                    <!-- Abrimos una fila -->
                    <div class="row">
                        <!-- ALERTA-->
                        <div class="alert alert-info alert-styled-left text-blue-800 content-group"
                            style="width: 100%; margin-left: 0; margin-right: 0;">
                            <span class="text-semibold">Estimado usuario,</span>
                            los campos remarcados con <span class="text-danger">*</span> son necesarios.

                            <input type="hidden" id="txtID" name="txtID" class="form-control" value="">
                            <input type="hidden" id="txtProceso" name="txtProceso" class="form-control"
                                value="Registro">
                        </div>
                        <!-- -------------------------- -->
                        <!-- comienza todo el contenido -->
                        <!-- -------------------------- -->
                        <!-- Columna para poner el código -->

                        

                        <!-- Columna para el nombre de la empresa -->
                        <div class="col-12 col-lg-12">
                            <div class="form-group mb-2">
                                <label class="" for="iptNombreEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">Nombre de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptNombreEmpresa"
                                    placeholder="Nombre" required>
                                <div class="invalid-feedback">Debe ingresar el nombre</div>
                            </div>
                        </div>

                        <!-- ID 
                        <div class="col-12 col-lg-1">
                            <div class="form-group mb-2">
                                <label class="" for="iptIDEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">ID</span><span
                                        class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptIDEmpresa"
                                    placeholder="ID" disabled>
                                
                            </div>
                        </div>-->

                

                        <!-- Columna para la descripción de la empresa -->
                        <div class="col-12 col-lg-12">
                            <div class="form-group mb-2">
                                <label class="" for="iptDescripcionEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">Descripción de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <textarea class="form-control form-control-sm" id="iptDescripcionEmpresa" rows="4"
                                    placeholder="Escribe aquí la descripción" required></textarea>
                                <div class="invalid-feedback">Debe ingresar la descripción de la empresa</div>
                            </div>
                        </div>

                        <!-- Columna para el ruc de la empresa -->
                        <div class="col-12 col-lg-6">
                            <div class="form-group mb-2">
                                <label class="" for="iptRucEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">Ruc de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptRucEmpresa"
                                    placeholder="Nombre" required maxlength="11" pattern="[0-9]{11}">
                                <div class="invalid-feedback">Debe ingresar un RUC válido de 11 números</div>
                            </div>
                        </div>


                        <!-- Columna para el IGV de la empresa -->
                        <div class="col-12 col-lg-6">
                            <div class="form-group mb-2">
                                <label class="" for="iptIgvEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">IGV de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptIgvEmpresa"
                                    placeholder="Nombre" disabled maxlength="n" pattern="[0-9]+">
                                <div class="invalid-feedback">Debe ingresar un valor válido para el IGV de la empresa
                                </div>
                            </div>
                        </div>


                        <!-- Columna para la direccion de la empresa -->
                        <div class="col-12 col-lg-12">
                            <div class="form-group mb-2">
                                <label class="" for="iptDireccionEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">Dirección de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptDireccionEmpresa"
                                    placeholder="Nombre" required>
                                <div class="invalid-feedback">Debe ingresar dirección de la empresa</div>
                            </div>
                        </div>

                        <!-- Columna para el email de la empresa -->
                        <div class="col-12 col-lg-12">
                            <div class="form-group mb-2">
                                <label class="" for="iptEmailEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">Email de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <input type="email" class="form-control form-control-sm" id="iptEmailEmpresa"
                                    placeholder="ejemplo@dominio.com" required>
                                <div class="invalid-feedback">Debe ingresar un email válido de la empresa</div>
                            </div>
                        </div>

                        <!-- Columna de la serie de la boleta de la empresa -->
                        <div class="col-12 col-lg-6">
                            <div class="form-group mb-2">
                                <label class="" for="iptSerieEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                    <span class="small">Serie de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptSerieEmpresa"
                                    placeholder="Ejemplo: ABC123" disabled pattern="[A-Z]+[0-9]+">
                                <div class="invalid-feedback">Debe ingresar una serie válida de la empresa (por ejemplo,
                                    ABC123)</div>
                            </div>
                        </div>


                        <!-- Columna del número correlativo de la empresa -->
                        <div class="col-12 col-lg-6">
                            <div class="form-group mb-2">
                                <label class="" for="iptNumCorrelativoEmpresa"><i
                                        class="fas fa-file-signature fs-6"></i>
                                    <span class="small">Número correlativo de la empresa</span><span
                                        class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptNumCorrelativoEmpresa"
                                    placeholder="Ejemplo: 12345678" disabled pattern="[0-9]{8}">
                                <div class="invalid-feedback">Debe ingresar un número correlativo válido de 8 dígitos
                                </div>
                            </div>
                        </div>


                        <!-- ALERTA-->
                        <div class="alert alert-info alert-styled-left text-blue-800 content-group"
                            style="width: 100%; margin-left: 0; margin-right: 0; height: 40px;">
                        </div>
                        <!-- creacion de botones para cancelar y guardar el producto -->
                        <button type="button" class="btn btn-danger mt-3 mx-2" style="width:170px;"
                            data-bs-dismiss="modal" id="btnCancelarActualizar">Cancelar</button>
                        <button type="button" style="width:170px;" class="btn btn-primary mt-3 mx-2"
                            id="btnActualizarEmpresa">Actualizar Empresa</button>
                        <!-- <button class="btn btn-default btn-success" type="submit" name="submit" value="Submit">Save</button> -->

                    </div>
                </form>

            </div>

        </div>
    </div>


</div>
<!-- /. End Ventana Modal para actualizar empresa -->

<!-- Modal para ver más información -->

<div class="modal fade" id="mdlVerMasInformacion" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header bg-gray py-2">
                <h6 class="modal-title" id="titulo_modal_info">Información adicional</h6>
                <button type="button" class="btn-close text-white fs-6" data-bs-dismiss="modal" aria-label="Close"
                    id="btnCerrarModalStock">
                </button>
            </div>

            <div class="modal-body">

                <div class="row">

                    <div class="col-12 mb-3">
                        <p class="form-text text-primary">Empresa: <span id="empresaInfo"
                                class="text-secondary"></span></p>
                        <p class="form-text text-primary">Descripción: <span id="descripcionEmpresaInfo"
                                class="text-secondary"></span></p>
                        <p class="form-text text-primary">Ruc: <span id="rucEmpresaInfo"
                                class="text-secondary"></span></p>
                        <p class="form-text text-primary">IGV: <span id="igvEmpresaInfo"
                                class="text-secondary"></span></p>
                        <p class="form-text text-primary">Dirección: <span id="direccionEmpresaInfo"
                                class="text-secondary"></span></p>
                        <p class="form-text text-primary">Email: <span id="emailEmpresaInfo"
                                class="text-secondary"></span></p>

                        <p class="form-text text-primary">Serie boleta: <span id="serieEmpresaInfo"
                                class="text-secondary"></span></p>
                        <p class="form-text text-primary">Número Correlativo: <span id="numCorrelativoEmpresaInfo"
                                class="text-secondary"></span></p>
                    </div>


                </div>

            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal"
                    id="btnCancelarEmpresa">¡OK!</button>

            </div>

        </div>
    </div>
</div>
<!-- /. End ver más información -->

<script src="vistas/assets/dist/js/datosEmpresa/datosEmpresa.js"></script>