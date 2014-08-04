var app = angular.module("bankStatementsStats", []);

app.controller("StatsController", function($scope){
	this.payments = [
		{ammount: -71.18,
        balance: 0,
        date: "2013-04-30",
        name: "RYANAIR     224000",
        type: "VIS"},
        {ammount: -71.18,
        balance: 0,
        date: "2013-04-30",
        name: "Laa",
        type: "VIS"}
	];

});