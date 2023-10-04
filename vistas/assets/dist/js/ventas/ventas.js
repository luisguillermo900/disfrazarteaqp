var table;
var items = []; // SE USA PARA EL INPUT DE AUTOCOMPLETE


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
            { "data": "codigo_producto" },
            { "data": "nombre_categoria" },
            { "data": "nombre_producto" },
            { "data": "talla_producto" },
            { "data": "cantidad" },
            { "data": "precio_venta_producto" },
            { "data": "precio_alquiler_estreno_producto" },
            { "data": "precio_alquiler_simple_producto" },
            { "data": "total" },
            { "data": "acciones" },
            { "data": "modalidad" }
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
            targets: 6,
            visible: true
        },
        {
            targets: 7,
            visible: true,

        },
        {
            targets: 8,
            visible: true
        },
        {
            targets: 9,
            visible: true,
            orderable: false
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
        "order": [
            [0, 'desc']
        ],
        language: {
            url: "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
        }
    });
    /* ======================================================================================
    TRAER LISTADO DE PRODUCTOS PARA INPUT DE AUTOCOMPLETADO
    ======================================================================================*/
    $.ajax({
        async: false,
        url: "ajax/productos.ajax.php",
        method: "POST",
        data: {
            'accion': 6
        },
        dataType: 'json',
        success: function (respuesta) {

            for (let i = 0; i < respuesta.length; i++) {
                items.push(respuesta[i]['descripcion_producto'])
            }

            $("#iptCodigoVenta").autocomplete({

                source: items,
                select: function (event, ui) {
                    console.log(ui);
                    CargarProductos(ui.item.value);                                                            

                    $("#iptCodigoVenta").val("");

                    $("#iptCodigoVenta").focus();

                    return false;
                }
            })


        }
    });
    /*===================================================================*/
    //FUNCION PARA CARGAR PRODUCTOS EN EL DATATABLE
    /*===================================================================*/
    function CargarProductos(producto = "") {

        if (producto != "") {
            var codigo_producto = producto;

        } else {
            var codigo_producto = $("#iptCodigoVenta").val();
        }

        var producto_repetido = 0;

        /*===================================================================*/
        // AUMENTAMOS LA CANTIDAD SI EL PRODUCTO YA EXISTE EN EL LISTADO
        /*===================================================================*/
        /*table.rows().eq(0).each(function (index) {

            var row = table.row(index);
            var data = row.data();

            if (parseInt(codigo_producto) == data['codigo_producto']) {

                producto_repetido = 1;

                $.ajax({
                    async: false,
                    url: "ajax/productos.ajax.php",
                    method: "POST",
                    data: {
                        'accion': 8,
                        'codigo_producto': data['codigo_producto'],
                        'cantidad_a_comprar': data['cantidad']
                    },
                    dataType: 'json',
                    success: function (respuesta) {

                        if (parseInt(respuesta['existe']) == 0) {

                            Toast.fire({
                                icon: 'error',
                                title: ' El producto ' + data['descripcion_producto'] + ' ya no tiene stock'
                            })

                            $("#iptCodigoVenta").val("");
                            $("#iptCodigoVenta").focus();


                        } else {

                            // AUMENTAR EN 1 EL VALOR DE LA CANTIDAD
                            table.cell(index, 5).data(parseFloat(data['cantidad']) + 1 + ' Und(s)').draw();

                            // ACTUALIZAR EL NUEVO PRECIO DEL ITEM DEL LISTADO DE VENTA
                            NuevoPrecio = (parseInt(data['cantidad']) * data['precio_venta_producto'].replace("S./ ", "")).toFixed(2);
                            NuevoPrecio = "S./ " + NuevoPrecio;
                            table.cell(index, 7).data(NuevoPrecio).draw();

                            // RECALCULAMOS TOTALES
                            recalcularTotales();
                        }
                    }
                });

            }
        });*/

        /*if (producto_repetido == 1) {
            return;
        }*/

        $.ajax({
            url: "ajax/productos.ajax.php",
            method: "POST",
            data: {
                'accion': 7, //BUSCAR PRODUCTOS POR SU CODIGO DE BARRAS
                'codigo_producto': codigo_producto
            },
            dataType: 'json',
            success: function (respuesta) {

                /*===================================================================*/
                //SI LA RESPUESTA ES VERDADERO, TRAE ALGUN DATO
                /*===================================================================*/
                if (respuesta) {

                    var TotalVenta = 0.00;

                    if (respuesta['modalidad'] == 'Venta') {

                        table.row.add({
                            
                            'codigo_producto': respuesta['codigo_producto'],
                            'nombre_categoria': respuesta['nombre_categoria'],
                            'nombre_producto': respuesta['nombre_producto'],
                            'talla_producto': respuesta['talla_producto'],
                            'cantidad': respuesta['cantidad'],
                            'precio_venta_producto': respuesta['precio_venta_producto'],
                            'precio_alquiler_estreno_producto': '-',
                            'precio_alquiler_simple_producto': '-',


                            'total': respuesta['total'],

                            'acciones': "<center>" +
                                "<span class='btnAumentarCantidad text-success px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Aumentar Stock'> " +
                                "<i class='fas fa-cart-plus fs-5'></i> " +
                                "</span> " +
                                "<span class='btnDisminuirCantidad text-warning px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Disminuir Stock'> " +
                                "<i class='fas fa-cart-arrow-down fs-5'></i> " +
                                "</span> " +
                                "<span class='btnEliminarproducto text-danger px-1'style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Eliminar producto'> " +
                                "<i class='fas fa-trash fs-5'> </i> " +
                                "</span>" +
                                "</center>",
                            'modalidad': respuesta['modalidad']
                        }).draw();
                        

                    } else if(respuesta['modalidad'] == 'Venta/Alq. Estreno'){

                        table.row.add({
                            'codigo_producto': respuesta['codigo_producto'],
                            'nombre_categoria': respuesta['nombre_categoria'],
                            'nombre_producto': respuesta['nombre_producto'],
                            'talla_producto': respuesta['talla_producto'],
                            'cantidad': respuesta['cantidad'],
                            'precio_venta_producto': respuesta['precio_venta_producto'],
                            'precio_alquiler_estreno_producto': respuesta['precio_alquiler_estreno_producto'],
                            'precio_alquiler_simple_producto': '-',

                            'total': respuesta['total'],

                            'acciones': "<center>" +
                                "<span class='btnAumentarCantidad text-success px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Aumentar Stock'> " +
                                "<i class='fas fa-cart-plus fs-5'></i> " +
                                "</span> " +
                                "<span class='btnDisminuirCantidad text-warning px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Disminuir Stock'> " +
                                "<i class='fas fa-cart-arrow-down fs-5'></i> " +
                                "</span> " +
                                "<span class='btnEliminarproducto text-danger px-1'style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Eliminar producto'> " +
                                "<i class='fas fa-trash fs-5'> </i> " +
                                "</span>" +
                                "<div class='btn-group'>" +
                                    "<button type='button' class=' p-0 btn transparentbar btn-sm' data-bs-toggle='dropdown' aria-expanded='false'>" +
                                    "<i class='fas fa-cog text-primary fs-5'></i> <i class='fas fa-chevron-down text-primary'></i>" +
                                    "</button>" +

                                    "<ul class='dropdown-menu'>" +
                                    "<li><a class='dropdown-item' codigo = '" + respuesta['codigo_producto'] + "' precio=' " + respuesta['precio_venta_producto'] + "' style='cursor:pointer; font-size:14px;'>P.Venta (" + respuesta['precio_venta_producto'] + ")</a></li>" +
                                    "<li><a class='dropdown-item' codigo = '" + respuesta['codigo_producto'] + "' precio=' " + respuesta['precio_alquiler_estreno_producto'] + "' style='cursor:pointer; font-size:14px;'>P.Alq.Estreno (" + respuesta['precio_alquiler_estreno_producto']+ ")</a></li>" +
                                    
                                    "</ul>" +
                                "</div>" +
                                "</center>",
                            'modalidad': respuesta['modalidad']
                        }).draw();
                        
                        
                    }else if(respuesta['modalidad'] == 'Alq. Normal'){

                        table.row.add({
                            'codigo_producto': respuesta['codigo_producto'],
                            'nombre_categoria': respuesta['nombre_categoria'],
                            'nombre_producto': respuesta['nombre_producto'],
                            'talla_producto': respuesta['talla_producto'],
                            'cantidad': respuesta['cantidad'],
                            'precio_venta_producto': '-',
                            'precio_alquiler_estreno_producto': '-',
                            'precio_alquiler_simple_producto': respuesta['precio_alquiler_simple_producto'],

                            

                            'total': respuesta['total'],

                            'acciones': "<center>" +
                                "<span class='btnAumentarCantidad text-success px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Aumentar Stock'> " +
                                "<i class='fas fa-cart-plus fs-5'></i> " +
                                "</span> " +
                                "<span class='btnDisminuirCantidad text-warning px-1' style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Disminuir Stock'> " +
                                "<i class='fas fa-cart-arrow-down fs-5'></i> " +
                                "</span> " +
                                "<span class='btnEliminarproducto text-danger px-1'style='cursor:pointer;' data-bs-toggle='tooltip' data-bs-placement='top' title='Eliminar producto'> " +
                                "<i class='fas fa-trash fs-5'> </i> " +
                                "</span>" +
                                "</center>",
                            'modalidad': respuesta['modalidad']
                        }).draw();

                       
                    }

                    //  Recalculamos el total de la venta
                    //recalcularTotales();

                    /*===================================================================*/
                    //SI LA RESPUESTA ES FALSO, NO TRAE ALGUN DATO
                    /*===================================================================*/
                } else {
                    Toast.fire({
                        icon: 'error',
                        title: ' El producto no existe o no tiene stock'
                    });

                    $("#iptCodigoVenta").val("");
                    $("#iptCodigoVenta").focus();
                }

            }
        });

    }/* FIN CargarProductos */
});