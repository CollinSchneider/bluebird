$(document).ready(function(){
  console.log('ready');
  
  $('a[href="/discover"]').mouseover(function(){
    $('.discover-sub-nav').css({
      display: 'inherit'
    })
  })

  $('.body-div').mouseover(function(){
    console.log('body....');
    $('.sub-nav-container').css({
      display: 'none'
    })
  })
  sendToStripe();

  $('.make-puchase-order').click(function(){
    console.log('click');
    var productBox = $(this).find('.product-box');
    // var items = productBox.find('.item-purchase-orders')
    var items = $(productBox , ' .item-purchase-orders');
    console.log(items);

    // $('.item-purchase-orders').each(function(order){
      // console.log($(this).val())
    // })
  })
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
