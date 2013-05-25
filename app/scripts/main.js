require([
  // Application.
  'app',

  // Main Router.
  'router',

  'FastClick',

  'domReady'
],

function(app, Router, FastClick, domReady) {

  // FastClick to make phone touch devices more responsive.
  new FastClick(document.body);

  // Define your master router on the application namespace and trigger all
  // navigation from this instance.
  app.router = new Router();

  domReady(function() {
    document.addEventListener('deviceready', startWhenReady, false);
  });

  function startWhenReady() {
    $(document).on('click', 'a', function(event) {
      event.preventDefault();
      window.open(event.currentTarget.href, '_blank', 'location=yes');
    });

    app.router.index();
  };
});
