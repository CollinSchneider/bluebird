
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
  $('.make-purchase-order').submit(function(e){
    e.preventDefault()
    makePurchaseOrder($(this))
  })
})

function makePurchaseOrder(form){
  var purchaseOrders = []
  var product = form.attr('data-product')
  form.find('.submit').prop('disabled', true)
  form.find('.submit').val('Ordering..')
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
        $('.message').text(msg)
        $('html, body').animate({
          scrollTop: 0
        }, 700)
        location.reload()
      } else {
        form.find('.submit').prop('disabled', false)
        form.find('.submit').val('Make Order')
        for (var i = 0; i < data.errors.length; i++) {
          var err = data.errors[i]
          var msg = $('<h6 class="red-text">').text(err)
          form.find('.errors').append(msg)
        }
      }
    }
  })
}
