'use strict';
var $ = require('cheerio')
  , fs = require('fs');

var dir = './statements';

function extractTable(content) {
  var parsedHTML = $.load(content);
  return parsedHTML('table').filter(function () {
    var summary = 'This table contains a statement of your account';
    return $(this).attr('summary') === summary;
  });
}

function extractPayments(table) {
  var rows = table.find('tbody tr')
    , allPayments = [];
  rows.each(function (idx, row) {
    var paragraphs = $(row).find('td p')
      , payment = [];
    paragraphs.each(function (idx, paragraph) {
      payment.push($(paragraph).text().trim());
    });
    allPayments.push(payment);
  });
  return allPayments;
}

fs.readdir(dir, function (err, files) {
  if (err) throw err;
  files.forEach(function (file) {
    var filePath = dir + '/' + file
      , outputDir = './app/data'
      , table = extractTable(fs.readFileSync(filePath).toString());
      fs.writeFileSync(outputDir + '/' + file,
        JSON.stringify(extractPayments(table), null, "  "));
  });
});
