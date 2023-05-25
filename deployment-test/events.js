jQuery(document).on("click", "#bPrediction", function () {
    fecha = jQuery("#date").val().replace("/", "-") + " " + jQuery("#hour").val();
    nPredicciones = jQuery("#nPredictions").val();

    $.ajax({
        type: "GET",
        url: "http://api.k8s-tfm.tk/getPrediction",
        data: {
            fecha: fecha,
            nPredicciones: nPredicciones,
        },
        success: function (response) {
            data = response;
            drawPrediction(response);
        },
        error: function (response) {
            error = response;
            showError(response);
        },
    });
});

jQuery(document).on("click", "#bSeeData", function () {
    fecha = jQuery("#date").val().replace("/", "-") + " " + jQuery("#hour").val();
    nPredicciones = jQuery("#nPredictions").val();

    $.ajax({
        type: "GET",
        url: "http://api.k8s-tfm.tk/getPoint",
        data: {
            fecha: fecha,
            nPredicciones: nPredicciones,
        },
        success: function (response) {
            drawPoint(response);
        },
        error: function (response) {
            error = response;
            showError(response);
        },
    });
});

let lienzo;
function drawPrediction(data) {
    if (jQuery(".alert").is(":visible")) {
        jQuery(".alert").remove();
    }

    fecha = [];
    real = [];
    pred = [];
    for (i of data) {
        fecha.push(i.date);
        real.push(i.real);
        pred.push(i.prediccion);
    }

    if (lienzo) {
        lienzo.destroy();
    }

    var ctx = document.getElementById("myChart").getContext("2d");
    lienzo = new Chart(ctx, {
        type: "line",
        data: {
            labels: fecha,
            datasets: [
                {
                    label: "Precio real",
                    data: real,
                    borderColor: ["rgb(67, 171, 151)"],
                    borderWidth: 1.5,
                    pointRadius: 0,
                    pointHitRadius: 6,
                },
                {
                    label: "Predicción",
                    data: pred,
                    borderColor: ["rgb(184, 55, 55)"],
                    borderWidth: 1.5,
                    pointRadius: 0,
                    pointHitRadius: 6,
                },
            ],
        },
        options: {
            scales: {
                y: {
                    title: {
                        display: true,
                        text: "Precio de cierre en dólares($)",
                    },
                    beginAtZero: false,
                },
                x: {
                    title: {
                        display: true,
                        text: "Fecha",
                    },
                },
            },
        },
    });
}

function drawPoint(data) {
    if (jQuery(".alert").is(":visible")) {
        jQuery(".alert").remove();
    }

    fecha = [];
    real = [];
    for (i of data) {
        fecha.push(i.date);
        real.push(i.real);
    }

    if (lienzo) {
        lienzo.destroy();
    }

    var ctx = document.getElementById("myChart").getContext("2d");
    lienzo = new Chart(ctx, {
        type: "line",
        data: {
            labels: fecha,
            datasets: [
                {
                    label: "Precio real",
                    data: real,
                    borderColor: ["rgb(67, 171, 151)"],
                    borderWidth: 1.5,
                    pointRadius: 0,
                    pointHitRadius: 6,
                },
            ],
        },
        options: {
            scales: {
                y: {
                    title: {
                        display: true,
                        text: "Precio de cierre en dólares($)",
                    },
                    beginAtZero: false,
                },
                x: {
                    title: {
                        display: true,
                        text: "Fecha",
                    },
                },
            },
        },
    });
}

function showError(response) {
    if (jQuery(".alert").is(":visible")) {
        jQuery(".alert").remove();
    }

    jQuery("#alert").append(
        "<div class='alert alert-warning' role='alert'>" +
        response.responseText +
        "<div>"
    );
}