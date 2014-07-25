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

function processPayment(year) {
  // returns a function that can convert a payment
  // from an array of values to an object with named
  // fields
  var processPaymentDate = function (year, paymentDate) {
    // a sample date format on the statement page would be Jun 13
    // we need to compose it with the year before parsing
    return moment(new Date(year + ' ' + paymentDate)).format('YYYY-MM-DD');
  };

  return function (payment) {
    return {
      date:       processPaymentDate(year, payment[0]),
      type:       payment[1],
      name:       payment[2],
      outgoing:   payment[3],
      incoming:   payment[4],
      balance:    payment[5],
      debt:       (payment[6] === 'D' ? true : false)
    };
  };
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

// TODO: payment type in human readable form
// TFR => transfer
// VIS => card payment
// CR => credit (incoming payment)
// ((( => contactless payment

fs.readdir(dir, function (err, files) {
  files.filter(function (file) {
    // only process files ending in HTML
    return file.substr(file.length - ".html".length) == ".html"
  }).forEach(function (file) {
    var filePath = dir + '/' + file
      , outputDir = './app/data'
      , table = extractTable(fs.readFileSync(filePath).toString())
      , year = file.split('-')[0];

    var payments = extractPayments(table).map(processPayment(year));

    fs.writeFileSync(outputDir + '/' + file,
      JSON.stringify(payments, null, '  '));
  });
});
