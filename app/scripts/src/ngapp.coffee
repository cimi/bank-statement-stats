app = angular.module 'bankStatementsStats', ["xeditable"]
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
  @
]
