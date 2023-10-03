

<aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
    <a href="index3.html" class="brand-link">
        <img src="vistas/assets/dist/img/disfrazarteAQPLogo.png" alt="disfrazarteAQPLogo"
            class="brand-image img-circle elevation-3" style="opacity: .8">
        <span class="brand-text font-weight-light">Disfrazarte AQP</span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
        <!-- Sidebar user panel (CAMBIAR A FUTURO) -->
        <div class="user-panel mt-3 pb-3 mb-3 d-flex">
            <div class="image">
                <img src="vistas/assets/dist/img/user2-160x160.jpg" class="img-circle elevation-2" alt="User Image">
            </div>
            <div class="info">
                <a href="#" class="d-block">Luis Chirinos</a>
            </div>
        </div>

        <!-- Sidebar Menu -->
        <nav class="mt-2">
            <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">

                <!--TABLERO PRINCIPAL-->

                <li class="nav-item">
                    <a style="cursor: pointer;" class="nav-link active"
                        onclick="cargarContenido('vistas/dashboard.php', 'content-wrapper')">
                        <i class="nav-icon fas fa-th"></i>
                        <p>
                            Tablero principal

                        </p>
                    </a>
                </li>
                <!--END TABLERO PRINCIPAL-->
                <li class="nav-item">
                    <a style="cursor: pointer;" class="nav-link"
                        onclick="cargarContenido('vistas/usuarios.php', 'content-wrapper')">
                        <i class="nav-icon fas fa-th"></i>
                        <p>
                            Usuarios

                        </p>
                    </a>
                </li>
                <!--SUB-MENÚ-->
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="nav-icon fas fa-tachometer-alt"></i>
                        <p>
                            Productos
                            <i class="right fas fa-angle-left"></i>
                        </p>
                    </a>
                    <ul class="nav nav-treeview">
                        <li class="nav-item">
                            <a style="cursor: pointer;" class="nav-link"
                                onclick="cargarContenido('vistas/productos.php', 'content-wrapper')">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Inventario</p>
                            </a>
                        </li>
                        <!-- <li class="nav-item">
                            <a style="cursor: pointer;" class="nav-link"
                                onclick="cargarContenido('vistas/carga_masiva_productos.php', 'content-wrapper')">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Carga Masiva</p>
                            </a>
                        </li>-->
                        <li class="nav-item">
                            <a style="cursor: pointer;" class="nav-link"
                                onclick="cargarContenido('vistas/categorias.php', 'content-wrapper')">
                                <i class="far fa-circle nav-icon"></i>
                                <p>Categorías</p>
                            </a>
                        </li>
                    </ul>
                </li>
                <!--END SUB-MENÚ-->

                <li class="nav-item">
                    <a style="cursor: pointer;" class="nav-link"
                        onclick="cargarContenido('vistas/ventas.php', 'content-wrapper')">
                        <i class="nav-icon fas fa-th"></i>
                        <p>
                            Ventas

                        </p>
                    </a>
                </li>
                <li class="nav-item">
                    <a style="cursor: pointer;" class="nav-link"
                        onclick="cargarContenido('vistas/alquiler.php', 'content-wrapper')">
                        <i class="nav-icon fas fa-th"></i>
                        <p>
                            Alquileres

                        </p>
                    </a>
                </li>
                <li class="nav-item">
                    <a style="cursor: pointer;" class="nav-link"
                        onclick="cargarContenido('vistas/compras.php', 'content-wrapper')">
                        <i class="nav-icon fas fa-th"></i>
                        <p>
                            Compras

                        </p>
                    </a>
                </li>
                <li class="nav-item">
                    <a style="cursor: pointer;" class="nav-link"
                        onclick="cargarContenido('vistas/reportes.php', 'content-wrapper')">
                        <i class="nav-icon fas fa-th"></i>
                        <p>
                            Reportes

                        </p>
                    </a>
                </li>
                <li class="nav-item">
                    <a style="cursor: pointer;" class="nav-link"
                        onclick="cargarContenido('vistas/configuracion.php', 'content-wrapper')">
                        <i class="nav-icon fas fa-th"></i>
                        <p>
                            Configuración

                        </p>
                    </a>
                </li>
            </ul>
        </nav>
        <!-- /.sidebar-menu -->
    </div>
    <!-- /.sidebar -->
</aside>


<!--SCRIPTS-->
<script src="vistas/assets/dist/js/aside.js"></script>    
<!--END SCRIPTS-->
