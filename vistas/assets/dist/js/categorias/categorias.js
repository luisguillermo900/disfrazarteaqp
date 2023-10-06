$(document).ready(function () {
    table = $('#lstCategorias').DataTable({
        dom: 'Bfrtip', //colocar los botones en la parte superior
        buttons: [
            'excel', 'print', 'pageLength' //nombre de los botones
        ],
        ajax: {
            url: "ajax/categorias.ajax.php",
            dataSrc: '',
            type: "POST",
            data: {
                'accion': 1 //1: LISTAR PRODUCTOS
            },
        },
        "columns": [
            { "data": "id_categoria" },
            { "data": "nombre_categoria" },
            { "data": "genero_categoria" },
            { "data": "fecha_creacion_categoria" },
            { "data": "fecha_actualizacion_categoria" },
        ],
        columnDefs: [{
            targets: 0,
            visible: true
        },
        {
            targets: 3,
            visible: true
        },
        {
            targets: 2,
            visible: true
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
})