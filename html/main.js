window.onload = init();

function init() {
    var map = new ol.Map({
        view: new ol.View({
            center: [-1543795.4, 4232854.9],
            zoom: 5,
        }),

        layers: [
            new ol.layer.Tile({
                title: "Boundaries",
                extent: [-1543795.4, 4232854.9, -301891.2, 5312385.6],
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/mapproxy/service?",
                    transition: 1,
                    params: {
                        'LAYERS': "Boundaries",
                        'TILED': true
                    },
                })

            }),
            new ol.layer.Tile({
                title: "OSM",
                extent: [-867671.9, 4743686.0, -787701.3, 4813200.8],
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/mapproxy/service?",
                    transition: 1,
                    params: {
                        'LAYERS': "OSM",
                        'TILED': true
                    },
                })

            }),
            new ol.layer.Tile({
                title: "Smallholding",
                extent: [-822553.0, 4780579.4, -821704.8, 4781316.7],
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/mapproxy/service?",
                    transition: 1,
                    params: {
                        'LAYERS': "Smallholding",
                        'TILED': true
                    },
                })

            })

        ],
        target: 'ol-map',
    });
};