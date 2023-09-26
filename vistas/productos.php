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
                            <th>Estado</th>
                            <th>Fecha creación</th>
                            
                            
                            <th class="text-center">Opciones</th>
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
            <div class="modal-header bg-gray py-1 align-items-center">

                <h5 class="modal-title">Agregar Producto</h5>

                <button type="button" class="btn btn-outline-primary text-white border-0 fs-5" data-bs-dismiss="modal"
                    id="btnCerrarModal">
                    <i class="far fa-times-circle"></i>
                </button>

            </div>

            <!-- cuerpo del modal -->
            <div class="modal-body">

                <form class="needs-validation" novalidate>
                    <!-- Abrimos una fila -->
                    <div class="row">

                        <!-- Columna para registro del codigo de barras -->
                        <div class="col-12 col-lg-6">
                            <div class="form-group mb-2">
                                <label class="" for="iptCodigoReg"><i class="fas fa-barcode fs-6"></i>
                                    <span class="small">Código de Barras</span><span class="text-danger">*</span>
                                </label>
                                <input type="text" class="form-control form-control-sm" id="iptCodigoReg"
                                    name="iptCodigoReg" placeholder="Código de Barras" required>
                                <div class="invalid-feedback">Debe ingresar el codigo de barras</div>
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
                                <label class="" for="iptDescripcionReg"><i class="fas fa-file-signature fs-6"></i> <span
                                        class="small">Descripción</span><span class="text-danger">*</span></label>
                                <input type="text" class="form-control form-control-sm" id="iptDescripcionReg"
                                    placeholder="Descripción" required>
                                <div class="invalid-feedback">Debe ingresar la descripción</div>
                            </div>
                        </div>

                        <!-- Columna para registro del Precio de Compra -->
                        <div class="col-12  col-lg-4">
                            <div class="form-group mb-2">
                                <label class="" for="iptPrecioCompraReg"><i class="fas fa-dollar-sign fs-6"></i> <span
                                        class="small">Precio
                                        Compra</span><span class="text-danger">*</span></label>
                                <input type="number" min="0" class="form-control form-control-sm" step="0.01"
                                    id="iptPrecioCompraReg" placeholder="Precio de Compra" required>
                                <div class="invalid-feedback">Debe ingresar el Precio de compra</div>
                            </div>
                        </div>

                        <!-- Columna para registro del Precio de Venta -->
                        <div class="col-12 col-lg-4">
                            <div class="form-group mb-2">
                                <label class="" for="iptPrecioVentaReg"><i class="fas fa-dollar-sign fs-6"></i> <span
                                        class="small">Precio
                                        Venta</span><span class="text-danger">*</span></label>
                                <input type="number" min="0" class="form-control form-control-sm" id="iptPrecioVentaReg"
                                    placeholder="Precio de Venta" step="0.01" required>
                                <div class="invalid-feedback">Debe ingresar el precio de venta</div>
                            </div>
                        </div>

                        <!-- Columna para registro de la Utilidad -->
                        <div class="col-12 col-lg-4">
                            <div class="form-group mb-2">
                                <label class="" for="iptUtilidadReg"><i class="fas fa-dollar-sign fs-6"></i> <span
                                        class="small">Utilidad</span></label>
                                <input type="number" min="0" class="form-control form-control-sm" id="iptUtilidadReg"
                                    placeholder="Utilidad" disabled>
                            </div>
                        </div>

                        <!-- Columna para registro del Stock del producto -->
                        <div class="col-12 col-lg-6">
                            <div class="form-group mb-2">
                                <label class="" for="iptStockReg"><i class="fas fa-plus-circle fs-6"></i>
                                    <span class="small">Stock</span><span class="text-danger">*</span></label>
                                <input type="number" min="0" class="form-control form-control-sm" id="iptStockReg"
                                    placeholder="Stock" required>
                                <div class="invalid-feedback">Debe ingresar el stock</div>
                            </div>
                        </div>

                        <!-- Columna para registro del Minimo de Stock -->
                        <div class="col-12 col-lg-6">
                            <div class="form-group mb-2">
                                <label class="" for="iptMinimoStockReg"><i class="fas fa-minus-circle fs-6"></i> <span
                                        class="small">Mínimo
                                        Stock</span><span class="text-danger">*</span></label>
                                <input type="number" min="0" class="form-control form-control-sm" id="iptMinimoStockReg"
                                    placeholder="Mínimo Stock" required>
                                <div class="invalid-feedback">Debe ingresar el minimo stock</div>
                            </div>
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