<?php

    $menuUsuario = UsuarioControlador::ctrObtenerMenuUsuario($_SESSION["usuario"]->id_usuario);

?>

<aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
    <a href="#" class="brand-link">
        <img src="vistas/assets/dist/img/disfrazarteAQPLogo.png" alt="disfrazarteAQPLogo"
            class="brand-image img-circle elevation-3" style="opacity: .8">
        <span class="brand-text font-weight-light">Disfrazarte AQP</span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
        <!-- Sidebar user panel (CAMBIAR A FUTURO) -->
        <div class="user-panel mt-3 pb-3 mb-3 d-flex">
            <div class="image">
                <img src="vistas/assets/dist/img/disfrazarteAQPLogo.png" class="img-circle elevation-2" alt="User Image">
            </div>
            <div class="info">
                <a href="#" class="d-block"><?php echo $_SESSION["usuario"]->nombre_usuario. ' ' . $_SESSION["usuario"]->apellido_usuario ?></a>
            </div>
        </div>

        <!-- Sidebar Menu -->
        <nav class="mt-2">
            <ul class="nav nav-pills nav-sidebar flex-column nav-child-indent" data-widget="treeview" role="menu" data-accordion="false">
            <?php foreach ($menuUsuario as $menu) : ?>
                    <li class="nav-item">

                        <a style="cursor: pointer;" 
                            class="nav-link <?php if($menu->vista_inicio == 1) : ?>
                                                <?php echo 'active'; ?>
                                            <?php endif; ?>"
                            <?php if(!empty($menu->vista)) : ?>
                                onclick="CargarContenido('vistas/<?php echo $menu->vista; ?>','content-wrapper')"
                            <?php endif; ?>
                        >
                            <i class="nav-icon <?php echo $menu->icon_menu; ?>"></i>
                            <p>
                                <?php echo $menu->modulo ?>
                                <?php if(empty($menu->vista)) : ?>
                                    <i class="right fas fa-angle-left"></i> 
                                <?php endif; ?>
                            </p>
                        </a>

                        <?php if(empty($menu->vista)) : ?>

                            <?php
                                $subMenuUsuario = UsuarioControlador::ctrObtenerSubMenuUsuario($menu->id,$_SESSION["usuario"]->id_usuario);
                            ?>

                            <ul class="nav nav-treeview">

                                <?php foreach ($subMenuUsuario as $subMenu) : ?>

                                    <li class="nav-item">
                                        <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/<?php echo $subMenu->vista ?>','content-wrapper')">
                                            <i class="<?php echo $subMenu->icon_menu; ?> nav-icon"></i>
                                            <p><?php echo $subMenu->modulo; ?></p>
                                        </a>
                                    </li>

                                <?php endforeach; ?>
                                                          
                            </ul>

                        <?php endif; ?>

                    </li>
                <?php endforeach; ?>
                
                <li class="nav-item">
                     <a style="cursor: pointer;" class="nav-link" href="http://localhost/disfrazarteaqp?cerrar_sesion=1">
                         <i class="nav-icon fas fa-sign-out-alt"></i>
                         <p>
                             Cerrar Sesión
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