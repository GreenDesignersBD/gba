define [ 
  'app'
  'lib/distance_helper'
], (app, DistanceHelper) ->
  class ItemModel extends Backbone.Model
    initialize: ->
      @set 'distance', 'No Geolocation'
      @on 'addMarker', @hasMarker

    hasMarker: (marker) =>
      @marker = marker
      if app.mapControl.currentLocation?
        @setDistance()
      else
        app.on 'locationfound', @setDistance

    setDistance: =>
      distance = app.mapControl.getDistance @marker.getLatLng()
      @set 'distance', new DistanceHelper(distance).humanize()

  return ItemModel
