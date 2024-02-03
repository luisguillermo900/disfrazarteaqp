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

<!-- Ventana Modal para ingresar o modificar un Productos -->
<div class="modal fade" id="mdlGestionarEmpresa" role="dialog">

<div class="modal-dialog modal-lg">

    <!-- contenido del modal -->
    <div class="modal-content">

        <!-- cabecera del modal -->
        <div class="modal-header bg-gray py-1 align-items-center ">

            <h5 class="modal-title">Actualizar Producto</h5>

            <button type="button" class="btn btn-outline-primary text-white border-0 fs-5"
                data-bs-dismiss="modal" id="btnCerrarModal">
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
                                <span class="small">Nombre de la empresa</span><span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="iptNombreEmpresa"
                                placeholder="Nombre" required>
                            <div class="invalid-feedback">Debe ingresar el nombre</div>
                        </div>
                    </div>

                    <!-- Columna para el ruc de la empresa -->
                    <div class="col-12 col-lg-12">
                        <div class="form-group mb-2">
                            <label class="" for="iptRucEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                <span class="small">Ruc de la empresa</span><span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="iptRucEmpresa"
                                placeholder="Nombre" required>
                            <div class="invalid-feedback">Debe ingresar el Ruc de la empresa</div>
                        </div>
                    </div>

                    <!-- Columna para el IGV de la empresa -->
                    <div class="col-12 col-lg-12">
                        <div class="form-group mb-2">
                            <label class="" for="iptIgvEmpresa"><i class="fas fa-file-signature fs-6"></i>
                                <span class="small">IGV de la empresa</span><span class="text-danger">*</span></label>
                            <input type="text" class="form-control form-control-sm" id="iptIgvEmpresa"
                                placeholder="Nombre" required>
                            <div class="invalid-feedback">Debe ingresar el IGV de la empresa</div>
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
<!-- /. End Ventana Modal para ingreso de Productos -->

<script src="vistas/assets/dist/js/datosEmpresa/datosEmpresa.js"></script>