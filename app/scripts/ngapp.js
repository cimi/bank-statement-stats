var app = angular.module("bankStatementsStats", []);

app.factory("PaymentsRetrieve", ["$window", function($window){

    return $window.Payments.load();

}]);

app.controller("StatsController", ['$scope', "PaymentsRetrieve", function ($scope, retrieve) {
	
    $scope.headers = ["Name", "Ammount", "Date", "Balance", "Category", "Tags"];

    
    retrieve.then( function(newPayments) {
        $scope.$apply(function () {
            $scope.payments = newPayments;    
        });     
    });
    
}]);