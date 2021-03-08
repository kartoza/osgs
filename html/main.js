var layers = [
    new ol.layer.Tile({
        title: "Watercolor",
        source: new ol.source.Stamen({ layer: 'watercolor' }),
        baseLayer: true,
        transition: 0,
    }),
    new ol.layer.Tile({
        title: "Boundaries",
        source: new ol.source.TileWMS({
            url: "https://castelo.kartoza.com/mapproxy/service?",
            params: { LAYERS: "Boundaries", TILED: true },
            transition: 1,
        }),
    }),
    new ol.layer.Tile({
        title: "OSM",
        source: new ol.source.TileWMS({
            url: "https://castelo.kartoza.com/mapproxy/service?",
            params: { LAYERS: "OSM", TILED: true },
            transition: 0,
        }),
    }),
    new ol.layer.Tile({
        title: "Orthophoto",
        source: new ol.source.TileWMS({
            url: "https://castelo.kartoza.com/mapproxy/service?",
            params: { LAYERS: "Orthophoto", TILED: true },
            transition: 0,
        }),
    }),
    new ol.layer.Tile({
        title: "DTM",
        source: new ol.source.TileWMS({
            url: "https://castelo.kartoza.com/mapproxy/service?",
            params: { LAYERS: "DTM", TILED: true },
            transition: 0,
        }),
    }),
    new ol.layer.Tile({
        title: "Smallholding - Mapproxy",
        source: new ol.source.TileWMS({
            url: "https://castelo.kartoza.com/mapproxy/service?",
            params: { LAYERS: "Smallholding", TILED: true },
            transition: 0,
        }),
    }),
    new ol.layer.Tile({
        title: "Smallholding - No Mapproxy",
        source: new ol.source.TileWMS({
            url: "https://castelo.kartoza.com/map/?",
            params: { LAYERS: "Smallholding", TILED: true },
            transition: 0,
        }),
    }),
];
map = new ol.Map({
    layers: layers,
    target: "map",
    view: new ol.View({
        projection: 'EPSG:3857',
        extent: [-821765.3967463834, 4781173.761551047],
        zoom: 20,
    }),
});

map.addControl(new ol.control.LayerSwitcher());