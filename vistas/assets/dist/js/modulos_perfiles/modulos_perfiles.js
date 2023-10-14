/* =============================================================
    VARIABLES GLOBALES
    ============================================================= */
var tbl_perfiles_asignar, tbl_modulos, modulos_usuario, modulos_sistema;

$(document).ready(function () {


    /* =============================================================
    FUNCIONES PARA LAS CARGAS INICIALES DE DATATABLES, ARBOL DE MODULOS Y REAJUSTE DE CABECERAS DE DATATABLES
    ============================================================= */
    cargarDataTables();
    ajustarHeadersDataTables($('#tblModulos'));
    iniciarArbolModulos();


    /* =============================================================
    VARIABLES PARA REGISTRAR EL PERFIL Y LOS MODULOS SELECCIOMADOS
    ============================================================= */
    var idPerfil = 0;
    var selectedElmsIds = [];

    /* =============================================================
    EVENTO PARA SELECCIONAR UN PERFIL DEL DATATABLE Y MOSTRAR LOS MODULOS ASIGNADOS EN EL ARBOL DE MODULOS
    ============================================================= */
    $('#tbl_perfiles_asignar tbody').on('click', '.btnSeleccionarPerfil', function () {

        var data = tbl_perfiles_asignar.row($(this).parents('tr')).data();

        if ($(this).parents('tr').hasClass('selected')) {

            $(this).parents('tr').removeClass('selected');

            $('#modulos').jstree("deselect_all", false);

            $("#select_modulos option").remove();

            idPerfil = 0;

            $("#card-modulos").css("display", "none");

        } else {

            tbl_perfiles_asignar.$('tr.selected').removeClass('selected');

            $(this).parents('tr').addClass('selected');

            idPerfil = data[0];

            $("#card-modulos").css("display", "block"); //MOSTRAMOS EL ALRBOL DE MODULOS DEL SISTEMA

            // alert(idPerfil);

            $.ajax({
                async: false,
                url: "ajax/modulo.ajax.php",
                method: 'POST',
                data: {
                    accion: 2,
                    id_perfil: idPerfil
                },
                dataType: 'json',
                success: function (respuesta) {
                    // console.log(respuesta);

                    modulos_usuario = respuesta;

                    seleccionarModulosPerfil(idPerfil);
                }
            });

        }
    })

    /* =============================================================
    EVENTO QUE SE DISPARA CADA VEZ QUE HAY UN CAMBIO EN EL ARBOL DE MODULOS
    ============================================================= */
    $("#modulos").on("changed.jstree", function (evt, data) {

        $("#select_modulos option").remove();

        var selectedElms = $('#modulos').jstree("get_selected", true);

        // console.log(selectedElms);

        $.each(selectedElms, function () {

            for (let i = 0; i < modulos_sistema.length; i++) {

                if (modulos_sistema[i]["id"] == this.id && modulos_sistema[i]["vista"]) {

                    $('#select_modulos').append($('<option>', {
                        value: this.id,
                        text: this.text
                    }));
                }
            }

        })

        if ($("#select_modulos").has('option').length <= 0) {

            $('#select_modulos').append($('<option>', {
                value: 0,
                text: "--No hay módulos seleccionados--"
            }));
        }


    })

    /* =============================================================
    EVENTO PARA MARCAR TODOS LOS CHECKBOX DEL ARBOL DE MODULOS
    ============================================================= */
    $("#marcar_modulos").on('click', function () {
        $('#modulos').jstree('select_all');
    })

    /* =============================================================
    EVENTO PARA DESMARCAR TODOS LOS CHECKBOX DEL ARBOL DE MODULOS
    ============================================================= */
    $("#desmarcar_modulos").on('click', function () {

        $('#modulos').jstree("deselect_all", false);
        $("#select_modulos option").remove();

        $('#select_modulos').append($('<option>', {
            value: 0,
            text: "--No hay módulos seleccionados--"
        }));
    })

    /* =============================================================
    REGISTRO EN BASE DE DATOS DE LOS MODULOS ASOCIADOS AL PERFIL 
    ============================================================= */
    $("#asignar_modulos").on('click', function () {

        alert("entro al evento")
        selectedElmsIds = []
        var selectedElms = $('#modulos').jstree("get_selected", true);

        $.each(selectedElms, function () {

            selectedElmsIds.push(this.id);

            if (this.parent != "#") {
                selectedElmsIds.push(this.parent);
            }

        });

        //quitamos valores duplicados
        let modulosSeleccionados = [...new Set(selectedElmsIds)];

        let modulo_inicio = $("#select_modulos").val();

        // console.log(modulosSeleccionados);

        if (idPerfil != 0 && modulosSeleccionados.length > 0) {
            registrarPerfilModulos(modulosSeleccionados, idPerfil, modulo_inicio);
        } else {
            Swal.fire({
                position: 'center',
                icon: 'warning',
                title: 'Debe seleccionar el perfil y módulos a registrar',
                showConfirmButton: false,
                timer: 3000
            })
        }

    })

    /* =============================================================
    =============================================================
    =============================================================
    MANTENIMIENTO DE MÓDULOS
    =============================================================
    =============================================================
    ============================================================= */

    fnCargarArbolModulos();

    /* =============================================================
    REORGANIZAR MÓDULOS DEL SISTEMA
    ============================================================= */
    $("#btnReordenarModulos").on('click', function () {
        fnOrganizarModulos();
    })


    /* =============================================================
    REINICIALIZAR MÓDULOS DEL SISTEMA EN EL JSTREE
    ============================================================= */
    $("#btnReiniciar").on('click', function () {
        actualizarArbolModulos();
    })

    /*=============================================================
    VISTA PREVIA DEL ICONO DE LA VISTA
    ==============================================================*/
    $("#iptIconoModulo").change(function () {

        $("#spn_icono_modulo").html($("#iptIconoModulo").val())

        if ($("#iptIconoModulo").val().length === 0) {
            $("#spn_icono_modulo").html("<i class='far fa-circle fs-6 text-white'></i>")
        }
    })

    /*===================================================================*/
    //EVENTO QUE GUARDA LOS DATOS DEL MODULO
    /*===================================================================*/
    document.getElementById("btnRegistrarModulo").addEventListener("click", function () {
        fnRegistrarModulo();
    })


}) // FIN DOCUMENT READY

