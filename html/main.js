window.onload = init();

// For updating extents display as you pan and zoom

function onMoveEnd(evt) {
    var map = evt.map;
    var extent = map.getView().calculateExtent(map.getSize());
    document.getElementById('minx').textContent = Math.floor(extent[0]);
    document.getElementById('miny').textContent = Math.floor(extent[1]);
    document.getElementById('maxx').textContent = Math.floor(extent[2]);
    document.getElementById('maxy').textContent = Math.floor(extent[3]);
}


// Setup openlayers and initial load of layers

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

	// smallholding source and view defined separately so we can use them for GFI requests
	var smallholdingSource = new ol.source.TileWMS({
					url: "https://castelo.kartoza.com/map/",
					transition: 1,
					params: {
						'LAYERS': "Smallholding",
						'TILED': true
					},
				})
        var view = new ol.View({
			center: [ -822123,4780956 ],
			zoom: 19,
			maxZoom: 25,
		});
	var map = new ol.Map({
		controls: ol.control.defaults().extend([
			mousePositionControl,
			new ol.control.ZoomToExtent({
				extent: [  -822351,4780704,-821943,4781120  ],
			})
		]),
		extent: [  -822351,4780704,-821943,4781120  ],
		constrainOnlyCenter: true,
		view: view,
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
				source: smallholdingSource
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
	map.addControl(layerSwitcher);
	map.on('moveend', onMoveEnd);

	// Next section for handling getFeatureInfo interactions

	map.on('singleclick', function (evt) {
		document.getElementById('info').innerHTML = '';
		var viewResolution = /** @type {number} */ (view.getResolution());
		var url = smallholdingSource.getFeatureInfoUrl(
			evt.coordinate,
			viewResolution,
			'EPSG:3857',
			{'INFO_FORMAT': 'text/html'}
		);
		if (url) {
			fetch(url)
				.then(function (response) { return response.text(); })
				.then(function (html) {
					document.getElementById('info').innerHTML = html;
				});
		}
	});

	map.on('pointermove', function (evt) {
		if (evt.dragging) {
			return;
		}
		var pixel = map.getEventPixel(evt.originalEvent);
		var hit = map.forEachLayerAtPixel(pixel, function () {
			return true;
		});
		map.getTargetElement().style.cursor = hit ? 'pointer' : '';
	});
};
