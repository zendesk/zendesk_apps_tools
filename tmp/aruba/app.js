(function() {
  return {
    events: {
      'app.activated': 'appActivated'
    },
    appActivated: function() {
      services.notify('Activated!');
    }
  };
}());