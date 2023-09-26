$(document).ready(function() {

    /* =======================================================
    SOLICITUD AJAX TARJETAS INFORMATIVAS
    =======================================================*/
    $.ajax({
        url: "ajax/dashboard.ajax.php",
        method: 'POST',
        data: {
            'accion': 0 //parametro para obtener el resultado de dashboard procedimiento
        },
        dataType: 'json',
        success: function(respuesta) {
            // console.log("respuesta", respuesta);
            $("#totalProductos").html(respuesta[0]['totalProductos']);
            $("#totalCompras").html(respuesta[0]['totalCompras'].replace(
                /\d(?=(\d{3})+\.)/g, "$&,"))
            $("#totalVentas").html(respuesta[0]['totalVentas'].replace(
                /\d(?=(\d{3})+\.)/g, "$&,"))
            $("#totalGanancias").html(respuesta[0]['ganancias'].replace(
                /\d(?=(\d{3})+\.)/g, "$&,"))
            $("#totalProductosMinStock").html(respuesta[0]['productosPocoStock'])
            $("#totalVentasHoy").html(respuesta[0]['ventasHoy'].replace(
                /\d(?=(\d{3})+\.)/g, "$&,"))
        }
    });

    setInterval(() => {
        $.ajax({
            url: "ajax/dashboard.ajax.php",
            method: 'POST',
            data: {
                'accion': 0 //parametro para obtener el resultado de dashboard procedimiento
            },
            dataType: 'json',
            success: function(respuesta) {
                // console.log("respuesta", respuesta);
                $("#totalProductos").html(respuesta[0]['totalProductos']);
                $("#totalCompras").html(respuesta[0]['totalCompras'].replace(
                    /\d(?=(\d{3})+\.)/g, "$&,"))
                $("#totalVentas").html(respuesta[0]['totalVentas'].replace(
                    /\d(?=(\d{3})+\.)/g,
                    "$&,"))
                $("#totalGanancias").html(respuesta[0]['ganancias'].replace(
                    /\d(?=(\d{3})+\.)/g, "$&,"))
                $("#totalProductosMinStock").html(respuesta[0]['productosPocoStock'])
                $("#totalVentasHoy").html(respuesta[0]['ventasHoy'].replace(
                    /\d(?=(\d{3})+\.)/g, "$&,"))
            }
        });
    }, 10000);


    /* =======================================================
    SOLICITUD AJAX GRAFICO DE BARRAS DE VENTAS DEL MES
    =======================================================*/
    $.ajax({
        url: "ajax/dashboard.ajax.php",
        method: 'POST',
        data: {
            'accion': 1 //parametro para obtener las ventas del mes
        },
        dataType: 'json',
        success: function(respuesta) {
            // console.log("respuesta", respuesta);

            var fecha_venta = [];
            var total_venta = [];
            var total_venta_ant = [];

            var total_ventas_mes = 0;

            for (let i = 0; i < respuesta.length; i++) {

                fecha_venta.push(respuesta[i]['fecha_venta']);
                total_venta.push(respuesta[i]['total_venta']);
                total_venta_ant.push(respuesta[i]['total_venta_ant']);
                total_ventas_mes = parseFloat(total_ventas_mes) + parseFloat(respuesta[i][
                    'total_venta'
                ]);

            }

            total_venta.push(0);
            // total_venta.push(600);

            // console.log(total_ventas_mes);

            $("#title-header").html('Ventas del Mes: S./ ' + total_ventas_mes.toString().replace(
                /\d(?=(\d{3})+\.)/g, "$&,"));

            var barChartCanvas = $("#barChart").get(0).getContext('2d');

            var areaChartData = {
                labels: fecha_venta,
                datasets: [{
                    label: 'Ventas del Anterior - Diciembre 2021',
                    backgroundColor: 'rgb(255, 140, 0,0.9)',
                    data: total_venta_ant
                }, {
                    label: 'Ventas del Mes - Enero 2022',
                    backgroundColor: 'rgba(60,141,188,0.9)',
                    data: total_venta
                }]
            }

            var barChartData = $.extend(true, {}, areaChartData);

            var temp0 = areaChartData.datasets[0];

            barChartData.datasets[0] = temp0;

            var barChartOptions = {
                maintainAspectRatio: false,
                responsive: true,
                events: false,
                legend: {
                    display: true
                },
                scales: {
                    xAxes: [{
                        stacked: true,
                    }],
                    yAxes: [{
                        stacked: true
                    }]
                },
                animation: {
                    duration: 500,
                    easing: "easeOutQuart",
                    onComplete: function() {
                        var ctx = this.chart.ctx;
                        ctx.font = Chart.helpers.fontString(Chart.defaults.global
                            .defaultFontFamily, 'normal',
                            Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';

                        this.data.datasets.forEach(function(dataset) {
                            for (var i = 0; i < dataset.data.length; i++) {
                                var model = dataset._meta[Object.keys(dataset
                                        ._meta)[0]].data[i]._model,
                                    scale_max = dataset._meta[Object.keys(dataset
                                        ._meta)[0]].data[i]._yScale.maxHeight;
                                ctx.fillStyle = '#444';
                                var y_pos = model.y - 5;
                                // Make sure data value does not get overflown and hidden
                                // when the bar's value is too close to max value of scale
                                // Note: The y value is reverse, it counts from top down
                                if ((scale_max - model.y) / scale_max >= 0.93)
                                    y_pos = model.y + 20;
                                ctx.fillText(dataset.data[i], model.x, y_pos);
                            }
                        });
                    }
                }
            }

            new Chart(barChartCanvas, {
                type: 'bar',
                data: barChartData,
                options: barChartOptions
            })


        }
    });
    
// listar los 10 productos mas vendidos---------------------------------------------------------------------------

    $.ajax({
        url: "ajax/dashboard.ajax.php",
        type: "POST",
        data: {
            'accion': 2 // listar los 10 productos mas vendidos
        },
        dataType:'json',
        success:function(respuesta){
            // console.log("respuesta",respuesta);

            for (let i = 0; i < respuesta.length; i++) {
                filas = '<tr>'+
                            '<td>'+ respuesta[i]["codigo_producto"] + '</td>'+
                            '<td>'+ respuesta[i]["descripcion_producto"] + '</td>'+
                            '<td>'+ respuesta[i]["cantidad"] + '</td>'+
                            '<td> S./ '+ respuesta[i]["total_venta"] + '</td>'+
                        '</tr>'
                $("#tbl_productos_mas_vendidos tbody").append(filas);
            }
            
        }
    });

    $.ajax({
        url: "ajax/dashboard.ajax.php",
        type: "POST",
        data: {
            'accion': 3 // listar los  productos con poco stock
        },
        dataType:'json',
        success:function(respuesta){
            // console.log("respuesta",respuesta);

            for (let i = 0; i < respuesta.length; i++) {
                filas = '<tr>'+
                            '<td>'+ respuesta[i]["codigo_producto"] + '</td>'+
                            '<td>'+ respuesta[i]["descripcion_producto"] + '</td>'+
                            '<td>'+ respuesta[i]["stock_producto"] + '</td>'+
                            '<td> S./ ' + respuesta[i]["minimo_stock_producto"] + '</td>'+
                        '</tr>'
                $("#tbl_productos_poco_stock tbody").append(filas);
            }
            
        }
    });

})