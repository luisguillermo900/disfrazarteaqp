<!-- Content Header (Page header) -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0">Tablero Principal</h1>
            </div><!-- /.col -->
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                    <li class="breadcrumb-item active">Tablero Principal</li>
                </ol>
            </div><!-- /.col -->
        </div><!-- /.row -->
    </div><!-- /.container-fluid -->
</div>
<!-- /.content-header -->

<!-- Main content -->
<div class="content">

    <div class="container-fluid">

        <!-- row Tarjetas Informativas -->
        <div class="row">

            <div class="col-lg-2">
                <!-- small box -->
                <div class="small-box bg-info">
                    <div class="inner">
                        <h4 id="totalProductos"></h4>

                        <p>Productos</p>
                    </div>
                    <div class="icon">
                        <i class="ion ion-clipboard"></i>
                    </div>
                    <a style="cursor:pointer;" class="small-box-footer">Mas Info <i
                            class="fas fa-arrow-circle-right"></i></a>
                </div>
            </div>

            <!-- TARJETA TOTAL COMPRAS -->
            <div class="col-lg-2">
                <!-- small box -->
                <div class="small-box bg-success">
                    <div class="inner">
                        <h4 id="totalCompras"></h4>

                        <p>Total Compras</p>
                    </div>
                    <div class="icon">
                        <i class="ion ion-cash"></i>
                    </div>
                    <a style="cursor:pointer;" class="small-box-footer">Mas Info <i
                            class="fas fa-arrow-circle-right"></i></a>
                </div>
            </div>

            <!-- TARJETA TOTAL VENTAS -->
            <div class="col-lg-2">
                <!-- small box -->
                <div class="small-box bg-warning">
                    <div class="inner">
                        <h4 id="totalVentas"></h4>

                        <p>Total Ventas</p>
                    </div>
                    <div class="icon">
                        <i class="ion ion-ios-cart"></i>
                    </div>
                    <a style="cursor:pointer;" class="small-box-footer">Mas Info <i
                            class="fas fa-arrow-circle-right"></i></a>
                </div>
            </div>

            <!-- TARJETA TOTAL GANANCIAS -->
            <div class="col-lg-2">
                <!-- small box -->
                <div class="small-box bg-danger">
                    <div class="inner">
                        <h4 id="totalGanancias"></h4>

                        <p>Total Ganancias</p>
                    </div>
                    <div class="icon">
                        <i class="ion ion-ios-pie"></i>
                    </div>
                    <a style="cursor:pointer;" class="small-box-footer">Mas Info <i
                            class="fas fa-arrow-circle-right"></i></a>
                </div>
            </div>

            <!-- TARJETA PRODUCTOS POCO STOCK -->
            <div class="col-lg-2">
                <!-- small box -->
                <div class="small-box bg-primary">
                    <div class="inner">
                        <h4 id="totalProductosMinStock"></h4>

                        <p>Productos poco stock</p>
                    </div>
                    <div class="icon">
                        <i class="ion ion-android-remove-circle"></i>
                    </div>
                    <a style="cursor:pointer;" class="small-box-footer">Mas Info <i
                            class="fas fa-arrow-circle-right"></i></a>
                </div>
            </div>

            <!-- TARJETA TOTAL VENTAS DIA ACTUAL -->
            <div class="col-lg-2">
                <!-- small box -->
                <div class="small-box bg-secondary">
                    <div class="inner">
                        <h4 id="totalVentasHoy"></h4>

                        <p>Ventas del día</p>
                    </div>
                    <div class="icon">
                        <i class="ion ion-android-calendar"></i>
                    </div>
                    <a style="cursor:pointer;" class="small-box-footer">Mas Info <i
                            class="fas fa-arrow-circle-right"></i></a>
                </div>
            </div>


        </div> <!-- ./row Tarjetas Informativas -->

        <!-- row Grafico de barras -->
        <div class="row">

            <div class="col-12">

                <div class="card card-info">

                    <div class="card-header">

                        <h3 class="card-title" id="title-header"></h3>

                        <div class="card-tools">

                            <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                <i class="fas fa-minus"></i>
                            </button>
                            <button type="button" class="btn btn-tool" data-card-widget="remove">
                                <i class="fas fa-times"></i>
                            </button>

                        </div> <!-- ./ end card-tools -->

                    </div> <!-- ./ end card-header -->


                    <div class="card-body">

                        <div class="chart">

                            <canvas id="barChart"
                                style="min-height: 250px; height: 300px; max-height: 350px; width: 100%;">

                            </canvas>

                        </div>

                    </div> <!-- ./ end card-body -->

                </div>

            </div>

        </div><!-- ./row Grafico de barras -->

        <div class="row">
            <div class="col-lg-6">
                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title">Los 10 productos más vendidos</h3>
                        <div class="card-tools">
                            <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                <i class="fas fa-minus"></i>
                            </button>
                            <button type="button" class="btn btn-tool" data-card-widget="remove">
                                <i class="fas fa-times"></i>
                            </button>
                        </div> <!-- ./ end card-tools -->
                    </div> <!-- ./ end card-header -->
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table" id="tbl_productos_mas_vendidos">
                                <thead>
                                    <tr class="text-danger">
                                        <th>Código</th>
                                        <th>Categoría</th>
                                        <th>Nombre</th>
                                        <th>Cantidad</th>
                                        <th>Total de venta</th>
                                    </tr>
                                </thead>
                                <tbody>

                                </tbody>
                            </table>
                        </div>
                    </div> <!-- ./ end card-body -->
                </div>
            </div>
            <div class="col-lg-6">
                <div class="card card-info">
                    <div class="card-header">
                        <h3 class="card-title">Listado de productos con poco stock</h3>
                        <div class="card-tools">
                            <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                <i class="fas fa-minus"></i>
                            </button>
                            <button type="button" class="btn btn-tool" data-card-widget="remove">
                                <i class="fas fa-times"></i>
                            </button>
                        </div> <!-- ./ end card-tools -->
                    </div> <!-- ./ end card-header -->
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table" id="tbl_productos_poco_stock">
                                <thead>
                                    <tr class="text-danger">
                                        <th>Código</th>
                                        <th>Categoría</th>
                                        <th>Nombre</th>
                                        <th>Stock</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div> <!-- ./ end card-body -->
                </div>
            </div>
        </div>

    </div><!-- /.container-fluid -->



</div>
<!-- /.content -->
<script src="vistas/assets/dist/js/dashboard.js"></script>
<script src="vistas/assets/dist/js/cdnjs.cloudflare.com_ajax_libs_Chart.js_2.9.4_Chart.min.js"></script>
