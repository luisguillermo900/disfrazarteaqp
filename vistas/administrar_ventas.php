<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-md-6">
                <h4 class="m-0">Reportes</h4>
            </div>
            <div class="col-md-6">
                <ol class="breadcrumb float-md-right">
                    <li class="breadcrumb-item"><a href="index.php">Inicio</a></li>
                    <li class="breadcrumb-item">Ventas</li>
                    <li class="breadcrumb-item active">Administrar Ventas</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<div class="content pb-2">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title">Criterios de Busqueda</h3>
                        <div class="card-tools"><button class="btn btn-tool" type="button" data-card-widget="collapse"><i class="fas fa-minus"></i></button></div>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label for="">Ventas desde:</label>
                                    <div class="input-group">
                                        <div class="input-group-prepend"><span class="input-group-text"><i class="far fa-calendar-alt"></i></span></div>
                                        <input type="text" class="form-control" data-inputmask-alias="datetime" data-inputmask-inputformat="dd/mm/yyyy" id="ventas_desde">
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label for="">Ventas hasta:</label>
                                    <div class="input-group">
                                        <div class="input-group-prepend"><span class="input-group-text"><i class="far fa-calendar-alt"></i></span></div>
                                        <input type="text" class="form-control" data-inputmask-alias="datetime" data-inputmask-inputformat="dd/mm/yyyy" id="ventas_hasta">
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8 d-flex flex-row align-items-center justify-content-end">
                                <div class="form-group m-0"><a href="" class="btn btn-primary" style="width:120px;" id="btnFiltrar">Buscar</a></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-md-12">
                <h4>Total venta: S./ <span id="totalVenta">0.00</span></h4>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <table class="display nowrap table-striped w-100 shadow" id="lstVentas">
                    <thead class="bg-info">
                        <tr>
                            <th>Nro Boleta</th>
                            <th>Codigo Barras</th>
                            <th>Categoria</th>
                            <th>Producto</th>
                            <th>Cantidad</th>
                            <th>Total Venta</th>
                            <th>Fecha Venta</th>
                        </tr>
                    </thead>
                    <tbody class="small"></tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="vistas/assets/dist/js/ventas/administrar_ventas.js"></script>