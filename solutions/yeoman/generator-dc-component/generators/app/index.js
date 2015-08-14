'use strict';
var yeoman = require('yeoman-generator');
var chalk = require('chalk');
var yosay = require('yosay');

var mkdirp = require('mkdirp');

module.exports = yeoman.generators.Base.extend({
  prompting: function () {
    var done = this.async();

    // Have Yeoman greet the user.
    this.log(yosay(
      'Welcome to the well-made ' + chalk.red('DcComponent') + ' generator!'
    ));

    var prompts = [{
      type: 'confirm',
      name: 'someOption',
      message: 'Would you like to enable this option?',
      default: true
    }];

    this.prompt(prompts, function (props) {
      this.props = props;
      // To access props later use this.props.someOption;

      done();
    }.bind(this));
  },

  writing: {
    app: function () {
      // folds
      mkdirp('src/html');
      mkdirp('src/js');
      mkdirp('src/css');
      mkdirp('src/img');
      // files
      this.fs.copy(
        this.templatePath('_package.json'),
        this.destinationPath('package.json')
      );
      this.fs.copy(
        this.templatePath('_bower.json'),
        this.destinationPath('bower.json')
      );
      this.fs.copy(
        this.templatePath('bowerrc'),
        this.destinationPath('bowerrc')
      );
      this.fs.copy(
        this.templatePath('editorconfig'),
        this.destinationPath('editorconfig')
      );
      this.fs.copy(
        this.templatePath('gitattributes'),
        this.destinationPath('gitattributes')
      );
      this.fs.copy(
        this.templatePath('gitignore'),
        this.destinationPath('gitignore')
      );
      this.fs.copy(
        this.templatePath('Gruntfile.js'),
        this.destinationPath('Gruntfile.js')
      );
      this.fs.copy(
        this.templatePath('jshintrc'),
        this.destinationPath('jshintrc')
      );
      this.fs.copy(
        this.templatePath('main.css'),
        this.destinationPath('src/css/main.css')
      );
      this.fs.copy(
        this.templatePath('main.js'),
        this.destinationPath('src/js/main.js')
      );
    },

    projectfiles: function () {
      this.fs.copy(
        this.templatePath('editorconfig'),
        this.destinationPath('.editorconfig')
      );
      this.fs.copy(
        this.templatePath('jshintrc'),
        this.destinationPath('.jshintrc')
      );
    }
  },

  install: function () {
    this.installDependencies();
  }
});
