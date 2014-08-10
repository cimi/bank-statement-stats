'use strict';

console.log('\'Allo \'Allo! Popup')

$(document).ready ->
  $('#viewer').click ->
    chrome.tabs.create({url: "index.html"});
  $('#clear').click ->
    chrome.tabs.create({url: "options.html"});
  true
