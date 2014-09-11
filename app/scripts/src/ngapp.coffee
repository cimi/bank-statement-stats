# var app = angular.module('bankStatementsStats', []);

# app.factory('PaymentsRetrieve', ['$window', function($window){

#     return $window.Payments;

# }]);

# app.controller('StatsController', ['$scope', 'PaymentsRetrieve', function ($scope, Payments) {

#     $scope.headers = ['Name', 'Ammount', 'Date', 'Balance', 'Category', 'Tags'];

#     Payments.load().then( function(newPayments) {
#         $scope.$apply(function () {
#             $scope.paymentsList = newPayments.paymentList;

#         });
#     });

#     this.saveInfo = function() {
#         var p = new Payments($scope.paymentsList);
#         p.storeAll().then( function(payments){
#         });
#     }
# }]);

app = angular.module 'bankStatementsStats', []
app.factory 'PaymentsRetrieve', ['$window', ($window) -> $window.Payments]

app.controller 'StatsController', ['$scope', 'PaymentsRetrieve', ($scope, PaymentsRetrieve) ->
  $scope.headers = ['Name', 'Ammount', 'Date', 'Balance', 'Category', 'Tags']

  Payments.load().then (newPayments) ->
    $scope.$apply () ->
      $scope.paymentsList = newPayments.paymentList

  @saveInfo = () ->
    p = new Payments $scope.paymentsList
    p.storeAll().then (payments) ->
      console.log payments
]
