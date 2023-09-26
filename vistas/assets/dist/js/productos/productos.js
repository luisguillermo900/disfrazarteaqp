$(document).ready(function(){
    var table;
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
                orderable: true,
                className: 'control'
            },
            {
                targets: 1,
                visible: true
            },
            {
                targets: 3,
                visible: true
            },
            {
                targets: 9,
                createdCell: function(td, cellData, rowData, row, col) {
                    if (parseFloat(rowData[9]) <= parseFloat(rowData[10])) {
                        $(td).parent().css('background', '#FF5733')
                        $(td).parent().css('color', '#ffffff')
                    }
                }
            },
            {
                targets: 11,
                visible: true
            },
            {
                targets: 12,
                visible: true
            },
            {
                targets: 13,
                visible: true
            },
            {
                targets: 1,
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
})
