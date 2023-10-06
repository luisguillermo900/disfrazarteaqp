$(document).ready(function(){

    var table, ventas_desde, ventas_hasta;
    var groupColumn = 0;

    $('#ventas_desde, #ventas_hasta').inputmask('dd/mm/yyyy', {
        'placeholder': 'dd/mm/yyyy'
    })

    $("#ventas_desde").val(moment().startOf('month').format('DD/MM/YYYY'));
    $("#ventas_hasta").val(moment().format('DD/MM/YYYY'));

    ventas_desde = $("#ventas_desde").val();
    ventas_hasta = $("#ventas_hasta").val();
    
    ventas_desde = ventas_desde.substr(6,4) + '-' + ventas_desde.substr(3,2) + '-' + ventas_desde.substr(0,2) ;        
    //console.log("🚀 ~ file: administrar_ventas.php ~ line 97 ~ $ ~ ventas_desde", ventas_desde)
    ventas_hasta = ventas_hasta.substr(6,4) + '-' + ventas_hasta.substr(3,2) + '-' + ventas_hasta.substr(0,2) ;
    //console.log("🚀 ~ file: administrar_ventas.php ~ line 99 ~ $ ~ ventas_hasta", ventas_hasta)

    table = $('#lstVentas').DataTable({  
        "columnDefs": [
            { visible: false, targets: groupColumn },
            {
                targets: [1,2,3,4,5],
                orderable: false
            }
        ],
        "order": [[ 6, 'desc' ]],
        dom: 'Bfrtip',
        buttons: [
            'excel', 'print', 'pageLength',

        ],
        lengthMenu: [0, 5, 10, 15, 20, 50],
        "pageLength": 15,
        ajax: {
            url: 'ajax/ventas.ajax.php',
            type: 'POST',
            dataType: 'json',
            "dataSrc": "",
            data: {
                'accion': 2,
                'fechaDesde': ventas_desde,
                'fechaHasta' : ventas_hasta
            }                              
        },
        drawCallback: function (settings) {
            
            var api = this.api();
            var rows = api.rows( {page:'current'} ).nodes();
            var last=null;

            api.column(groupColumn, {page:'current'} ).data().each( function ( group, i ) {                
                                
                if ( last !== group ) {

                    const data = group.split("-");
                    var nroBoleta = data[0];
                    nroBoleta = nroBoleta.split(":")[1].trim();                        
                    console.log("🚀 ~ file: administrar_ventas.php ~ line 134 ~ nroBoleta", nroBoleta)

                    $(rows).eq(i).before(
                        '<tr class="group">'+
                            '<td colspan="6" class="fs-6 fw-bold fst-italic bg-success text-white"> ' +
                                '<i nroBoleta = ' + nroBoleta + ' class="fas fa-trash fs-6 text-danger mx-2 btnEliminarVenta" style="cursor:pointer;"></i> '+
                                    group +  
                            '</td>'+
                        '</tr>'
                    );

                    last = group;
                }
            } );
        },
        language: {
            "url": "//cdn.datatables.net/plug-ins/1.10.20/i18n/Spanish.json"
        }
    });


})