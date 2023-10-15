var table;
var accion;
var operacion_stock = 0;

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
        buttons: [{ //crea las columnas
            text: 'Agregar Empresa',
            className: 'addNewRecord btn btn-primary',
            action: function (e, dt, node, config) { //documentación
                $("#mdlGestionarProducto").modal('show'); //evento para abrir la ventana
                accion = 0; //registrar
            }
        },
            'excel', 'print', 'pageLength' //nombre de los botones
        ],
        pageLength: [5, 10, 15, 30, 50, 100], //coloca los valores que entran en las tablas
        pageLength: 10, //paginación por defecto
        ajax: {
            url: "ajax/datosEmpresa.ajax.php",
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
            className: 'control',
            visible: false
        },
        {
            targets: 1,
            visible: true
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
            orderable: false, //No coloca la opción de ordenar
            render: function (data, type, full, meta) { //para colocar las opciones
                return "<center>" +
                    "<span class='btnMasInformacion text-success px-1' style='cursor:pointer;'>" +
                    "<i class='fas fa-plus-circle fs-5'></i>" +
                    "</span>" +
                    "<span class='btnEditarProducto text-primary px-1' style='cursor:pointer;'>" +
                    "<i class='fas fa-pencil-alt fs-5'></i>" +
                    "</span>" +
                    "</center>"
            }
        },
        {
            targets: 5,
            visible: false
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
            targets: 9,
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
})