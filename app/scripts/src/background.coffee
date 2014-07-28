'use strict';

chrome.runtime.onInstalled.addListener (details) ->
    console.log('previousVersion', details.previousVersion)

chrome.tabs.onUpdated.addListener (tabId) ->
    console.log "Adding page action"
    chrome.pageAction.show(tabId)

console.log('\'Allo \'Allo! Event Page for Page Action')

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  console.log("received " + request)
  sendResponse({farewell: "goodbye"}) if (request.greeting == "hello")
