'use strict'


createTableFrom = (data) ->
  console.log data
  $('#payments').dataTable {
    "data": data,
    "columns": [
        { "title": "Date", "data": "date" },
        { "title": "Name", "data": "name" },
        { "title": "Payed", "class": "center", "data": "ammount", "type": "numeric" },
        { "title": "Balance", "class": "center", "data": "balance" }
    ]
  }

displayTableFromLocalFile = () ->
  url = chrome.extension.getURL 'scripts/sample.json'
  $.getJSON(url, (payments) -> createTableFrom payments)

$(document).ready () ->
  localforage.getItem "payments", (payments) ->
    if payments == null or payments.length == 0
      displayTableFromLocalFile()
    else
      createTableFrom payments
