Package.describe({
  summary: ''
});



Package.on_use(function (api) {
  api.use(['coffeescript', 'sugar', 'http']);
  api.use(['templating'], 'client');
  api.use(['ctrl', 'util', 'stylus-compiler']);

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.add_files('client/checkbox-slider/checkbox-slider.html', 'client');
  api.add_files('client/checkbox-slider/checkbox-slider.coffee', 'client');
  api.add_files('client/checkbox-slider/checkbox-slider.styl', 'client');

});