//----------------------------------------------------------------------
//ASIGNAR MÓDULO A PERFIL
//----------------------------------------------------------------------

function cargarDataTables() {

    tbl_perfiles_asignar = $('#tbl_perfiles_asignar').DataTable({
        ajax: {
            async: false,
            url: 'ajax/perfil.ajax.php',
            type: 'POST',
            dataType: 'json',
            dataSrc: "",
            data: {
                accion: 1
            }
        },
        columnDefs: [{
            targets: 2,
            sortable: false,
            createdCell: function (td, cellData, rowData, row, col) {

                if (parseInt(rowData[2]) == 1) {
                    $(td).html("Activo")
                } else {
                    $(td).html("Inactivo")
                }

            }
        },
        {
            targets: 5,
            sortable: false,
            render: function (data, type, full, meta) {
                return "<center>" +
                    "<span class='btnSeleccionarPerfil text-primary px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Seleccionar perfil'> " +
                    "<i class='fas fa-check fs-5'></i> " +
                    "</span> " +
                    "</center>";
            }
        }
        ],
        language: {
            "url": "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
        }

    });

//----------------------------------------------------------------------
//MÓDULOS
//----------------------------------------------------------------------

    tbl_modulos = $('#tblModulos').DataTable({

        ajax: {
            async: false,
            url: 'ajax/modulo.ajax.php',
            type: 'POST',
            dataType: 'json',
            dataSrc: "",
            data: {
                'accion': 3
            }
        },
        columnDefs: [{
            targets: 7,
            visible: false
        },
        {
            targets: 8,
            visible: false
        },
        {
            targets: 0,
            sortable: false,
            render: function (data, type, full, meta) {
                return "<center>" +
                    "<span class='fas fa-edit fs-6 btnSeleccionarModulo text-primary px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Seleccionar Módulo'> " +
                    "</span> " +
                    "<span class='fas fa-trash fs-6 btnEliminarModulo text-danger px-1'style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Eliminar Módulo'> " +
                    "</span>" +
                    "</center>";
            }
        }
        ],
        scrollX: true,
        order: [
            [2, 'asc']
        ],
        lengthMenu: [0, 5, 10, 15, 20, 50],
        pageLength: 20,
        language: {
            url: "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
        }
    });

}

function ajustarHeadersDataTables(element) {

    var observer = window.ResizeObserver ? new ResizeObserver(function (entries) {
        entries.forEach(function (entry) {
            $(entry.target).DataTable().columns.adjust();
        });
    }) : null;

    // Function to add a datatable to the ResizeObserver entries array
    resizeHandler = function ($table) {
        if (observer)
            observer.observe($table[0]);
    };

    // Initiate additional resize handling on datatable
    resizeHandler(element);

}

