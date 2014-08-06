var app = angular.module("bankStatementsStats", []);

app.controller("StatsController", function($scope){
	this.payments = [
		{ammount: -71.18,
        balance: 0,
        date: "2013-04-30",
        name: "RYANAIR     224000",
        type: "VIS",
    	category: "",
    	tags:""},

        {ammount: -71.18,
        balance: 0,
        date: "2013-04-30",
        name: "Laa",
        type: "VIS",
    	category: "",
    	tags:""}
	];

	this.headers = ["Name", "Ammount", "Date", "Balance", "Category", "Tags"];

});

app.directive("contenteditable", function(){
	return{
		restrict: 'A',
		require: 'ngModel',
		link: function(scope, element, attrs, ngModel){
			    // view -> model
                element.bind('blur', function() {
                    scope.$apply(function() {
                        ngModel.$setViewValue(element.html());
                    });
                });

                // model -> view
                ngModel.$render = function() {
                    element.html(ngModel.$viewValue);
                };

                // load init value from DOM
                ngModel.$setViewValue(element.html());
		}
	};


});