<!-- Content Header (Page header) -->
<div class="content-header">
    <div class="container-fluid">
        <div class="row mb-2">
            <div class="col-sm-6">
                <h1 class="m-0">Administrar Categorías</h1>
            </div><!-- /.col -->
            <div class="col-sm-6">
                <ol class="breadcrumb float-sm-right">
                    <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                    <li class="breadcrumb-item active">Administrar Categorías</li>
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
                        <h3 class="card-title">LISTA DE CATEGORÍAS</h3>
                        <div class="card-tools">
                            <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                <i class="fas fa-minus"></i>
                            </button>
                            <button type="button" class="btn btn-tool text-danger" id="btnLimpiarBusqueda">
                                <i class="fas fa-times"></i>
                            </button>
                        </div> <!-- ./ end card-tools -->
                    </div> <!-- ./ end card-header -->
                </div>
                <div class="row">

                    <!-- LISTADO QUE CONTIENE LOS PRODUCTOS QUE SE VAN AGREGANDO PARA LA COMPRA -->
                    <div class="col-md-12">

                        <table id="lstCategorias" class="display nowrap table-striped w-100 shadow ">
                            <thead class="bg-info text-left fs-6">
                                <tr>
                                    <th>Id</th>
                                    <th>Nombre</th>
                                    <th>Género</th>
                                    <th>Fecha creación</th>
                                    <th>Fecha actualización</th>
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

<script src="vistas/assets/dist/js/categorias/categorias.js"></script>