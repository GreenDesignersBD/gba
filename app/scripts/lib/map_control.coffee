define [
  'app',
  'leaflet'
], (app, Leaflet) ->

  class MapControl
    constructor: (@el) ->
      @createMap()

    createMap: ->
      @mapFactory = new MapFactory(@el)
      @map = @mapFactory.map
      @map.on 'locationfound', (e) =>
        @currentLocation = e.latlng
        @mapFactory.updateCurrentLocationMarker(e)
        app.trigger 'locationfound'

      @items = L.layerGroup().addTo(@map)

    addMarker: (lat, lng) ->
      marker = new MapMarker(lat, lng)
      @items.addLayer marker
      marker

    clearMarkers: ->
      @items.clearLayers()

    getDistance: (latlng) ->
      @currentLocation.distanceTo(latlng)

  class MapFactory
    constructor: (@el) ->
      @createMap()
      @createTiles().addTo @map

      app.on 'geoLocate', @locate
      @map.on 'locationerror', @locationError
      @locate()

      @map.on 'click', (e) ->
        app.trigger 'map:Interaction'

    createMap: ->
      @map = L.map @el,
        zoomControl        : false
        attributionControl : false
        maxZoom            : 16
        minZoom            : 2
        worldCopyJump      : true

    createTiles: ->
      L.tileLayer 'http://{s}.tiles.mapbox.com/v3/mpl.map-glvcefkt/{z}/{x}/{y}.png',
        detectRetina: true
        maxZoom: 24

    updateCurrentLocationMarker: (e) =>
      unless @currentMarker?
        @currentMarker ?= new CurrentLocationMarker e.latlng, e.accuracy
        @currentMarker.layers.addTo(@map);

      else
        @currentMarker.update e.latlng, e.accuracy

    locate: =>
      @map.locate
        setView: true

    locationError: (e) =>
      app.trigger 'locationError'
      unless @currentMarker
        @map.setView([46, -95], 2)

  class MapMarker
    constructor: (@lat, @lng, @className) ->
      return @createMarker()

    createMarker: ->
      new L.Marker [@lat, @lng],
        icon: @markerIcon()

    markerIcon: ->
      options =
        iconSize: L.point(34, 34)

      if @className?
        options['className'] = @className

      new L.DivIcon options

  class CurrentLocationMarker
    constructor: (@latlng, @accuracy) ->
      @layers = new L.LayerGroup @currentLocationLayers()

    currentLocationLayers: () ->
      radius = @accuracy / 2

      @circle = L.circle @latlng, radius,
        weight: 1

      @centerpoint = new MapMarker(@latlng.lat, @latlng.lng, 'map-current-location')

      return [@circle, @centerpoint]

    update: (@latlng, @accuracy) ->
      @circle.setLatLng @latlng
      @circle.setRadius(@accuracy / 2)
      @centerpoint.setLatLng @latlng

  return MapControl
