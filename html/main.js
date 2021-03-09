window.onload = init();

function init() {
    var mousePositionControl = new ol.control.MousePosition({
        coordinateFormat: ol.coordinate.createStringXY(4),
        projection: 'EPSG:4326',
        // comment the following two lines to have the mouse position
        // be placed within the map.
        className: 'custom-mouse-position',
        target: document.getElementById('mouse-position'),
        undefinedHTML: '&nbsp;',
    });
    var map = new ol.Map({
        controls: ol.control.defaults().extend([
            mousePositionControl,
            new ol.control.ZoomToExtent({
                extent: [-1245324, 5235961, -353763, -549441, 4363968],
            })
        ]),
        extent: [-1245324, 5235961, -353763, -549441, 4363968],
        constrainOnlyCenter: true,
        view: new ol.View({
            center: [-844183, 4779174],
            zoom: 7,
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
                title: "Orthophoto",
                extent: [-822553.0, 4780579.4, -821704.8, 4781316.7],
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/mapproxy/service?",
                    transition: 1,
                    params: {
                        'LAYERS': "Orthophoto",
                        'TILED': true
                    },
                })

            }),
            new ol.layer.Tile({
                title: "DTM",
                visible: false,
                extent: [-822553.0, 4780579.4, -821704.8, 4781316.7],
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/mapproxy/service?",
                    transition: 1,
                    params: {
                        'LAYERS': "DTM",
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

            }),

        ],
        target: 'ol-map',
    });
    var layerSwitcher = new ol.control.LayerSwitcher({
        tipLabel: 'Legend', // Optional label for button
        groupSelectStyle: 'children' // Can be 'children' [default], 'group' or 'none'
    });
    map.addControl(layerSwitcher);
};