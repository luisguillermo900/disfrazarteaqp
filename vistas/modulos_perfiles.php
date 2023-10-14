<!-- Content Header (Page header) -->
<div class="content-header">

    <div class="container-fluid">

        <div class="row mb-2">

            <div class="col-sm-6">

                <h1 class="m-0">Administrar Módulos y Perfiles</h1>

            </div><!-- /.col -->

            <div class="col-sm-6">

                <ol class="breadcrumb float-sm-right">

                    <li class="breadcrumb-item"><a href="#">Inicio</a>
                    </li>

                    <li class="breadcrumb-item active">Administrar Módulos y Perfiles</li>

                </ol>

            </div><!-- /.col -->

        </div><!-- /.row -->

    </div>

</div>

<div class="content">

    <div class="container-fluid">

        <ul class="nav nav-tabs" id="tabs-asignar-modulos-perfil" role="tablist">

            <li class="nav-item">
                <a class="nav-link" id="content-perfiles-tab" data-toggle="pill" href="#content-perfiles" role="tab"
                    aria-controls="content-perfiles" aria-selected="false">Perfiles</a>
            </li>

            <li class="nav-item">
                <a class="nav-link " id="content-modulos-tab" data-toggle="pill" href="#content-modulos" role="tab"
                    aria-controls="content-modulos" aria-selected="false">Módulos</a>
            </li>

            <li class="nav-item">
                <a class="nav-link active" id="content-modulo-perfil-tab" data-toggle="pill"
                    href="#content-modulo-perfil" role="tab" aria-controls="content-modulo-perfil"
                    aria-selected="false">Asignar Módulo a Perfil</a>
            </li>

        </ul>

        <div class="tab-content" id="tabsContent-asignar-modulos-perfil">

            <div class="tab-pane fade mt-4 px-4" id="content-perfiles" role="tabpanel"
                aria-labelledby="content-perfiles-tab">
                <h4>Administrar Perfiles</h4>
            </div>

            <!--============================================================================================================================================
            CONTENIDO PARA MODULOS 
            =============================================================================================================================================-->
            <div class="tab-pane fade  mt-4 px-4" id="content-modulos" role="tabpanel"
                aria-labelledby="content-modulos-tab">

                <div class="row">

                    <!--LISTADO DE MODULOS -->
                    <div class="col-md-6">

                        <div class="card card-info card-outline shadow">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-list"></i> Listado de Módulos</h3>

                            </div>

                            <div class="card-body">

                                <table id="tblModulos" class="display nowrap table-striped shadow rounded"
                                    style="width:100%">

                                    <thead class="bg-info text-left">
                                        <th class="text-center">Acciones</th>
                                        <th>id</th>
                                        <th>orden</th>
                                        <th>Módulo</th>
                                        <th>Módulo Padre</th>
                                        <th>Vista</th>
                                        <th>Icono</th>
                                        <th>F. Creación</th>
                                        <th>F. Actualización</th>
                                    </thead>
                                    <tbody class="small text left">

                                    </tbody>

                                </table>

                            </div>

                        </div>

                    </div>
                    <!--/. col-md-6 -->

                    <!--FORMULARIO PARA REGISTRO Y EDICION -->
                    <div class="col-md-3">

                        <div class="card card-info card-outline shadow">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-edit"></i> Registro de Módulos</h3>

                            </div>

                            <div class="card-body">

                                <form method="post" class="needs-validation-registro-modulo" novalidate
                                    id="frm_registro_modulo">

                                    <div class="row">

                                        <div class="col-md-12">

                                            <div class="form-group mb-2">

                                                <label for="iptModulo" class="m-0 p-0 col-sm-12 col-form-label-sm"><span
                                                        class="small">Módulo</span><span
                                                        class="text-danger">*</span></label>

                                                <div class="input-group  m-0">
                                                    <input type="text" class="form-control form-control-sm"
                                                        name="iptModulo" id="iptModulo" required>
                                                    <div class="input-group-append">
                                                        <span class="input-group-text bg-info"><i
                                                                class="fas fa-laptop text-white fs-6"></i></span>
                                                    </div>
                                                    <div class="invalid-feedback">Debe ingresar el módulo</div>
                                                </div>

                                            </div>

                                        </div>

                                        <div class="col-md-12">

                                            <div class="form-group mb-2">

                                                <label for="iptVistaModulo"
                                                    class="m-0 p-0 col-sm-12 col-form-label-sm"><span
                                                        class="small">Vista PHP</span></label>
                                                <div class="input-group  m-0">
                                                    <input type="text" class="form-control form-control-sm"
                                                        name="iptVistaModulo" id="iptVistaModulo">
                                                    <div class="input-group-append">
                                                        <span class="input-group-text bg-info"><i
                                                                class="fas fa-code text-white fs-6"></i></span>
                                                    </div>
                                                </div>

                                            </div>

                                        </div>

                                        <div class="col-md-12">

                                            <div class="form-group mb-2">

                                                <label for="iptIconoModulo"
                                                    class="m-0 p-0 col-sm-12 col-form-label-sm"><span
                                                        class="small">Icono</span><span
                                                        class="text-danger">*</span></label>
                                                <div class="input-group  m-0">
                                                    <input type="text" placeholder="<i class='far fa-circle'></i>"
                                                        name="iptIconoModulo" class="form-control form-control-sm"
                                                        id="iptIconoModulo" required>
                                                    <div class="input-group-append">
                                                        <span class="input-group-text bg-info" id="spn_icono_modulo"><i
                                                                class="far fa-circle fs-6 text-white"></i></span>
                                                    </div>
                                                    <div class="invalid-feedback">Debe ingresar el ícono del módulo
                                                    </div>
                                                </div>

                                            </div>

                                        </div>

                                        <div class="col-md-12">

                                            <div class="form-group m-0 mt-2">

                                                <button type="button" class="btn btn-success w-100"
                                                    id="btnRegistrarModulo">Guardar Módulo</button>

                                            </div>

                                        </div>

                                    </div>

                                </form>

                            </div>

                        </div>

                    </div>
                    <!--/. col-md-3 -->

                    <!--ARBOL DE MODULOS PARA REORGANIZAR -->
                    <div class="col-md-3">

                        <div class="card card-info card-outline shadow">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-edit"></i> Organizar Módulos</h3>

                            </div>

                            <div class="card-body">

                                <div class="">

                                    <div>Módulos del Sistema</div>

                                    <div class="" id="arbolModulos"></div>

                                </div>

                                <hr>

                                <div class="row">

                                    <div class="col-md-12">

                                        <div class="text-center">

                                            <button id="btnReordenarModulos" class="btn btn-success btn-sm"
                                                style="width: 100%;">Organizar Módulos</button>

                                            <button id="btnReiniciar" class="btn btn-sm btn-warning mt-3 "
                                                style="width: 100%;">Estado Inicial</button>
                                        </div>

                                    </div>

                                </div>

                            </div>

                        </div>

                    </div>
                    <!--/. col-md-3 -->

                </div>
                <!--/.row -->

            </div><!-- /#content-modulos -->

            <div class="tab-pane fade active show mt-4 px-4" id="content-modulo-perfil" role="tabpanel"
                aria-labelledby="content-modulo-perfil-tab">

                <div class="row">

                    <div class="col-md-8">

                        <div class="card card-info card-outline shadow">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-list"></i> Listado de Perfiles</h3>

                            </div>

                            <div class="card-body">

                                <table id="tbl_perfiles_asignar"
                                    class="display nowrap table-striped w-100 shadow rounded">

                                    <thead class="bg-info text-left">
                                        <th>id Perfil</th>
                                        <th>Perfil</th>
                                        <th>Estado</th>
                                        <th>F. Creación</th>
                                        <th>F. Actualización</th>
                                        <th class="text-center">Opciones</th>
                                    </thead>

                                    <tbody class="small text left">

                                    </tbody>

                                </table>

                            </div>

                        </div>

                    </div>

                    <div class="col-md-4">

                        <div class="card card-info card-outline shadow" style="display:none" id="card-modulos">

                            <div class="card-header">

                                <h3 class="card-title"><i class="fas fa-laptop"></i> Módulos del Sistema</h3>

                            </div>

                            <div class="card-body" id="card-body-modulos">

                                <div class="row m-2">

                                    <div class="col-md-6">

                                        <button class="btn btn-success btn-small  m-0 p-0 w-100"
                                            id="marcar_modulos">Marcar todo</button>

                                    </div>

                                    <div class="col-md-6">

                                        <button class="btn btn-danger btn-small m-0 p-0 w-100"
                                            id="desmarcar_modulos">Desmarcar todo</button>

                                    </div>

                                </div>

                                <!-- AQUI SE CARGAN TODOS LOS MODULOS DEL SISTEMA -->
                                <div id="modulos" class="demo"></div>

                                <div class="row m-2">

                                    <div class="col-md-12">

                                        <div class="form-group">

                                            <label>Seleccione el modulo de inicio</label>
                                            <select class="custom-select" id="select_modulos">
                                            </select>

                                        </div>

                                    </div>

                                </div>

                                <div class="row m-2">

                                    <div class="col-md-12">

                                        <button class="btn btn-success btn-small w-50 text-center"
                                            id="asignar_modulos">Asignar</button>

                                    </div>

                                </div>

                            </div>

                        </div>
                    </div>

                </div>

            </div>

        </div>

    </div>

</div>

<script src="vistas/assets/dist/js/modulos_perfiles/modulos_perfiles.js"></script>