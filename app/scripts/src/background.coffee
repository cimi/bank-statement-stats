'use strict';

chrome.runtime.onInstalled.addListener (details) ->
    console.log('previousVersion', details.previousVersion)

chrome.tabs.onUpdated.addListener (tabId) ->
    chrome.pageAction.show(tabId)

chrome.runtime.onMessage.addListener (request, sender) ->
  payments = new Payments request.map (payment) -> new Payment payment
  savedPayments = 0;
  payments.store().then (results) ->
    savedPayments = results.length
    Payments.getCount()
  .then (count) ->
    options = {
      type: "basic",
      title: "Payments extracted successfully",
      message: savedPayments + " payments saved, " + count + " payments total.",
      iconUrl: "images/icon-38.png"
    }
    console.log options.message
    chrome.notifications.create("saved", options, () -> console.log("works"));