function iniciarArbolModulos() {

    $.ajax({
        async: false,
        url: "ajax/modulo.ajax.php",
        method: 'POST',
        data: {
            accion: 1
        },
        dataType: 'json',
        success: function (respuesta) {

            modulos_sistema = respuesta;

            // console.log(respuesta);

            // inline data demo
            $('#modulos').jstree({
                'core': {
                    "check_callback": true,
                    'data': respuesta
                },
                "checkbox": {
                    "keep_selected_style": true
                },
                "types": {
                    "default": {
                        "icon": "fas fa-laptop text-warning"
                    }
                },
                "plugins": ["wholerow", "checkbox", "types", "changed"]

            }).bind("loaded.jstree", function (event, data) {
                // you get two params - event & data - check the core docs for a detailed description
                $(this).jstree("open_all");
            });

        }
    })
}

function seleccionarModulosPerfil(pin_idPerfil) {

    $('#modulos').jstree('deselect_all');
    // console.log("modulos_sistema",modulos_sistema);
    // console.log("modulos_usuario",modulos_usuario);
    console.log("pin_idPerfil", pin_idPerfil);

    for (let i = 0; i < modulos_sistema.length; i++) {

        console.log("modulos_sistema[i]['id']", modulos_sistema[i]["id"]);

        if (parseInt(modulos_sistema[i]["id"]) == parseInt(modulos_usuario[i]["id"]) && parseInt(modulos_usuario[i]["sel"]) == 1) {



            $("#modulos").jstree("select_node", modulos_sistema[i]["id"]);

        }

    }

    /*OCULTAMOS LA OPCION DE MODULOS Y PERFILES PARA EL PERFIL DE ADMINISTRADOR*/
    if (pin_idPerfil == 1) { //SOLO PERFIL ADMINISTRADOR
        $("#modulos").jstree(true).hide_node(13);
    } else {
        $('#modulos').jstree(true).show_all();
    }

}

function registrarPerfilModulos(modulosSeleccionados, idPerfil, idModulo_inicio) {


    $.ajax({
        async: false,
        url: "ajax/perfil_modulo.ajax.php",
        method: 'POST',
        data: {
            accion: 1,
            id_modulosSeleccionados: modulosSeleccionados,
            id_Perfil: idPerfil,
            id_modulo_inicio: idModulo_inicio
        },
        dataType: 'json',
        success: function (respuesta) {

            if (respuesta > 0) {

                Swal.fire({
                    position: 'center',
                    icon: 'success',
                    title: 'Se registró correctamente',
                    showConfirmButton: false,
                    timer: 2000
                })

                $("#select_modulos option").remove();
                $('#modulos').jstree("deselect_all", false);
                tbl_perfiles_asignar.ajax.reload();
                $("#card-modulos").css("display", "none");

            } else {

                Swal.fire({
                    position: 'center',
                    icon: 'error',
                    title: 'Error al registrar',
                    showConfirmButton: false,
                    timer: 3000
                })

            }

        }
    });
}

function actualizarArbolModulosPerfiles() {

    $.ajax({
        async: false,
        url: "ajax/modulo.ajax.php",
        method: 'POST',
        data: {
            accion: 1
        },
        dataType: 'json',
        success: function (respuesta) {
            modulos_sistema = respuesta;

            // console.log(modulos_sistema);

            $('#modulos').jstree(true).settings.core.data = respuesta;
            $('#modulos').jstree(true).refresh();
        }
    });

}

/* =============================================================
=============================================================
=============================================================
FUNCIONES PARA EL MANTENIMIENTO DE MODULOS
=============================================================
=============================================================
============================================================= */

function fnCargarArbolModulos() {

    var dataSource;

    $.ajax({
        async: false,
        url: "ajax/modulo.ajax.php",
        method: 'POST',
        data: {
            accion: 1
        },
        dataType: 'json',
        success: function (respuesta) {

            dataSource = respuesta;
            console.log("🚀 ~ file: modulos_perfiles.php ~ line 793 ~ fnCargarArbolModulos ~ dataSource", dataSource)
        }
    });


    /*
    $.jstree.defaults.core.check_callback:
        Determina lo que sucede cuando un usuario intenta modificar la estructura del árbol .
        Si se deja como false se impiden todas las operaciones como crear, renombrar, eliminar, mover o copiar.
        Puede configurar esto en true para permitir todas las interacciones o usar una función para tener un mejor control.
    */
    $('#arbolModulos').jstree({
        "core": {
            "check_callback": true,
            "data": dataSource
        },
        "types": {
            "default": {
                "icon": "fas fa-laptop"
            },
            "file": {
                "icon": "fas fa-laptop"
            }
        },
        "plugins": ["types", "dnd"]
    }).bind('ready.jstree', function (e, data) {
        $('#arbolModulos').jstree('open_all')
    })

}

