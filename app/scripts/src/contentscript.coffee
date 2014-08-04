'use strict';

extractTable = () ->
  console.log 'reload works'
  $('table').filter () ->
    summary = 'This table contains a statement of your account'
    $(this).attr('summary') == summary

processPayment = (year) ->
  # returns a function that can convert a payment
  # from an array of values to an object with named
  # fields
  processPaymentDate = (year, paymentDate) ->
    # a sample date format on the statement page would be Jun 13
    # we need to compose it with the year before parsing
    moment(new Date(year + ' ' + paymentDate)).format('YYYY-MM-DD');

  processPaymentAmmount = (incoming, outgoing) ->
    # either of these values can be the empty string
    # using Number to convert as that maps '' to 0
    Number(incoming) - Number(outgoing)

  processBalance = (ammount, isPositive = true) ->
    if isPositive then Number(ammount) else (0 - Number(ammount))

  (payment) ->
    {
      date:       processPaymentDate(year, payment[0]),
      type:       payment[1],
      name:       payment[2],
      ammount:    processPaymentAmmount(payment[4], payment[3]),
      balance:    processBalance(payment[5], (payment[6] != 'D'))
    }

extractPayments = (table) ->
  rows = table.find('tbody tr')
  allPayments = [];

  rows.each (idx, row) ->
    paragraphs = $(row).find('td p')
    payment = []
    paragraphs.each (idx, paragraph) ->
      payment.push($(paragraph).text().trim())
    allPayments.push(payment);

  allPayments;

# TODO: payment type in human readable form
# TFR => transfer
# VIS => card payment
# CR => credit (incoming payment)
# ((( => contactless payment

payments = extractPayments(extractTable()).map(processPayment(2013));
chrome.runtime.sendMessage payments
