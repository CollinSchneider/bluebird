$(document).ready(function(){
  console.log('ready');
  sendToStripe();
})

var productId;
function sendToStripe(){
  $('.create-credit-card').click(function(){
    $(".create-credit-card").prop("disabled", true)
    $(this).text('One Moment')
    productId = $(this).attr("data");
    console.log(productId);
    var cardName = $('#card-name').val();
    var cardNumber = $('#card-number').val();
    var cardCvc = $('#card-cvc').val();
    var expMonth = $('#exp-month').val();
    var expYear = $('#exp-year').val();
    var billingZip = $('#billing-zip').val()
    Stripe.card.createToken({
      name: cardName,
      number: cardNumber,
      cvc: cardCvc,
      exp_month: expMonth,
      exp_year: expYear,
      address_zip: billingZip
    }, stripeResponseHandler);
  })
}

function stripeResponseHandler(status, response){
  if(response.error){
    $('#payment-errors').text(response.error.message)
    $('#create-card').prop("disabled", false)
  } else {
    var token = response.id;
    console.log(response);
    var xhttp = new XMLHttpRequest()
    // xhttp.onreadystatechange = function() {
    //   if (xhttp.readyState == 4 && xhttp.status == 200) {
    //     var json = JSON.parse(xhttp.responseText);
    //   }
    // }
    xhttp.open("GET", "/api/create_credit_card/" + token, true);
    xhttp.send();
    window.location = "products/" + productId
    // location.reload();
  }
}
