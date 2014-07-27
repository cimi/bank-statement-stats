'use strict';

console.log('\'Allo \'Allo! Popup')

$(document).ready ->
  console.log $('a')
  console.log $('#viewer')
  $('#viewer').click ->
    chrome.tabs.create({url: "index.html"});
  true
