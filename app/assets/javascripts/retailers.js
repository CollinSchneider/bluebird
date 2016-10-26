
$('a[href="/discover"]').mouseover(function(){
  $('.discover-sub-nav').css({
    display: 'inherit'
  })
})

$('.body-div').mouseover(function(){
  $(this).css({
    marginTop: 0
  })
  $('.sub-nav-container').css({
    display: 'none'
  })
  $('.sub-nav-triangle').css({
    display: 'none'
  })
})

$(document).ready(function(){
  addShippingAddress()
  addCreditCard()
  changePayment()
  changeShippingAddress()
  deleteShippingAddress()
  $('.make-primary-address').click(function(button){
    makePrimaryAddress(button)
  })
  $('.make-purchase-order').submit(function(e){
    e.preventDefault()
    makePurchaseOrder($(this))
  })
})

function makePurchaseOrder(form){
  var purchaseOrders = []
  var product = form.attr('data-product')
  var submitText = form.find('.submit').val()
  form.find('.submit').prop('disabled', true)
  form.find('.submit').val('Ordering..')
  form.find('.errors').text('')
  var url = form.attr('data-full-price') == null ? '/api/orders/make_purchase_order' : '/api/orders/full_price_commit'
  form.find('.purchase-order-amount').each(function(i, input){
    if($(this).val() != "") {
      var purchaseOrder = {}
      purchaseOrder.quantity = $(this).val()
      purchaseOrder.sku = $(this).attr('data-sku')
      purchaseOrders.push(purchaseOrder)
    }
  })
  $.ajax({
    method: 'POST',
    url: url+'?orders='+JSON.stringify(purchaseOrders)+'&product='+product,
    success: function(data){
      if(data.success == true){
        // $('.message').text(msg)
        $('html, body').animate({
          scrollTop: 0
        }, 700)
        location.reload()
      } else {
        form.find('.submit').prop('disabled', false)
        form.find('.submit').val(submitText)
        var msg = $('<h5 class="red-text">').text(data.message)
        form.find('.errors').append(msg)
        var offset = $('.make-purchase-order').offset().top
        console.log(offset);
        $('html, body').animate({
          scrollTop: offset
        })
      }
    }
  })
}

var submittedForm;

function addCreditCard(){
  $('.credit-card-form').submit(function(e){
    e.preventDefault()
    submittedForm = $(this)
    var cardName = submittedForm.find($('#card-name')).val();
    var cardNumber = submittedForm.find($('#card-number')).val();
    var cardCvc = submittedForm.find($('#card-cvc')).val();
    var expMonth = submittedForm.find($('#exp-month')).val();
    var expYear = submittedForm.find($('#exp-year')).val();
    var billingZip = submittedForm.find($('#billing-zip')).val()
    var submitButton = submittedForm.find($('.submit'))
    submitButton.val('Saving Card...')
    submitButton.prop('disabled', true)
    // console.log(cardName + ', ' + cardNumber);
    Stripe.card.createToken({
      // customer: stripeCustomer,
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
    submittedForm.find('#payment-errors').text(response.error.message)
    submittedForm.find('.submit').prop("disabled", false)
    submittedForm.find('.submit').val('Add Credit Card')
  } else {
    var token = response.id;
    $.ajax({
      method: 'POST',
      url: '/api/payments/create_credit_card?token=' + token,
      success: function(data) {
        if(!data.success) {
          $('#payment-errors').text(data.error)
          submittedForm.find('.submit').prop('disabled', false)
          submittedForm.find('.submit').val('Add Credit Card')
        } else {
          location.reload()
          // changePaymentApiCall(data.card.id)
        }
      }
    })
  }
}

function addShippingAddress(){
  $('.add-shipping-address').submit(function(e){
    e.preventDefault()
    var form = $(this)
    form.find('.errors').text('')
    var street_one = form.find('.street-line-one').val()
    var street_two = form.find('.street-line-two').val()
    var city = form.find('.city').val()
    var state = form.find('.state').val()
    var zip = form.find('.zip').val()
    form.find('.submit-address').prop('disabled', true)
    var params = "?street_one=" + street_one + "&street_two=" + street_two + "&city="
          + city + "&state=" + state + "&zip=" + zip
    $.ajax({
      method: 'POST',
      url: '/api/shipping/create_shipping_address' + params,
      success: function(data){
        console.log(data);
        if(data.success){
          var commitId = form.attr('data-change-shipping')
          if(commitId) {
            changeShippingApiCall(data.local_address.id, commitId)
          } else {
            location.reload()
          }
          // location.reload()
          // changeShippingApiCall(data.local_address.id)
        } else {
          var errorDiv = form.find('.errors')
          for (var i = 0; i < data.errors.length; i++) {
            var e = data.errors[i]
            errorDiv.append($('<h6 class="red-text">').text(e.message))
          }
          $('.submit-address').prop('disabled', false)
        }
      }
    })
  })
}

function changeShippingAddress(){
  $('.change-address').submit(function(e){
    e.preventDefault()
    var shippingId = $(this).find('.address-id').val()
    var commitId = $(this).attr('data-commit')
    changeShippingApiCall(shippingId, commitId)
  })
}

function changeShippingApiCall(shippingId, commitId){
  $.ajax({
    method: 'POST',
    url: '/api/shipping/change_commit_shipping?shipping_id=' +shippingId+ '&commit_id='+commitId,
    success: function(data){
      if(data.success){
        location.reload()
      }
    }
  })
}

function changePayment(){
  $('.change-payment').submit(function(e){
    e.preventDefault()
    var cardId = $(this).find('.card_id').val()
    var commitUuid = $(this).attr('data-commit')
    changePaymentApiCall(cardId, commitUuid)
  })
}

function changePaymentApiCall(cardId, commitUuid){
  $.ajax({
    method: 'POST',
    url: '/api/payments/change_commit_card?card_id=' +cardId+ '&commit_uuid='+commitUuid,
    success: function(data){
      if(data.success){
        location.reload()
      }
    }
  })
}

function makePrimaryAddress(button){
  if(button){
    button.text('Updating...')
  }
  var addressId = $(this).attr('data')
  $.ajax({
    method: 'POST',
    url: '/api/shipping/make_primary_address?address_id=' + addressId,
    success: function(data){
      location.reload()
    }
  })
}

function deleteShippingAddress(){
  $('.delete-address').click(function(){
    var id = $(this).attr('data')
    $(this).text('Updating...')
    $.ajax({
      method: 'POST',
      url: '/api/shipping/delete_address?id=' + id,
      success: function(data){
        console.log(data);
        if(data.success){
          location.reload()
        } else {
          $('.address-errors').append($('<h6>').text('The following purchase orders are currently using this address you are attempting to delete:'))
          for (var i = 0; i < data.html.length; i++) {
            var commit = data.html[i]
            $('.address-errors').append(commit)
          }
        }
      }
    })
  })
}
