var table;
var accion;
var operacion_stock = 0;
var idNombre;
/*===================================================================*/
//INICIALIZAMOS EL MENSAJE DE TIPO TOAST (EMERGENTE EN LA PARTE SUPERIOR)
/*===================================================================*/
var Toast = Swal.mixin({
    toast: true,
    position: 'top',
    showConfirmButton: false,
    timer: 6000
});

$(document).ready(function () {
    table = $("#lstDatosEmpresa").DataTable({
        dom: 'Bfrtip', //colocar los botones en la parte superior
        buttons: [/*{ //crea las columnas Y AGREGAR EMPRESA
            //text: 'Agregar Empresa',
            //className: 'addNewRecord btn btn-primary',
            action: function (e, dt, node, config) { //documentación
                $("#mdlGestionarProducto").modal('show'); //evento para abrir la ventana
                accion = 0; //registrar
            }
        },*/
            'excel', 'print', 'pageLength' //nombre de los botones
        ],
        pageLength: [5, 10, 15, 30, 50, 100], //coloca los valores que entran en las tablas
        pageLength: 10, //paginación por defecto
        ajax: {
            url: "ajax/datosEmpresa.ajax.php",
            dataSrc: '',
            type: "POST",
            data: {
                'accion': 1 //1: LISTAR EMPRESAS
            },
        },
        responsive: {
            details: {
                type: 'column'
            }
        },
        columnDefs: [{
            targets: 0,
            orderable: false,
            className: 'control',
            visible: false
        },
        {
            targets: 1,
            visible: false
        },
        {
            targets: 2,
            visible: true
        },
        {
            targets: 3,
            visible: true
        },
        {
            targets: 4,
            visible: true
        },
        {
            targets: 5,
            orderable: false, //No coloca la opción de ordenar
            render: function (data, type, full, meta) { //para colocar las opciones
                return "<center>" +
                    "<span class='btnMasInformacionEmpresa text-success px-1' style='cursor:pointer;'>" +
                    "<i class='fas fa-plus-circle fs-5'></i>" +
                    "</span>" +
                    "<span class='btnEditarEmpresa text-primary px-1' style='cursor:pointer;'>" +
                    "<i class='fas fa-pencil-alt fs-5'></i>" +
                    "</span>" +
                    "</center>"
            }
        },
        {
            targets: 6,
            visible: false
        },
        {
            targets: 7,
            visible: false
        },
        {
            targets: 8,
            visible: false
        },
        {
            targets: 8,
            visible: false
        },
        {
            targets: 9,
            visible: false
        },
        {
            targets: 10,
            visible: false
        },
        {
            targets: "_all", // Aplicar a todas las columnas
            className: "text-center", // Establecer la clase para centrar texto
        },
        ],
        language: {
            url: "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
        }
    });

    /* ======================================================================================
    EVENTO AL DAR CLICK EN EL BOTON EDITAR EMPRESA PARA PASAR LOS DATOS AL MODAL DE EDITAR
    =========================================================================================*/
    $('#lstDatosEmpresa tbody').on('click', '.btnEditarEmpresa', function () {

        accion = 2; //seteamos la accion para editar

        $("#mdlGestionarEmpresa").modal('show');

        var data = table.row($(this).parents('tr')).data();
        //console.log("🚀 ~ file: productos.php ~ line 751 ~ $ ~ data", data)

        //$("#iptIDEmpresa").val(data["id_empresa"]);
        idNombre = data["id_empresa"];
        $("#iptNombreEmpresa").val(data["empresa"]);
        
        $("#iptRucEmpresa").val(data["ruc"]);
        $("#iptIgvEmpresa").val(data["IGV"]);
        $("#iptDireccionEmpresa").val(data["direccion"]);
        $("#iptEmailEmpresa").val(data["email"]);
        $("#iptDescripcionEmpresa").val(data["descripcion"]);
        $("#iptSerieEmpresa").val(data["serie_boleta"]);
        $("#iptNumCorrelativoEmpresa").val(data["nro_correlativo_venta"]);
 
    })

/*===================================================================*/
    //EVENTO QUE ACTUALIZAR LOS DATOS DE LA EMPRESA PREVIA VALIDACION DEL INGRESO DE LOS DATOS OBLIGATORIOS
    /*===================================================================*/
    document.getElementById("btnActualizarEmpresa").addEventListener("click", function () {
        
        // Get the forms we want to add validation styles to
        var forms = document.getElementsByClassName('needs-validation');
        // Loop over them and prevent submission
        var validation = Array.prototype.filter.call(forms, function (form) {

            if (form.checkValidity() === true) {

                console.log("Listo para actualizar los datos de la empresa")

                Swal.fire({
                    title: '¿Está seguro de actualizar la empresa?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: '¡Sí, deseo actualizar!',
                    cancelButtonText: '¡Cancelar!',
                }).then((result) => {

                    if (result.isConfirmed) {

                        var datos = new FormData();
                        //ESTOS DATOS SON ENVÍADOS MEDIANTE EL MÉTODO POST
                        datos.append("accion", accion);
                        datos.append("id_empresa", idNombre); //ID empresa
                        datos.append("empresa", $("#iptNombreEmpresa").val());
                        datos.append("ruc", $("#iptRucEmpresa").val());
                        datos.append("IGV", $("#iptIgvEmpresa").val());
                        datos.append("direccion", $("#iptDireccionEmpresa").val());
                        datos.append("email", $("#iptEmailEmpresa").val());
                        datos.append("descripcion", $("#iptDescripcionEmpresa").val());
                        datos.append("serie_boleta", $("#iptSerieEmpresa").val());
                        datos.append("nro_correlativo_venta", $("#iptNumCorrelativoEmpresa").val());
                       

                        if (accion == 2) {
                            var titulo_msj = "Los datos de la empresa se actualizó correctamente"
                        }

                        $.ajax({
                            url: "ajax/datosEmpresa.ajax.php",
                            method: "POST",
                            data: datos,
                            cache: false,
                            contentType: false,
                            processData: false,
                            dataType: 'json',
                            success: function (respuesta) {

                                if (respuesta == "ok") {

                                    Toast.fire({
                                        icon: 'success',
                                        title: titulo_msj
                                    });

                                    table.ajax.reload();

                                    $("#mdlGestionarEmpresa").modal('hide');
                                    //$("#iptIDEmpresa").val("");
                                    $("#iptNombreEmpresa").val("");
                                    $("#iptRucEmpresa").val("");
                                    $("#iptIgvEmpresa").val("");
                                    $("#iptDireccionEmpresa").val("");
                                    $("#iptEmailEmpresa").val("");
                                    $("#iptDescripcionEmpresa").val("");
                                    $("#iptSerieEmpresa").val("");
                                    $("#iptNumCorrelativoEmpresa").val("");
                                    
                                } else {
                                    Toast.fire({
                                        icon: 'error',
                                        title: 'error'
                                    });
                                }

                            }
                        });

                    }
                })
            } else {
                console.log("No pasó la validación")
            }

            form.classList.add('was-validated');

        });
    });

    /* ======================================================================================
    EVENTO AL DAR CLICK EN EL BOTON VER MÁS INFORMACIÓN
    =========================================================================================*/
    $('#lstDatosEmpresa tbody').on('click', '.btnMasInformacionEmpresa', function () {
        //accion = 1;
        $("#mdlVerMasInformacion").modal('show'); // MOSTRAR VENTANA MODAL
        $("#titulo_modal_info").html('Información Adicional'); // CAMBIAR EL TITULO DE LA VENTANA MODAL

        var rowData = table.row($(this).parents('tr')).data();

        $("#empresaInfo").html(rowData[2]);
        $("#descripcionEmpresaInfo").html(rowData[8]);
        $("#rucEmpresaInfo").html(rowData[3]);
        $("#igvEmpresaInfo").html(rowData[4]);

        $("#direccionEmpresaInfo").html(rowData[6]);
        $("#emailEmpresaInfo").html(rowData[7]);
        $("#serieEmpresaInfo").html(rowData[9]);
        $("#numCorrelativoEmpresaInfo").html(rowData[10]);
        
    });

})