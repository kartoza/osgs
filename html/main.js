import "ol/ol.css";
import Map from "ol/Map";
import TileLayer from "ol/layer/Tile";
import TileWMS from "ol/source/TileWMS";
import View from "ol/View";

var layers = [
  new TileLayer({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "Boundaries", TILED: true },
      transition: 0,
    }),
  }),
  new TileLayer({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "OSM", TILED: true },
      transition: 0,
    }),
  }),
  new TileLayer({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "Orthophoto", TILED: true },
      transition: 0,
    }),
  }),
  new TileLayer({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "DTM", TILED: true },
      transition: 0,
    }),
  }),
  new TileLayer({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new TileWMS({
      url: "https://castelo.kartoza.com/mapproxy/service?",
      params: { LAYERS: "Smallholding", TILED: true },
      transition: 0,
    }),
  }),
  new TileLayer({
    extent: [-13884991, 2870341, -7455066, 6338219],
    source: new TileWMS({
      url: "https://castelo.kartoza.com/map/?",
      params: { LAYERS: "Smallholding", TILED: true },
      transition: 0,
    }),
  }),
];
var map = new Map({
  layers: layers,
  target: "map",
  view: new View({
    center: [-10997148, 4569099],
    zoom: 4,
  }),
});

var map = L.map("map", {
  center: [-7.3850817, 39.412649],
  zoom: 3,
});


