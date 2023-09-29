    <!-- Content Header (Page header) -->
    <div class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">Inventario / Productos</h1>
                </div><!-- /.col -->
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                        <li class="breadcrumb-item active">Inventario / Productos</li>
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
                            <h3 class="card-title">CRITERIOS DE BÚSQUEDA</h3>
                            <div class="card-tools">
                                <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <button type="button" class="btn btn-tool text-danger" id="btnLimpiarBusqueda">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div> <!-- ./ end card-tools -->
                        </div> <!-- ./ end card-header -->
                        <div class="card-body">

                            <div class="row">

                                <div class="d-none d-md-flex col-md-12 ">

                                    <div style="width: 20%;" class="form-floating mx-1">
                                        <input type="text" id="iptCodigo" class="form-control" data-index="1"
                                            placeholder="Código">
                                        <div style="display: flex; align-items: center; justify-content: center;">
                                            <label for="iptEstado" style="margin: 0;">Código</label>
                                        </div>
                                    </div>

                                    <div style="width: 20%;" class="form-floating mx-1">
                                        <select id="selectCategoria" class="form-control" data-index="2">
                                            <option value="" selected>Todas las categorías</option>
                                            <!-- Opción para eliminar el filtro -->
                                            <option value="BEBÉ NIÑA">BEBÉ NIÑA</option>
                                            <option value="BEBÉ NIÑO">BEBÉ NIÑO</option>
                                            <option value="NIÑA">NIÑA</option>
                                            <option value="NIÑO">NIÑO</option>
                                            <option value="MUJER">MUJER</option>
                                            <option value="HOMBRE">HOMBRE</option>
                                            <option value="USA-CHINA: BEBÉ NIÑA">USA-CHINA: BEBÉ NIÑA</option>
                                            <option value="USA-CHINA: BEBÉ NIÑO">USA-CHINA: BEBÉ NIÑO</option>
                                            <option value="USA-CHINA: NIÑA">USA-CHINA: NIÑA</option>
                                            <option value="USA-CHINA: NIÑO">USA-CHINA: NIÑO</option>
                                            <option value="USA-CHINA: MUJER">USA-CHINA: MUJER</option>
                                            <option value="USA-CHINA: HOMBRE">USA-CHINA: HOMBRE</option>
                                            <!-- Agrega más opciones según sea necesario -->
                                        </select>
                                        <div style="display: flex; align-items: center; justify-content: center;">
                                            <label for="iptEstado" style="margin: 0;">Categoría</label>
                                        </div>
                                    </div>

                                    <div style="width: 20%;" class="form-floating mx-1">
                                        <input type="text" id="iptNombre" class="form-control" data-index="3"
                                            placeholder="Nombre">
                                        <div style="display: flex; align-items: center; justify-content: center;">
                                            <label for="iptEstado" style="margin: 0;">Nombre</label>
                                        </div>
                                    </div>

                                    <div style="width: 20%;" class="form-floating mx-1">
                                        <select id="selectTalla" class="form-control" data-index="4">
                                            <option value="" selected>Todas las tallas</option>
                                            <!-- Opción para eliminar el filtro -->
                                            <option value="opcion1">Opción 1</option>
                                            <option value="opcion2">Opción 2</option>
                                            <option value="opcion3">Opción 3</option>
                                            <!-- Agrega más opciones según sea necesario -->
                                        </select>
                                        <div style="display: flex; align-items: center; justify-content: center;">
                                            <label for="iptEstado" style="margin: 0;">Talla</label>
                                        </div>
                                    </div>

                                    <div style="width: 20%;" class="form-floating mx-1">
                                        <select id="selectModalidad" class="form-control" data-index="10">
                                            <option value="" selected>Todas las modalidades</option>
                                            <!-- Opción para eliminar el filtro -->
                                            <option value="Venta">Venta</option>
                                            <option value="Alq. Estreno">Alq. Estreno</option>
                                            <option value="Alq. Normal">Alq. Normal</option>
                                            <option value="Venta/Alq. Estreno">Venta/Alq. Estreno</option>
                                            <option value="Sin modalidad">Sin modalidad</option>
                                            <!-- Agrega más opciones según sea necesario -->
                                        </select>
                                        <div style="display: flex; align-items: center; justify-content: center;">
                                            <label for="iptEstado" style="margin: 0;">Modalidad</label>
                                        </div>
                                    </div>

                                    <div style="width: 20%;" class="form-floating mx-1">
                                        <select id="selectEstado" class="form-control" data-index="11">
                                            <option value="" selected>Todos los estados</option>
                                            <!-- Opción para eliminar el filtro -->
                                            <option value="Disponible">Disponible</option>
                                            <option value="No disponible">No disponible</option>
                                            <!-- Agrega más opciones según sea necesario -->
                                        </select>
                                        <div style="display: flex; align-items: center; justify-content: center;">
                                            <label for="iptEstado" style="margin: 0;">Estado</label>
                                        </div>
                                    </div>


                                </div>




                            </div>

                        </div> <!-- ./ end card-body -->
                    </div>

                </div>

            </div>
            <!-- row para tabla-->
            <div class="row">
                <div class="col-lg-12">
                    <table id="tbl_productos" class="table table-striped w-100 shadow">
                        <thead class="bg-info">
                            <tr style="font-size: 15px;">
                                <th></th>
                                <th>Código</th>
                                <th>Categoría</th>
                                <th>Nombre</th>
                                <th>Talla</th>
                                <th>Stock</th>
                                <th>P.Compra</th>
                                <th>P.Venta</th>
                                <th>P.Alq.Estreno</th>
                                <th>P.Alq.Normal</th>
                                <th>Modalidad</th>
                                <th>Estado</th>
                                <th>Fecha creación</th>
                                <th class="text-center">Opciones</th>
                                <th>Descripción</th>
                                <th>Incluye</th>
                                <th>Num. Piezas</th>
                                <th>Precio Compra</th>
                                <th>Marca</th>
                            </tr>
                        </thead>
                        <tbody class="text-small">
                        </tbody>
                    </table>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </div>
    <!-- /.content -->

    <!-- Ventana Modal para ingresar o modificar un Productos -->
    <div class="modal fade" id="mdlGestionarProducto" role="dialog">

        <div class="modal-dialog modal-lg">

            <!-- contenido del modal -->
            <div class="modal-content">

                <!-- cabecera del modal -->
                <div class="modal-header bg-gray py-1 align-items-center ">

                    <h5 class="modal-title">Agregar Producto</h5>

                    <button type="button" class="btn btn-outline-primary text-white border-0 fs-5"
                        data-bs-dismiss="modal" id="btnCerrarModal">
                        <i class="far fa-times-circle"></i>
                    </button>

                </div>

                <!-- cuerpo del modal -->
                <div class="modal-body">

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

                            <!-- Columna para el nombre del producto -->
                            <div class="col-12 col-lg-6">
                                <div class="form-group mb-2">
                                    <label class="" for="iptNombreReg"><i class="fas fa-file-signature fs-6"></i>
                                        <span class="small">Nombre</span><span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-sm" id="iptNombreReg"
                                        placeholder="Nombre" required>
                                    <div class="invalid-feedback">Debe ingresar el nombre</div>
                                </div>
                            </div>

                            <!-- Columna para registro de la categoría del producto -->
                            <div class="col-12  col-lg-6">
                                <div class="form-group mb-2">
                                    <label class="" for="selCategoriaReg"><i class="fas fa-dumpster fs-6"></i>
                                        <span class="small">Categoría</span><span class="text-danger">*</span>
                                    </label>
                                    <select class="form-select form-select-sm" aria-label=".form-select-sm example"
                                        id="selCategoriaReg" required>
                                        

                                    </select>
                                    <div class="invalid-feedback">Seleccione la categoría</div>
                                </div>
                            </div>

                            <!-- Columna para registro de la descripción del producto -->
                            <div class="col-12">
                                <div class="form-group mb-2">
                                    <label class="" for="iptDescripcionReg"><i class="fas fa-file-signature fs-6"></i>
                                        <span class="small">Descripción</span></label>
                                    <input type="text" class="form-control form-control-sm" id="iptDescripcionReg"
                                        placeholder="Descripción" required>
                                    <div class="invalid-feedback">Debe ingresar la descripción</div>
                                </div>
                            </div>

                            <!-- Columna para registro de número de piezas -->
                            <div class="col-12  col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptNumPiezasReg"><i class="fas fa-plus-circle fs-6"></i>
                                        <span class="small">Núm.
                                            Piezas</span><span class="text-danger">*</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm" step="0.01"
                                        id="iptNumPiezasReg" placeholder="0" required>
                                    <div class="invalid-feedback">Debe ingresar el número de piezas</div>
                                </div>
                            </div>

                            <!-- Columna para registro número de stock -->
                            <div class="col-12  col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptNumStockReg"><i class="fas fa-plus-circle fs-6"></i>
                                        <span class="small">Núm.
                                            stock</span><span class="text-danger">*</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm" step="0.01"
                                        id="iptNumStockReg" placeholder="0" required>
                                    <div class="invalid-feedback">Debe ingresar el número de stock</div>
                                </div>
                            </div>

                            <!-- Columna para registro de talla -->
                            <div class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptTallaReg"><i class="fas fa-file-signature fs-6"></i>
                                        <span class="small">Talla</span><span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-sm" id="iptTallaReg"
                                        placeholder="Ejm: XL" required>
                                    <div class="invalid-feedback">Debe ingresar la talla</div>
                                </div>
                            </div>

                            <!-- Columna para registro de productos que incluye -->
                            <div class="col-12">
                                <div class="form-group mb-2">
                                    <label class="" for="iptIncluyeReg"><i class="fas fa-file-signature fs-6"></i>
                                        <span class="small">Incluye</span><span class="text-danger">*</span></label>
                                    <input type="text" class="form-control form-control-sm" id="iptIncluyeReg"
                                        placeholder="Ejm: traje 1, traje 2" required>
                                    <div class="invalid-feedback">Debe ingresar la sección incluye</div>
                                </div>
                            </div>

                            <!-- Columna para registro de productos que no incluye -->
                            <div class="col-12">
                                <div class="form-group mb-2">
                                    <label class="" for="iptNoIncluyeReg"><i class="fas fa-file-signature fs-6"></i>
                                        <span class="small">No incluye</span></label>
                                    <input type="text" class="form-control form-control-sm" id="iptNoIncluyeReg"
                                        placeholder="Ejm: traje 1, traje 2" required>
                                    <div class="invalid-feedback">Debe ingresar la sección no incluye</div>
                                </div>
                            </div>


                            <!-- Columna para registro de marca -->
                            <div class="col-12 col-lg-12">
                                <div class="form-group mb-2">
                                    <label class="" for="iptMarcaReg"><i class="fas fa-file-signature fs-6"></i>
                                        <span class="small">Marca</span></label>
                                    <input type="text" class="form-control form-control-sm" id="iptMarcaReg"
                                        placeholder="Ejm: Marca" required>
                                    <div class="invalid-feedback">Debe ingresar la marca</div>
                                </div>
                            </div>

                            <!-- Columna para registro del estado del producto -->
                            <div class="col-12  col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="selEstadoReg"><i class="fas fa-dumpster fs-6"></i>
                                        <span class="small">Estado</span><span class="text-danger">*</span>
                                    </label>
                                    <select class="form-select form-select-sm" aria-label=".form-select-sm example"
                                        id="selEstadoReg" required>
                                        <option value="no_disponible">No disponible</option>
                                        <option value="disponible">Disponible</option>

                                    </select>
                                    <div class="invalid-feedback">Seleccione el estado</div>
                                </div>
                            </div>

                            <div class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="selectModalidades"><i class="fas fa-dumpster fs-6"></i>
                                        <span class="small">Modalidad</span><span class="text-danger">*</span>
                                    </label>
                                    <select class="form-select form-select-sm" aria-label=".form-select-sm example"
                                        id="selectModalidades" required>
                                        <option value="Sin modalidad">Sin modalidad</option>
                                        <option value="Venta">Venta</option>
                                        <option value="Alq. Estreno">Alq. Estreno</option>
                                        <option value="Alq. Normal">Alq. Normal</option>
                                        <option value="Venta/Alq. Estreno">Venta/Alq. Estreno</option>
                                    </select>


                                    <div class="invalid-feedback">Seleccione la modalidad</div>
                                </div>
                            </div>


                            <!-- Columna para registro del Precio de Compra -->
                            <div class="col-12  col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptPrecioCompraReg"><i class="fas fa-dollar-sign fs-6"></i>
                                        <span class="small">Precio
                                            Compra</span><span class="text-danger">*</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm" step="0.01"
                                        id="iptPrecioCompraReg" placeholder="Precio de Compra" required>
                                    <div class="invalid-feedback">Debe ingresar el Precio de compra</div>
                                </div>
                            </div>

                            <!-- Columna para registro del Precio de Venta -->
                            <div id="divPrecioVenta" class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptPrecioVentaReg"><i class="fas fa-dollar-sign fs-6"></i>
                                        <span class="small">Precio
                                            Venta</span><span class="text-danger">*</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm"
                                        id="iptPrecioVentaReg" placeholder="Precio de Venta" step="0.01" required>
                                    <div class="invalid-feedback">Debe ingresar el precio de venta</div>
                                </div>
                            </div>
                            <!-- Columna para registro del Precio alquiler estreno -->
                            <div id="divAlquilerEstreno" class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptPrecioAlqEstrenoReg"><i class="fas fa-dollar-sign fs-6"></i>
                                        <span class="small">Precio
                                            Alq. Estreno</span><span class="text-danger">*</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm"
                                        id="iptPrecioAlqEstrenoReg" placeholder="Precio Alq. Estreno" step="0.01"
                                        required>
                                    <div class="invalid-feedback">Debe ingresar el precio alquiler estreno</div>
                                </div>
                            </div>

                            <!-- Columna para registro del Precio alquiler normal -->
                            <div id="divAlquilerNormal" class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptPrecioAlqNormalReg"><i class="fas fa-dollar-sign fs-6"></i>
                                        <span class="small">Precio
                                            Alq. Normal</span><span class="text-danger">*</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm"
                                        id="iptPrecioAlqNormalReg" placeholder="Precio Alq. Normal" step="0.01"
                                        required>
                                    <div class="invalid-feedback">Debe ingresar el precio alquiler normal</div>
                                </div>
                            </div>

                            <!-- Columna para registro de la Utilidad venta-->
                            <div class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptUtilidadVentaReg"><i class="fas fa-dollar-sign fs-6"></i> <span
                                            class="small">Utilidad</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm"
                                        id="iptUtilidadVentaReg" placeholder="Utilidad venta" disabled>
                                </div>
                            </div>

                            <!-- Columna para registro de la Utilidad precio alq. estreno-->
                            <div class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptUtilidadAlqEstrenoReg"><i class="fas fa-dollar-sign fs-6"></i> <span
                                            class="small">Utilidad Alq. Estreno</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm"
                                        id="iptUtilidadAlqEstrenoReg" placeholder="Utilidad Alq. Estreno" disabled>
                                </div>
                            </div>

                            <!-- Columna para registro de la Utilidad precio alq. normal-->
                            <div class="col-12 col-lg-4">
                                <div class="form-group mb-2">
                                    <label class="" for="iptUtilidadAlqNormalReg"><i class="fas fa-dollar-sign fs-6"></i> <span
                                            class="small">Utilidad Alq. Normal</span></label>
                                    <input type="number" min="0" class="form-control form-control-sm"
                                        id="iptUtilidadAlqNormalReg" placeholder="Utilidad Alq. Normal" disabled>
                                </div>
                            </div>

                            <!-- ALERTA-->
                            <div class="alert alert-info alert-styled-left text-blue-800 content-group"
                                style="width: 100%; margin-left: 0; margin-right: 0; height: 40px;">



                            </div>

                            <!-- creacion de botones para cancelar y guardar el producto -->
                            <button type="button" class="btn btn-danger mt-3 mx-2" style="width:170px;"
                                data-bs-dismiss="modal" id="btnCancelarRegistro">Cancelar</button>
                            <button type="button" style="width:170px;" class="btn btn-primary mt-3 mx-2"
                                id="btnGuardarProducto">Guardar Producto</button>
                            <!-- <button class="btn btn-default btn-success" type="submit" name="submit" value="Submit">Save</button> -->

                        </div>
                    </form>

                </div>

            </div>
        </div>


    </div>
    <!-- /. End Ventana Modal para ingreso de Productos -->
    <script src="vistas/assets/dist/js/productos/productos.js"></script>