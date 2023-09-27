var table;
$(document).ready(function(){
    
    table = $("#tbl_productos").DataTable({
        dom: 'Bfrtip', //colocar los botones en la parte superior
        buttons: [{ //crea las columnas
                text: 'Agregar Producto',
                className: 'addNewRecord',
                action: function(e, dt, node, config) { //documentación
                    $("#mdlGestionarProducto").modal('show'); //evento para abrir la ventana
                    accion = 2; //registrar
                }
            },
            'excel', 'print', 'pageLength' //nombre de los botones
        ],
        
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
                targets: 12,
                orderable: false, //No coloca la opción de ordenar
                render: function(data, type, full, meta) { //para colocar las opciones
                    return "<center>" +
                        "<span class='btnEditarProducto text-primary px-1' style='cursor:pointer;'>" +
                        "<i class='fas fa-pencil-alt fs-5'></i>" +
                        "<span class='btnEliminarProducto text-danger px-1' style='cursor:pointer;'>" +
                        "<i class='fas fa-trash fs-5'></i>" +
                        "</span>" +
                        "</center>"
                }
            }

        ],
        language: {
            url: "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
        }
    });
    /*===================================================================*/
    // EVENTOS PARA CRITERIOS DE BUSQUEDA (CODIGO, CATEGORIA Y PRODUCTO)
    /*===================================================================*/
    $("#iptCodigo").keyup(function() {
        table.column($(this).data('index')).search(this.value).draw();
    })

    $("#selectCategoria").change(function() {
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
    
    $("#iptNombre").keyup(function() {
        table.column($(this).data('index')).search(this.value).draw();
    })

    $("#selectTalla").change(function() {
        // Obtén el valor seleccionado en el elemento select
        var selectedValue = $(this).val();
        
        // Filtra la tabla basada en el valor seleccionado
        table.column($(this).data('index')).search(selectedValue).draw();
    });

    $("#selectEstado").change(function() {
        // Obtén el valor seleccionado en el elemento select
        var selectedValue = $(this).val();
        
        // Filtra la tabla basada en el valor seleccionado
        table.column($(this).data('index')).search(selectedValue).draw();
    });

    /*===================================================================*/
    // EVENTO PARA LIMPIAR LOS CAMPOS DE BÚSQUEDA Y RESTABLECER LOS FILTROS
    /*===================================================================*/
    
    $("#btnLimpiarBusqueda").on('click', function() {
    // Limpiar campos de búsqueda
    $("#iptCodigo").val('');
    $("#selectCategoria").val('');
    $("#iptNombre").val('');
    $("#selectTalla").val('');
    $("#selectEstado").val('');

    // Restablecer los filtros de DataTables
    table.search('').columns().search('').draw();
});

})
