//= require Chart.bundle
//= require chartkick
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
  setInitialShipment()
  addOrder()
  removeOrder()
  completeShipment()
  exitErrorDiv()
  deleteSku()
})

var orders = [];

function completeShipment(){
  $('.complete-shipment').click(function(){
    var button = $(this)
    var shipment = button.attr('data-shipment')
    button.prop('disabled', true)
    button.text('Shipping Order...')
    console.log(JSON.stringify(orders));
    if(orders.length > 0) {
      $.ajax({
        method: 'POST',
        url: '/api/shipping/complete_shipment?shipment='+shipment+'&orders='+JSON.stringify(orders),
        success: function(data){
          if(data.success){
            $('.add-order-success').text('Order shipped!')
            $('.shipment-orders').remove()
            $('.complete-shipment').remove()
            $('.available-orders').remove()
            $('.completion-button-div').append($('<a href="/needs_shipping" class="btn">').text('New Shipment'))
          } else {
            $('.error').text(data.message)
            button.prop('disabled', false)
            button.text('Complete Shipment')
          }
        }
      })
    }
  })
}

function setInitialShipment(){
  $('.set-initial-shipment').submit(function(e){
    e.preventDefault()
    var form = $(this)
    form.find('.submit').prop('disabled', true)
    var trackingCode = form.find('.tracking-number').val()
    var shippingAmount = form.find('.shipping-cost').val()
    $.ajax({
      method: 'POST',
      url: '/api/shipping/create_initial_shipment?tracking_code='+trackingCode+'&shipping_amount='+shippingAmount,
      success: function(data){
        if(data.success){
          window.location = '/needs_shipping?shipment=' + data.shipment.id
          form.hide()
        } else {
          form.find('.errors').text(data.error)
          form.find('.submit').prop('disabled', false)
        }
      }
    })
  })
}

function addOrder() {
  $('body').on('click', '.add-order-to-shipment', function(){
    var div = $(this)
    for (var i = 0; i < orders.length; i++) {
      var order = orders[i]
      if(order.addressId != div.attr('data-address')){
        return $('.add-order-error-div').fadeIn()
      }
    }
    $('.add-order-error-div').fadeOut()
    addOrderClick(div)
  })
}

function exitErrorDiv(){
  $('.exit-error-div').click(function(){
    $('.add-order-error-div').fadeOut()
  })
}

function addOrderClick(div){
  div.attr('class', 'border remove-order pointer')
  var poId = div.attr('data-po')
  var addressId = div.attr('data-address')
  var orderDiv = div.parent().clone()
  div.parent().remove()
  var order = {}
  order.poId = poId
  order.addressId = addressId
  orders.push(order)
  $('.shipment-orders').append(orderDiv)
  console.log(orders.length);
  if(orders.length == 1){
    $('.complete-shipment').attr('class', 'btn complete-shipment')
    $('.remove-hint').attr('class', 'remove-hint')
  }
}

function removeOrder(){
  $('body').on('click', '.remove-order', function(){
    $(this).attr('class', 'border add-order-to-shipment')
    var poId = $(this).attr('data-po')
    var addressId = $(this).attr('data-address')
    var orderDiv = $(this).parent().clone()
    $(this).parent().remove()
    $('.available-orders').append(orderDiv)
    for (var i = 0; i < orders.length; i++) {
      var order = orders[i]
      if(order.poId == poId){
        orders.pop(order)
      }
    }
    console.log(orders.length);
    if(orders.length < 1) {
      $('.complete-shipment').attr('class', 'btn complete-shipment hidden')
      $('.remove-hint').attr('class', 'remove-hint hidden')
    }
  })
}

function deleteSku(){
  $('.remove-sku').click(function(){
    var sku = $(this).attr('data-sku')
    $.ajax({
      method: 'POST',
      url: '/api/products/remove_sku?sku='+sku,
      success: function(data){
        if(data.success){
          location.reload()
        }
      }
    })
  })
}
