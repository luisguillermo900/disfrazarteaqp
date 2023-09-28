var table;
var accion;
var operacion_stock = 0;

$(document).ready(function () {

    table = $("#tbl_productos").DataTable({
        dom: 'Bfrtip', //colocar los botones en la parte superior
        buttons: [{ //crea las columnas
            text: 'Agregar Producto',
            className: 'addNewRecord',
            action: function (e, dt, node, config) { //documentación
                $("#mdlGestionarProducto").modal('show'); //evento para abrir la ventana
                accion = 2; //registrar
            }
        },
            'excel', 'print', 'pageLength' //nombre de los botones
        ],
        createdRow: function (row, data, dataIndex) {
            if (parseFloat(data[5]) === 0) { // El índice 4 corresponde a la columna de stock
                $(row).css({
                    'background-color': 'rgba(255, 0, 0, 0.5)', // Cambia el fondo a rojo para las filas sin stock
                    'color': 'white' // Cambia el color del texto a blanco para mayor legibilidad
                    // Puedes agregar más estilos si es necesario
                });
            }
        },
        pageLength: [5, 10, 15, 30, 50, 100], //coloca los valores que entran en las tablas
        pageLength: 10, //paginación por defecto
        ajax: {
            url: "ajax/productos.ajax.php",
            dataSrc: '',
            type: "POST",
            data: {
                'accion': 1 //1: LISTAR PRODUCTOS
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
            className: 'control'
        },
        {
            targets: 10,
            orderable: false, //No coloca la opción de ordenar
        },
        {
            targets: 11, // Columna de estado
            orderable: false, //No coloca la opción de ordenar
            render: function (data, type, full, meta) {
                var colorClass = data === 'Disponible' ? 'bg-success text-white' : 'bg-danger text-white';
                return '<div class="' + colorClass + '" style="border-radius: 3px; padding: 2px 4px; display: inline-block; font-size: 12px;">' + data + '</div>';
            }
        }
            ,
        {
            targets: 14,
            visible: false
        },
        {
            targets: 15,
            visible: false
        },
        {
            targets: 16,
            visible: false
        },
        {
            targets: 17,
            visible: false
        },
        {
            targets: 18,
            visible: false
        },
        {
            targets: 13,
            orderable: false, //No coloca la opción de ordenar
            render: function (data, type, full, meta) { //para colocar las opciones
                return "<center>" +
                    "<span class='btnEditarProducto text-primary px-1' style='cursor:pointer;'>" +
                    "<i class='fas fa-plus fs-5'></i>" +
                    "<span class='btnEditarProducto text-primary px-1' style='cursor:pointer;'>" +
                    "<i class='fas fa-pencil-alt fs-5'></i>" +
                    "<span class='btnEliminarProducto text-danger px-1' style='cursor:pointer;'>" +
                    "<i class='fas fa-trash fs-5'></i>" +
                    "</span>" +
                    "</center>"
            }
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
    /*===================================================================*/
    // EVENTOS PARA CRITERIOS DE BUSQUEDA (CODIGO, CATEGORIA Y PRODUCTO)
    /*===================================================================*/
    $("#iptCodigo").keyup(function () {
        table.column($(this).data('index')).search(this.value).draw();
    })

    $("#selectCategoria").change(function () {
        // Obtén el valor seleccionado en el elemento select
        var selectedValue = $(this).val();

        if (selectedValue === "") {
            // Si no se ha seleccionado ningún valor, muestra todos los datos
            table.column($(this).data('index')).search("").draw();
        } else {
            // Escapa cualquier carácter especial en el valor seleccionado
            selectedValue = $.fn.dataTable.util.escapeRegex(selectedValue);

            // Construye una expresión regular que coincide exactamente con el valor seleccionado
            var regex = "^" + selectedValue + "$";

            // Filtra la tabla basada en la expresión regular
            table.column($(this).data('index')).search(regex, true, false).draw();
        }
    });

    $("#iptNombre").keyup(function () {
        table.column($(this).data('index')).search(this.value).draw();
    })

    $("#selectTalla").change(function () {
        // Obtén el valor seleccionado en el elemento select
        var selectedValue = $(this).val();

        // Filtra la tabla basada en el valor seleccionado
        table.column($(this).data('index')).search(selectedValue).draw();
    });

    $("#selectModalidad").change(function () {
        // Obtén el valor seleccionado en el elemento select
        var selectedValue = $(this).val();

        if (selectedValue === "") {
            // Si no se ha seleccionado ningún valor, muestra todos los datos
            table.column($(this).data('index')).search("").draw();
        } else {
            // Escapa cualquier carácter especial en el valor seleccionado
            selectedValue = $.fn.dataTable.util.escapeRegex(selectedValue);

            // Construye una expresión regular que coincide exactamente con el valor seleccionado
            var regex = "^" + selectedValue + "$";

            // Filtra la tabla basada en la expresión regular
            table.column($(this).data('index')).search(regex, true, false).draw();
        }
    });


    $("#selectEstado").change(function () {
        // Obtén el valor seleccionado en el elemento select
        var selectedValue = $(this).val();

        if (selectedValue === "") {
            // Si no se ha seleccionado ningún valor, muestra todos los datos
            table.column($(this).data('index')).search("").draw();
        } else {
            // Escapa cualquier carácter especial en el valor seleccionado
            selectedValue = $.fn.dataTable.util.escapeRegex(selectedValue);

            // Construye una expresión regular que coincide exactamente con el valor seleccionado
            var regex = "^" + selectedValue + "$";

            // Filtra la tabla basada en la expresión regular
            table.column($(this).data('index')).search(regex, true, false).draw();
        }
    });

    /*===================================================================*/
    // EVENTO PARA LIMPIAR LOS CAMPOS DE BÚSQUEDA Y RESTABLECER LOS FILTROS
    /*===================================================================*/

    $("#btnLimpiarBusqueda").on('click', function () {
        // Limpiar campos de búsqueda
        $("#iptCodigo").val('');
        $("#selectCategoria").val('');
        $("#iptNombre").val('');
        $("#selectTalla").val('');
        $("#selectEstado").val('');
        $("#selectEstado").val('');
        $("#selectModalidad").val('');

        // Restablecer los filtros de DataTables
        table.search('').columns().search('').draw();
    });
    //-------------------------
    // LIMPIAR INPUTS DE MODAL CUANDO SE DA EL BOTÓN CANCELAR
    //-------------------------

    $("#btnCancelarRegistro, #btnCerrarModal").on('click', function() {
        //CORREGIR
        $("#validate_codigo").css("display", "none");
        $("#validate_categoria").css("display", "none");
        $("#validate_descripcion").css("display", "none");
        $("#validate_precio_compra").css("display", "none");
        $("#validate_precio_venta").css("display", "none");
        $("#validate_stock").css("display", "none");
        $("#validate_min_stock").css("display", "none");
        //PARA VACIAR LOS DATOS A LA HORA DE HACER CLIC EN CANCELAR

        $("#iptNombreReg").val("");
        $("#selCategoriaReg").val("");
        $("#iptDescripcionReg").val("");
        $("#iptNumPiezasReg").val("");
        $("#iptNumStockReg").val("");
        $("#iptTallaReg").val("");
        $("#iptIncluyeReg").val("");
        $("#iptNoIncluyeReg").val("");
        $("#iptMarcaReg").val("");
        $("#selEstadoReg").val("");
        $("#selectModalidades").val("");
        $("#iptPrecioCompraReg").val("");
        $("#iptPrecioVentaReg").val("");
        $("#iptPrecioAlqEstrenoReg").val("");
        $("#iptPrecioAlqNormalReg").val("");
        $("#iptUtilidadReg").val("");

    })
    /*===================================================================*/
    //SOLICITUD AJAX PARA CARGAR SELECT DE CATEGORIAS
    /*===================================================================*/
    $.ajax({
        url: "ajax/categorias.ajax.php",
        cache: false,
        contentType: false,
        processData: false,
        dataType: 'json',
        success: function(respuesta) {

            var options = '<option selected value="">Seleccione una categoría</option>';

            for (let index = 0; index < respuesta.length; index++) {
                options = options + '<option value=' + respuesta[index][0] + '>' + respuesta[index][
                    1
                ] + '</option>';
            }

            $("#selCategoriaReg").append(options);
        }
    });
    /*===================================================================*/
    //SOLICITUD AJAX PARA CARGAR SELECT DE TALLAS
    /*===================================================================*/
    $.ajax({
        url: "ajax/productos.ajax.php",
        cache: false,
        contentType: false,
        processData: false,
        dataType: 'json',
        data: {
            'accion': 2 //20: LISTAR TALLAS
        },
        success: function(respuesta) {

            var options = '<option selected value="">Seleccione una talla</option>';

            for (let index = 0; index < respuesta.length; index++) {
                options = options + '<option value=' + respuesta[index][0] + '</option>';
                
            }

            $("#selectTalla").append(options);
        }
    });
})
