var layers = [
  new ol.layer.Tile({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new ol.source.TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "Boundaries", TILED: true },
      transition: 0,
    }),
  }),
  new ol.layer.Tile({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new ol.source.TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "OSM", TILED: true },
      transition: 0,
    }),
  }),
  new ol.layer.Tile({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new ol.source.TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "Orthophoto", TILED: true },
      transition: 0,
    }),
  }),
  new ol.layer.Tile({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new ol.source.TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "DTM", TILED: true },
      transition: 0,
    }),
  }),
  new ol.layer.Tile({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new ol.source.TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "Smallholding", TILED: true },
      transition: 0,
    }),
  }),
  new ol.layer.Tile({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new ol.source.TileWMS({
      url: "https://castelo.kartoza.com/map/?",
      params: { LAYERS: "Smallholding", TILED: true },
      transition: 0,
    }),
  }),
];
var map = new ol.Map({
  layers: layers,
  target: "map",
  view: new ol.View({
    center: [-10997148, 4569099],
    zoom: 4,
  }),
});

map.addControl(new ol.control.LayerSwitcher());