function actualizarArbolModulos() {

    $.ajax({
        async: false,
        url: "ajax/modulo.ajax.php",
        method: 'POST',
        data: {
            accion: 1
        },
        dataType: 'json',
        success: function (respuesta) {

            $('#arbolModulos').jstree(true).settings.core.data = respuesta;
            $('#arbolModulos').jstree(true).refresh();
        }
    });

}

function fnOrganizarModulos() {

    var array_modulos = [];

    var reg_id, reg_padre_id, reg_orden;

    var v = $("#arbolModulos").jstree(true).get_json('#', {
        'flat': true
    });

    console.log("🚀 ~ file: modulos_perfiles.php ~ line 1074 ~ fnOrganizarModulos ~ v", v)

    for (i = 0; i < v.length; i++) {

        var z = v[i];
        console.log("🚀 ~ file: modulos_perfiles.php ~ line 871 ~ fnOrganizarModulos ~ z", z)

        //asignamos el id, el padre Id y el nombre del modulo
        reg_id = z["id"];
        reg_padre_id = z["parent"];
        reg_orden = i;

        array_modulos[i] = reg_id + ';' + reg_padre_id + ';' + reg_orden;

    }



    console.log("🚀 ~ file: modulos_perfiles.php ~ line 713 ~ $ ~ array_modulos", array_modulos)

    /*REGISTRAMOS LOS MODULOS CON EL NUEVO ORDENAMIENTO */
    $.ajax({
        async: false,
        url: "ajax/modulo.ajax.php",
        method: 'POST',
        data: {
            accion: 4,
            modulos: array_modulos
        },
        dataType: 'json',
        success: function (respuesta) {

            if (respuesta > 0) {

                Swal.fire({
                    position: 'center',
                    icon: 'success',
                    title: 'Se registró correctamente',
                    showConfirmButton: false,
                    timer: 1500
                })

                tbl_modulos.ajax.reload();

                //recargamos arbol de modulos - MANTENIMIENTO MODULOS ASIGNADOS A PERFILES                                
                actualizarArbolModulosPerfiles();

            } else {

                Swal.fire({
                    position: 'center',
                    icon: 'error',
                    title: 'Error al registrar',
                    showConfirmButton: false,
                    timer: 1500
                })

            }



        }
    });

}

function fnRegistrarModulo() {

    var forms = document.getElementsByClassName('needs-validation-registro-modulo');

    var validation = Array.prototype.filter.call(forms, function (form) {

        if (form.checkValidity() === true) {

            console.log("Listo para registrar el producto");

            Swal.fire({
                title: 'Está seguro de registrar el producto?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Si, deseo registrarlo!',
                cancelButtonText: 'Cancelar',
            }).then((result) => {

                if (result.isConfirmed) {

                    $("#iptIconoModulo").val($('#spn_icono_modulo i').attr('class'));

                    $.ajax({
                        async: false,
                        url: "ajax/modulo.ajax.php",
                        method: 'POST',
                        data: {
                            accion: 5,
                            datos: $('#frm_registro_modulo').serialize()
                        },
                        dataType: 'json',
                        success: function (respuesta) {

                            console.log("🚀 ~ file: modulos_perfiles.php ~ line 1240 ~ validation ~ respuesta", respuesta)

                            Swal.fire({
                                position: 'center',
                                icon: 'success',
                                title: respuesta,
                                showConfirmButton: false,
                                timer: 1500
                            })

                            tbl_modulos.ajax.reload();

                            //recargamos arbol de modulos - MANTENIMIENTO MODULOS
                            actualizarArbolModulos();

                            //recargamos arbol de modulos - MANTENIMIENTO MODULOS ASIGNADOS A PERFILES                                
                            actualizarArbolModulosPerfiles();

                            $("#iptModulo").val("");
                            $("#iptVistaModulo").val("");
                            $("#iptIconoModulo").val("");

                            $(".needs-validation-registro-modulo").removeClass("was-validated");
                        }

                    })

                }
            });

        }

        form.classList.add('was-validated');
    })

}