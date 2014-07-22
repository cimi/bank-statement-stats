'use strict';
$(document).ready(function () {
  $.get('data/2013-06.html', function (data) {
    console.log(JSON.parse(data));
  });
});
