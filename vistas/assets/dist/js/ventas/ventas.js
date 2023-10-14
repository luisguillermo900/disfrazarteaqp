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

            { "data": "precio_venta_producto" },
            { "data": "precio_alquiler_estreno_producto" },
            { "data": "precio_alquiler_simple_producto" },
            { "data": "cantidad" },
            { "data": "precio_unitario" },
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
            visible: true,
            orderable: false
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
        table.rows().eq(0).each(function (index) {

            var row = table.row(index);
            var data = row.data();

            if (codigo_producto == data['codigo_producto']) {

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
                                title: ' El producto ' + data['codigo_producto'] + ' ya no tiene stock'
                            })

                            $("#iptCodigoVenta").val("");
                            $("#iptCodigoVenta").focus();


                        } else {

                            // AUMENTAR EN 1 EL VALOR DE LA CANTIDAD
                            table.cell(index, 7).data(parseFloat(data['cantidad']) + 1).draw();

                            // ACTUALIZAR EL NUEVO PRECIO DEL ITEM DEL LISTADO DE VENTA
                            NuevoPrecio = (parseInt(data['cantidad']) * data['precio_unitario'].replace("S./ ", "")).toFixed(2);
                            NuevoPrecio = "S./ " + NuevoPrecio;
                            table.cell(index, 9).data(NuevoPrecio).draw();

                            // RECALCULAMOS TOTALES
                            recalcularTotales();
                        }
                    }
                });

            }
        });

        if (producto_repetido == 1) {
            return;
        }

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

                            'precio_venta_producto': respuesta['precio_venta_producto'],
                            'precio_alquiler_estreno_producto': '-',
                            'precio_alquiler_simple_producto': '-',
                            'cantidad': respuesta['cantidad'],
                            'precio_unitario': respuesta['precio_venta_producto'],
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


                    } else if (respuesta['modalidad'] == 'Venta/Alq. Estreno') {

                        table.row.add({
                            'codigo_producto': respuesta['codigo_producto'],
                            'nombre_categoria': respuesta['nombre_categoria'],
                            'nombre_producto': respuesta['nombre_producto'],
                            'talla_producto': respuesta['talla_producto'],

                            'precio_venta_producto': respuesta['precio_venta_producto'],
                            'precio_alquiler_estreno_producto': respuesta['precio_alquiler_estreno_producto'],
                            'precio_alquiler_simple_producto': '-',
                            'cantidad': respuesta['cantidad'],
                            'precio_unitario': respuesta['precio_unitario'],
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
                                "<li><a class='dropdown-item' codigo = '" + respuesta['codigo_producto'] + "' precio=' " + respuesta['precio_alquiler_estreno_producto'] + "' style='cursor:pointer; font-size:14px;'>P.Alq.Estreno (" + respuesta['precio_alquiler_estreno_producto'] + ")</a></li>" +

                                "</ul>" +
                                "</div>" +
                                "</center>",
                            'modalidad': respuesta['modalidad']
                        }).draw();


                    } else if (respuesta['modalidad'] == 'Alq. Normal') {

                        table.row.add({
                            'codigo_producto': respuesta['codigo_producto'],
                            'nombre_categoria': respuesta['nombre_categoria'],
                            'nombre_producto': respuesta['nombre_producto'],
                            'talla_producto': respuesta['talla_producto'],

                            'precio_venta_producto': '-',
                            'precio_alquiler_estreno_producto': '-',
                            'precio_alquiler_simple_producto': respuesta['precio_alquiler_simple_producto'],
                            'cantidad': respuesta['cantidad'],
                            'precio_unitario': respuesta['precio_alquiler_simple_producto'],
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
                    recalcularTotales();

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

    /*===================================================================*/
    //FUNCION PARA RECALCULAR LOS TOTALES DE VENTA
    /*===================================================================*/
    function recalcularTotales() {

        var TotalVenta = 0.00;

        table.rows().eq(0).each(function (index) {

            var row = table.row(index);
            var data = row.data();

            TotalVenta = parseFloat(TotalVenta) + parseFloat(data['total'].replace("S./ ", ""));

        });

        $("#totalVenta").html("");
        $("#totalVenta").html(TotalVenta.toFixed(2));//DERECHA

        var totalVenta = $("#totalVenta").html();
        var igv = parseFloat(totalVenta) * 0.18//IGV
        var subtotal = parseFloat(totalVenta) - parseFloat(igv);

        $("#totalVentaRegistrar").html(totalVenta);

        $("#boleta_subtotal").html(parseFloat(subtotal).toFixed(2));
        $("#boleta_igv").html(parseFloat(igv).toFixed(2));
        $("#boleta_total").html(parseFloat(totalVenta).toFixed(2));

        //limpiamos el input de efectivo exacto; desmarcamos el check de efectivo exacto
        //borramos los datos de efectivo entregado y vuelto
        $("#iptEfectivoRecibido").val("");
        $("#chkEfectivoExacto").prop('checked', false);
        $("#EfectivoEntregado").html("0.00");
        $("#Vuelto").html("0.00");

        $("#iptCodigoVenta").val("");
        $("#iptCodigoVenta").focus();
    }
    /* ======================================================================================
    EVENTO PARA MODIFICAR EL PRECIO DE VENTA DEL PRODUCTO
    ======================================================================================*/
    $('#lstProductosVenta tbody').on('click', '.dropdown-item', function () {

        codigo_producto = $(this).attr("codigo");
        precio_venta = parseFloat($(this).attr("precio").replaceAll("S./ ", "")).toFixed(2);
        console.log("Código: " + codigo_producto);
        console.log("Precio String: " + precio_venta);
        recalcularMontos(codigo_producto, precio_venta);
    });


    function recalcularMontos(codigo_producto, precio_venta) {

        table.rows().eq(0).each(function (index) {

            var row = table.row(index);

            var data = row.data();

            if (data['codigo_producto'] == codigo_producto) {

                // AUMENTAR EN 1 EL VALOR DE LA CANTIDAD
                table.cell(index, 8).data("S./ " + parseFloat(precio_venta).toFixed(2)).draw();

                // ACTUALIZAR EL NUEVO PRECIO DEL ITEM DEL LISTADO DE VENTA
                NuevoPrecio = (parseFloat(data['cantidad']) * data['precio_unitario'].replaceAll("S./ ", "")).toFixed(2);
                NuevoPrecio = "S./ " + NuevoPrecio;
                table.cell(index, 9).data(NuevoPrecio).draw();
            }
        });

        // RECALCULAMOS TOTALES
        recalcularTotales();

    }
    /* ======================================================================================
    EVENTO PARA AUMENTAR LA CANTIDAD DE UN PRODUCTO DEL LISTADO
    ====================================================================================== */
    $('#lstProductosVenta tbody').on('click', '.btnAumentarCantidad', function () {

        var data = table.row($(this).parents('tr')).data(); //Recuperar los datos de la fila

        var idx = table.row($(this).parents('tr')).index();  // Recuperar el Indice de la Fila

        var codigo_producto = data['codigo_producto'];
        var cantidad = data['cantidad'];

        $.ajax({
            async: false,
            url: "ajax/productos.ajax.php",
            method: "POST",
            data: {
                'accion': 8,
                'codigo_producto': codigo_producto,
                'cantidad_a_comprar': cantidad
            },

            dataType: 'json',
            success: function (respuesta) {

                if (parseInt(respuesta['existe']) == 0) {

                    Toast.fire({
                        icon: 'error',
                        title: ' El producto ' + data['codigo_producto'] + ' ya no tiene stock'
                    })

                    $("#iptCodigoVenta").val("");
                    $("#iptCodigoVenta").focus();

                } else {

                    cantidad = parseInt(data['cantidad']) + 1;

                    table.cell(idx, 7).data(cantidad).draw();

                    NuevoPrecio = (parseInt(data['cantidad']) * data['precio_unitario'].replace("S./ ", "")).toFixed(2);
                    NuevoPrecio = "S./ " + NuevoPrecio;

                    table.cell(idx, 9).data(NuevoPrecio).draw();

                    recalcularTotales();
                }
            }
        });

    });
    /* ======================================================================================
    EVENTO PARA DESMINUIR LA CANTIDAD DE UN PRODUCTO DEL LISTADO
    ======================================================================================*/
    $('#lstProductosVenta tbody').on('click', '.btnDisminuirCantidad', function () {

        var data = table.row($(this).parents('tr')).data();

        if (data['cantidad'] >= 2) {

            cantidad = parseInt(data['cantidad']) - 1;

            var idx = table.row($(this).parents('tr')).index();

            table.cell(idx, 7).data(cantidad).draw();

            NuevoPrecio = (parseInt(data['cantidad']) * data['precio_unitario'].replace("S./ ", "")).toFixed(2);
            NuevoPrecio = "S./ " + NuevoPrecio;

            table.cell(idx, 9).data(NuevoPrecio).draw();

        }

        recalcularTotales();
    });
    /* ======================================================================================
    EVENTO PARA ELIMINAR UN PRODUCTO DEL LISTADO
    ======================================================================================*/
    $('#lstProductosVenta tbody').on('click', '.btnEliminarproducto', function () {
        table.row($(this).parents('tr')).remove().draw();
        recalcularTotales();
    });
    /* ======================================================================================
    EVENTO PARA VACIAR EL CARRITO DE COMPRAS
    =========================================================================================*/
    $("#btnVaciarListado").on('click', function () {
        vaciarListado();
    })
    /*===================================================================*/
    //FUNCION PARA LIMPIAR TOTALMENTE EL CARRITO DE VENTAS
    /*===================================================================*/
    function vaciarListado() {
        table.clear().draw();
        LimpiarInputs();
    }
    /*===================================================================*/
    //FUNCION PARA LIMPIAR LOS INPUTS DE LA BOLETA Y LABELS QUE TIENEN DATOS
    /*===================================================================*/
    function LimpiarInputs() {
        $("#totalVenta").html("0.00");
        $("#totalVentaRegistrar").html("0.00");
        $("#boleta_total").html("0.00");
        $("#iptEfectivoRecibido").val("");
        $("#EfectivoEntregado").html("0.00");
        $("#Vuelto").html("0.00");
        $("#chkEfectivoExacto").prop('checked', false);
        $("#boleta_subtotal").html("0.00");
        $("#boleta_igv").html("0.00")
    }/* FIN LimpiarInputs */

    /*===================================================================*/
    //REALIZAR LA VENTA
    /*===================================================================*/
    function realizarVenta() {

        var count = 0;
        var totalVenta = $("#totalVenta").html();
        var nro_boleta = $("#iptNroVenta").val();

        table.rows().eq(0).each(function (index) {
            count = count + 1;
        });

        if (count > 0) {

            if ($("#iptEfectivoRecibido").val() > 0 && $("#iptEfectivoRecibido").val() != "") {

                if ($("#iptEfectivoRecibido").val() < parseFloat(totalVenta)) {

                    Toast.fire({
                        icon: 'warning',
                        title: 'El efectivo es menor al costo total de la venta'
                    });

                    return false;
                }

                var formData = new FormData();
                var arr = [];

                table.rows().eq(0).each(function(index) {

                    var row = table.row(index);

                    var data = row.data();

                    arr[index] = data['codigo_producto'] + "," + parseFloat(data['cantidad']) + "," + data['total'].replace("S./ ", "");

                    formData.append('arr[]', arr[index]);

                });

                formData.append('nro_boleta', nro_boleta);
                formData.append('descripcion_venta', 'Venta realizada con Nro Boleta: ' + nro_boleta);
                formData.append('total_venta', parseFloat(totalVenta));

                $.ajax({
                    url: "ajax/ventas.ajax.php",
                    method: "POST",
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function (respuesta) {

                        Swal.fire({
                            position: 'center',
                            icon: 'success',
                            title: respuesta,
                            showConfirmButton: false,
                            timer: 1500
                        })

                        table.clear().draw();

                        LimpiarInputs();

                        CargarNroBoleta();

                        window.open('http://localhost/disfrazarteaqp/vistas/generar_ticket.php?nro_boleta='+nro_boleta);

                    }
                });
            } else {

                Toast.fire({
                    icon: 'warning',
                    title: 'Ingrese el monto en efectivo'
                });
            }

        } else {

            Toast.fire({
                icon: 'warning',
                title: 'No hay productos en el listado.'
            });

        }

        $("#iptCodigoVenta").focus();

    }/* FIN realizarVenta */
    /* ======================================================================================
    TRAER EL NRO DE BOLETA
    ======================================================================================*/
    CargarNroBoleta();
    /* ======================================================================================
    EVENTO QUE REGISTRA EL PRODUCTO EN EL LISTADO CUANDO SE INGRESA EL CODIGO DE BARRAS
    ======================================================================================*/
    $("#iptCodigoVenta").change(function () {
        CargarProductos();
    });
    /* =======================================================================================
    EVENTO QUE PERMITE CHECKEAR EL EFECTIVO CUANDO ES EXACTO
    =========================================================================================*/
    $("#chkEfectivoExacto").change(function () {

        if ($("#chkEfectivoExacto").is(':checked')) {

            var vuelto = 0;
            var totalVenta = $("#totalVenta").html();

            $("#iptEfectivoRecibido").val(totalVenta);

            $("#EfectivoEntregado").html(totalVenta);

            var EfectivoRecibido = parseFloat($("#EfectivoEntregado").html().replace("S./ ", ""));

            vuelto = parseFloat(totalVenta) - parseFloat(EfectivoRecibido);

            $("#Vuelto").html(vuelto.toFixed(2));

        } else {

            $("#iptEfectivoRecibido").val("")
            $("#EfectivoEntregado").html("0.00");
            $("#Vuelto").html("0.00");

        }
    })
    /* ======================================================================================
    EVENTO QUE SE DISPARA AL DIGITAR EL MONTO EN EFECTIVO ENTREGADO POR EL CLIENTE
    =========================================================================================*/
    $("#iptEfectivoRecibido").keyup(function () {
        actualizarVuelto();
    });

    /* ======================================================================================
    EVENTO PARA INICIAR EL REGISTRO DE LA VENTA
    ====================================================================================== */
    $("#btnIniciarVenta").on('click', function () {
        realizarVenta();
    })
    /*===================================================================*/
    //FUNCION PARA CARGAR EL NRO DE BOLETA
    /*===================================================================*/
    function CargarNroBoleta() {

        $.ajax({
            async: false,
            url: "ajax/ventas.ajax.php",
            method: "POST",
            data: {
                'accion': 1
            },
            dataType: 'json',
            success: function (respuesta) {

                serie_boleta = respuesta["serie_boleta"];
                nro_boleta = respuesta["nro_venta"];

                $("#iptNroSerie").val(serie_boleta);
                $("#iptNroVenta").val(nro_boleta);
            }
        });
    }
    /*===================================================================*/
    //FUNCION PARA ACTUALIZAR EL VUELTO
    /*===================================================================*/
    function actualizarVuelto() {

        var totalVenta = $("#totalVenta").html();

        $("#chkEfectivoExacto").prop('checked', false);

        var efectivoRecibido = $("#iptEfectivoRecibido").val();

        if (efectivoRecibido > 0) {

            $("#EfectivoEntregado").html(parseFloat(efectivoRecibido).toFixed(2));

            vuelto = parseFloat(efectivoRecibido) - parseFloat(totalVenta);
            $("#Vuelto").html(`S./ ${vuelto.toFixed(2)}`);


        } else {

            $("#EfectivoEntregado").html("S./ 0.00");
            $("#Vuelto").html("S./ 0.00");

        }
    }
});