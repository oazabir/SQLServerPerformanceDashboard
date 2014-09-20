
var plots = [];

function initData(count) {
    var data = [];
    for (var i = 0; i < count; i++)
        data.push(0);
    return data;
}

function updatePlot() {
    if (typeof $.plot == "undefined")
        return;
    var index = 0;

    $.each(datasets, function (key, val) {
        var items = [];
        for (var i = 0; i < val.data.length; i++)
            items.push([i, val.data[i]]);

        var data = { color: val.color, data: items, threshold: val.threshold };

        if (plots[index] != null) {
            plot = plots[index];
            plot.setData([data]);
            plot.draw();
        }
        else {
            plot = $.plot("#placeholder" + (index + 1), [data], {
                series: {
                    //shadowSize: 0	// Drawing is faster without shadows
                },
                lines: { show: true, fill: true },
                grid: {
                    hoverable: true,
                    clickable: true
                },
                yaxis: {
                    min: 0,
                    max: val.ymax
                },
                xaxis: {
                    show: false
                }
            });
            $("#placeholder" + (index + 1)).bind("plothover", function (event, pos, item) {                
                var str = "(" + pos.y.toFixed(2) + ")";
                $("#hoverdata").text(str);                

                if (item) {
                    var x = item.datapoint[0].toFixed(2),
                        y = item.datapoint[1].toFixed(2);

                    $("#tooltip").html(item.label + " = " + y)
                        .css({ top: item.pageY + 5, left: item.pageX + 5 })
                        .fadeIn(200);
                } else {
                    $("#tooltip").hide();
                }
                
            });
            plot.draw();
            plots[index] = plot;
        }
        ++index;
    });
}

window.setContent = function(iframe, id) {
    $('#' + id)
        .find('td.large-cell').off('click');

    if ($('#' + id).scrollLeft() == 0 && $('#' + id).scrollTop() == 0) {
        $('#' + id)
            .html($(iframe).contents().find("form").html())
            .dblclick(function () {
                iframe.contentWindow.location.reload();
            })
            .find('td.large-cell').find('div').click(function () {
                $('#content_text').text($(this).html());
                $('#basic-modal-content').modal();
            });                   
    }

    $(iframe).contents().find("form").find(".x-axis").each(function (i, e) {
        var x = $(e);
        var y = x.next('.y-axis');
        var xname = x.text();
        var yvalue = parseFloat(y.text());
        if (datasets[xname]) {
            var data = datasets[xname].data;
            data.pop();
            data.splice(0, 0, yvalue);
        }
    });

    updatePlot();   
}

$(document).ready(function () {
    $("<div id='tooltip'></div>").css({
        position: "absolute",
        display: "none",
        border: "1px solid #fdd",
        padding: "2px",
        "background-color": "#fee",
        opacity: 0.80
    }).appendTo("body");
    //updatePlot();
});