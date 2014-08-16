var app = angular.module("bankStatementsStats", []);

app.factory("PaymentsRetrieve", ["$window", function($window){

    return $window.Payments;

}]);

app.controller("StatsController", ['$scope', "PaymentsRetrieve", function ($scope, Payments) {
	
    $scope.headers = ["Name", "Ammount", "Date", "Balance", "Category", "Tags"];

    Payments.load().then( function(newPayments) {
        $scope.$apply(function () {
            $scope.paymentsList = newPayments.paymentList;    
            //$scope.paymentsList[0].prototype.tags = "";
        });     
    });

    this.saveInfo = function() {
        var p = new Payments($scope.paymentsList);
        p.storeAll().then( function(payments){
        });
    }    
}]);