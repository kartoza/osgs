window.onload = init();

function display(id, value) {
    document.getElementById(id).value = value.toFixed(2);
}

function wrapLon(value) {
    var worlds = Math.floor((value + 180) / 360); return value - worlds * 360;
}

function onMoveEnd(evt) {
    var map = evt.map;
    var extent = map.getView().calculateExtent(map.getSize());
    document.getElementById('minx').textContent = Math.floor(extent[0]);
    document.getElementById('miny').textContent = Math.floor(extent[1]);
    document.getElementById('maxx').textContent = Math.floor(extent[2]);
    document.getElementById('maxy').textContent = Math.floor(extent[3]);
}

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
                extent: [ -822268.483000652, 4780883.439473242, -821994.440735224, 4781022.184142217 ],
            })
        ]),
        extent: [ -822268.483000652, 4780883.439473242, -821994.440735224, 4781022.184142217 ],
        constrainOnlyCenter: true,
        view: new ol.View({
            center: [-822268.483000652, 4780883.439473242],
            zoom: 15,
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
                visible: false,
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
                //content display will be clipped to this extent
                extent: [ -822438.3339819671, 4780780.531185782, -821790.3266751256, 4781108.610356856 ],
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/mapproxy/service?",
                    transition: 1,
                    params: {
                        'LAYERS': "Smallholding",
                        'TILED': true
                    },
                })
            }),
            new ol.layer.Tile({
                title: "Smallholding - no caching",
                visible: false,
                //content display will be clipped to this extent
                extent: [ -822438.3339819671, 4780780.531185782, -821790.3266751256, 4781108.610356856 ],
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/map/",
                    transition: 1,
                    params: {
                        'LAYERS': "Smallholding",
                        'TILED': true
                    },
                })
            }),
            new ol.layer.Tile({
                title: "Labels - Small Scale",
                visible: true,
                source: new ol.source.TileWMS({
                    url: "https://castelo.kartoza.com/mapproxy/service?",
                    transition: 1,
                    params: {
                        'LAYERS': "Labels Small Scale",
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
    map.on('moveend', onMoveEnd);
};
