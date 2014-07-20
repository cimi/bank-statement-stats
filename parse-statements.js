'use strict';
var $ = require('cheerio')
  , moment = require('moment')
  , fs = require('fs');

var dir = './statements';

function extractTable(content) {
  var parsedHTML = $.load(content);
  return parsedHTML('table').filter(function () {
    var summary = 'This table contains a statement of your account';
    return $(this).attr('summary') === summary;
  });
}
// payment:
//  0 => date
//  1 => type
//  2 => name
//  3 => outgoing amount
//  4 => incoming amount
//  5 => balance
//  6 => debit?

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

// TODO: payment type in human readable form
// TFR => transfer
// VIS => card payment
// CR => credit (incoming payment)
// ((( => contactless payment

function processPaymentDate(year) {
  return function (payment) {
    payment[0] = moment(new Date(year + ' ' + payment[0])).format('YYYY-MM-DD');
    return payment;
  };
}

fs.readdir(dir, function (err, files) {
  files.forEach(function (file) {
    var filePath = dir + '/' + file
      , outputDir = './app/data'
      , table = extractTable(fs.readFileSync(filePath).toString())
      , year = file.split('-')[0];

    var payments = extractPayments(table).map(processPaymentDate(year));

    fs.writeFileSync(outputDir + '/' + file,
      JSON.stringify(payments, null, '  '));
  });
});
