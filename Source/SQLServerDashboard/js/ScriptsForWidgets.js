window.refreshEvery = function(mili) {
    var refreshtimer = window.setTimeout(function () { window.location.reload(); }, mili);

    document.ondblclick = function () {
        window.clearTimeout(refreshtimer);
    }
}

window.applyPlotAxis = function(plot) {
    $('td').each(function (i, e) {
        var td = $(e);
        if (td.text().trim().length > 0) {
            for (var i = 0; i < plot.length; i++) {
                if (plot[i] == td.text().trim()) {
                    td.addClass("x-axis");
                    td.next().addClass("y-axis");                    
                }
            }
        }
    })
}

window.applyLargeCells = function(selector) {
    $('tr').each(function (i, tr) {
        var td = $(selector, tr);
        td.html('<div>' + td.html() + '</div>');
        td.addClass('large-cell');
        td.find('div').click(function () {
            alert($(this).text())
        });
    });
}