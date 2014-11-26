Package.describe({
  name: 'respondly:ctrls-input',
  summary: 'UI controls that take input from the user',
  version: '0.0.1',
  git: 'https://github.com/Respondly/meteor-ctrls-input.git'
});



Package.onUse(function (api) {
  api.use(['coffeescript', 'http']);
  api.use(['templating', 'ui', 'spacebars'], 'client');
  api.use(['respondly:ctrl', 'respondly:util', 'respondly:css-stylus']);
  api.export('Ctrls');

  // Generated with: github.com/philcockfield/meteor-package-paths
  api.addFiles('shared/ns.js', ['client', 'server']);
  api.addFiles('shared/css-mixins/textbox.import.styl', 'client');
  api.addFiles('shared/css-mixins/textbox.import.styl', 'server', { isAsset:true });
  api.addFiles('shared/util.coffee', ['client', 'server']);
  api.addFiles('client/textboxes/content-editable/ctrl/content-editable.html', 'client');
  api.addFiles('client/textboxes/raw-textbox/raw-textbox.html', 'client');
  api.addFiles('client/textboxes/text-input/text-input.html', 'client');
  api.addFiles('client/button/button.html', 'client');
  api.addFiles('client/checkbox/checkbox.html', 'client');
  api.addFiles('client/checkbox-tree/checkbox-tree.html', 'client');
  api.addFiles('client/radio/radio.html', 'client');
  api.addFiles('client/radios/radios.html', 'client');
  api.addFiles('client/select/select.html', 'client');
  api.addFiles('client/textboxes/content-editable/lib/css/medium-editor.css', 'client');
  api.addFiles('client/textboxes/content-editable/lib/css/theme-default.css', 'client');
  api.addFiles('client/textboxes/content-editable/lib/js/medium-editor.js', 'client');
  api.addFiles('client/textboxes/content-editable/ctrl/content-editable.coffee', 'client');
  api.addFiles('client/textboxes/content-editable/ctrl/content-editable.styl', 'client');
  api.addFiles('client/textboxes/validation/email_validator.coffee', 'client');
  api.addFiles('client/textboxes/validation/screen_name_validator.coffee', 'client');
  api.addFiles('client/textboxes/content-editable/content-editable-controller.coffee', 'client');
  api.addFiles('client/textboxes/content-editable/css.styl', 'client');
  api.addFiles('client/textboxes/raw-textbox/raw-textbox.coffee', 'client');
  api.addFiles('client/textboxes/raw-textbox/raw-textbox.styl', 'client');
  api.addFiles('client/textboxes/text-input/text-input.coffee', 'client');
  api.addFiles('client/textboxes/text-input/text-input.styl', 'client');
  api.addFiles('client/button/button.coffee', 'client');
  api.addFiles('client/button/button.styl', 'client');
  api.addFiles('client/textboxes/textbox-date.coffee', 'client');
  api.addFiles('client/checkbox/checkbox.coffee', 'client');
  api.addFiles('client/checkbox/checkbox.styl', 'client');
  api.addFiles('client/checkbox-tree/checkbox-tree.coffee', 'client');
  api.addFiles('client/checkbox-tree/checkbox-tree.styl', 'client');
  api.addFiles('client/radio/radio.coffee', 'client');
  api.addFiles('client/radio/radio.styl', 'client');
  api.addFiles('client/radios/radios.coffee', 'client');
  api.addFiles('client/radios/radios.styl', 'client');
  api.addFiles('client/select/select.coffee', 'client');
  api.addFiles('client/select/select.styl', 'client');
  api.addFiles('client/common.styl', 'client');
  api.addFiles('client/data-binder.coffee', 'client');
  api.addFiles('images/text_input_error.svg', ['client', 'server']);
  api.addFiles('images/text_input_tick.svg', ['client', 'server']);

});


