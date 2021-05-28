// openlayers map
// https://openlayers.org/en/latest/doc/quickstart.html
document.addEventListener('DOMContentLoaded', () => {

  var map = new ol.Map({
      target: 'pagemap',
      layers: [
        new ol.layer.Tile({
          source: new ol.source.OSM()
        })
      ],
      view: new ol.View({
        center: ol.proj.fromLonLat([-61, 14]),
        zoom: 13
      })
    });

  });