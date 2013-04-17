define [
  'leaflet'
], (Leaflet) ->
  class MapControl
    constructor: (@el) ->
      @createMap()
      @findLocation

    createMap: ->
      @map = L.map(@el,
        zoomControl: false
      ).locate
        setView: true
        maxZoom: 16

      L.tileLayer('http://{s}.tiles.mapbox.com/v3/mpl.map-glvcefkt/{z}/{x}/{y}.png'
        detectRetina: true
        maxZoom: 24
      ).addTo @map

      @map.on('locationfound', @addCurrentLocationMarker)

    addCurrentLocationMarker: (e) =>
      radius = e.accuracy / 2

      circle = L.circle e.latlng, radius,
        weight: 1

      centerPoint = new MapMarker(e.latlng.lat, e.latlng.lng, 'map-current-location')

      layers = new L.layerGroup([
        circle
        centerPoint
      ]).addTo(@map);

    addMarker: (lat, lng) ->
      marker = new MapMarker(lat, lng)
      marker.addTo(@map)

  class MapMarker
    constructor: (@lat, @lng, @className = 'map-marker') ->
      return @createMarker()

    createMarker: ->
      new L.Marker [@lat, @lng],
        icon: @markerIcon()

    markerIcon: ->
      new L.DivIcon
        className: @className

  return MapControl
