Package.describe({
  summary: ''
});



Package.on_use(function (api) {
  api.use(['coffeescript', 'sugar', 'http']);
  api.use(['templating'], 'client');
  api.use(['ctrl', 'util', 'stylus-compiler']);

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.add_files('client/api.coffee', 'client');

});



Package.on_test(function (api) {
  api.use(['munit', 'coffeescript', 'chai']);
  api.use('ctrl-input');

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.add_files('tests/shared/_init.coffee', ['client', 'server']);
  api.add_files('tests/shared/tests.coffee', ['client', 'server']);

});
