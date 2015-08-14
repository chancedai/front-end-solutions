var page = require('webpage').create();
page.open('http://sina.com.cn', function() {
  page.render('example.png');
  phantom.exit();
});