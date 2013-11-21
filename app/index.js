'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');


var CoffeeRequirejsGenerator = module.exports = function CoffeeRequirejsGenerator(args, options, config) {
  yeoman.generators.Base.apply(this, arguments);

  this.on('end', function () {
    this.installDependencies({ skipInstall: options['skip-install'] });
  });

  this.pkg = JSON.parse(this.readFileAsString(path.join(__dirname, '../package.json')));
};

util.inherits(CoffeeRequirejsGenerator, yeoman.generators.Base);

CoffeeRequirejsGenerator.prototype.app = function app() {
  var dirs = [
    'app',
    'app/scripts',
    'app/templates',
    'app/styles',
    'app/images',
    'test',
    'test/scripts',
    'test/templates'
  ];

  var templates = [
    'package.json',
    'bower.json',
    'app/index.html'
  ];

  var files = [
    [ 'Gruntfile.coffee' ],
    [ 'test/karma.conf.coffee' ],
    [ 'test/test-main.coffee' ],
    [ 'editorconfig', '.editorconfig' ],
    [ 'bowerrc', '.bowerrc' ],
    [ 'app/favicon.ico' ],
    [ 'app/404.html' ],
    [ 'app/robots.txt' ],
    [ 'app/htaccess', 'app/.htaccess' ],
    [ 'app/scripts/config.js' ],
    [ 'app/scripts/main.coffee' ]
  ];

  var _this = this;

  // Yeoman applies templates, even when just copying. Circumvent that
  function avoidTemplating(body) {
    return body.replace(/<%/g, '<%%');
  }

  dirs.forEach(function(path) { _this.mkdir(path); });
  templates.forEach(function(path) { _this.template(path + '.template', path); });
  files.forEach(function(paths) { _this.copy.apply(_this, paths.concat([avoidTemplating])); });
};
