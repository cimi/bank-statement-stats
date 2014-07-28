'use strict'
console.log "Works!"

$(document).ready () ->
  localforage.getItem "payments", (payments) ->
    console.log payments
    $('#payments').dataTable {
        "data": payments,
        "columns": [
            { "title": "Date", "data": "date" },
            { "title": "Name", "data": "name" },
            { "title": "Payed", "class": "center", "data": "ammount", "type": "numeric" },
            { "title": "Balance", "class": "center", "data": "balance" }
        ]
    }

