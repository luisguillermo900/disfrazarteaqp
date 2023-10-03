var table;
var items = []; // SE USA PARA EL INPUT DE AUTOCOMPLETE
var itemProducto = 1;

var Toast = Swal.mixin({
    toast: true,
    position: 'top',
    showConfirmButton: false,
    timer: 3000
});
$(document).ready(function () {

    /* ======================================================================================
        INICIALIZAR LA TABLA DE VENTAS
        ======================================================================================*/
    table = $('#lstProductosVenta').DataTable({
        "columns": [
            { "data": "id" },
            { "data": "codigo_producto" },
            { "data": "id_categoria" },
            { "data": "nombre_categoria" },
            { "data": "descripcion_producto" },
            { "data": "cantidad" },
            { "data": "precio_venta_producto" },
            { "data": "total" },
            { "data": "acciones" },
            { "data": "aplica_peso" },
            { "data": "precio_mayor_producto" },
            { "data": "precio_oferta_producto" }
        ],
        columnDefs: [{
                targets: 0,
                visible: false
            },
            {
                targets: 3,
                visible: false
            },
            {
                targets: 2,
                visible: false
            },
            {
                targets: 6,
                orderable: false
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
                targets: 11,
                visible: false
            },
            {
                targets: "_all", // Aplicar a todas las columnas
                className: "text-center", // Establecer la clase para centrar texto
            },
        ],
        "order": [
            [0, 'desc']
        ],
        language: {
            url: "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
        }
    });
});