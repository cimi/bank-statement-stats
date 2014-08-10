'use strict';

localforage.clear().then () ->
  $('h1').text('Deleted everything')
