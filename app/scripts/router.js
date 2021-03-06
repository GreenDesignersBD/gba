'use strict';
define([
  // Application.
  'app',
  'collections/items',
  'views/map_tiles',
  'views/controls',
  'views/items',
  'views/results'
],

function(app, ItemCollection, MapTiles, ControlsView, ItemsPanel, ResultsPanel) {

  // Defining the application router, you can attach sub routers here.
  var Router = Backbone.Router.extend({
    routes: {
      '': 'index'
    },

    index: function() {
      var items = new ItemCollection();

      items.currentlyFetching = false;

      items.listenToOnce(app, 'locationfound', function() {
        items.fetchWithDefaults({
          reset: true
        });
      });

      items.listenTo(app, 'map:fetchItems', function(boundsString) {
        if (items.currentlyFetching === false) {
          items.currentlyFetching = true;
          items.fetch({
            remove: false,
            success: function (collection, response) {
              items.currentlyFetching = false;
            },
            error: function (collection, response) {
              items.currentlyFetching = false;
            }
          });
        }
      });

      app.items = items;

      app.useLayout('map_panel').insertViews({
        '.controls': new ControlsView({
          el: false,
          collection: items
        }),
        '.tiles'   : new MapTiles({
          el: false,
          collection: items
        }),
        '' : new ItemsPanel({
          tag: 'div',
          className: 'item-container hidden',
          collection: items
        })
      }).render();

      app.layout.listenTo(items, 'open', function () {
        var $container = this.$el.addClass('open-item').find('.item-container');
        var setHeight = function() {
          $container.height($('#main').height());
        };

        setHeight();

        $(window).on('resize.openitem', setHeight);
      });

      app.layout.listenTo(items, 'close', function() {
        this.$el.find('.item-container').
          css('height', '').
        end().
        removeClass('open-item');
        $(window).off('resize.openitem');

      });

      app.layout.listenTo(app, 'viewToggle', function() {
        if (this.resultsView == null) {
          this.resultsView = new ResultsPanel({
            collection : items,
            el: false
          });
          this.insertView(this.resultsView).render();
        }

        var setHeight = function () {
          $('.results').height(window.innerHeight - 55);
        };

        $(window).on('resize', setHeight);

        this.$el.toggleClass('map list');
      });
    }
  });

  return Router;

});
