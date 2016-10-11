//= require Chart.bundle
//= require chartkick


// $(document).ready(function(){
//   console.log('script loadeddd');
//
//   $('.submit-tracker').click(function(){
//     // e.preventDefault()
//     var div = $(this).parent()
//     var form = div.find($('.tracking-form'))
//     var trackingInput = div.find($('.tracking-number'))
//     var trackingNumber = trackingInput.val()
//     var commitId = trackingInput.attr('data')
//     var saleAmount = div.find($('.sale-amount')).text()
//     console.log(saleAmount + ', ' + trackingNumber + ', ' + commitId);
//     createTracking(commitId, trackingNumber, form, saleAmount, div)
//     $(this).replaceWith($("<h6 class='button-replacement'>").text("Enter Tracking Number"))
//   })
// })
//
// function createTracking(commitId, trackingNumber, form, saleAmount, div) {
//   console.log(commitId);
//   console.log(trackingNumber);
//   $.ajax({
//     method: 'POST',
//     url: '/api/create_tracking_and_charge?commit_id=' + commitId + '&tracking_number=' + trackingNumber,
//     success: function(data){
//       var shippedText = $('<h4>').text('Item has been shipped!')
//       form.replaceWith(shippedText)
//       div.find($('.button-replacement')).remove()
//       Materialize.toast(saleAmount, 4000)
//     }
//   })
// }

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
})

var orderUuids = [];
var addressIds = []
var addressId = null;

function completeShipment(){
  $('.complete-shipment').click(function(){
    var button = $(this)
    var shipment = button.attr('data-shipment')
    button.prop('disabled', true)
    button.text('Shipping Order...')
    if(orderUuids.length > 0) {
      $.ajax({
        method: 'POST',
        url: '/api/shipping/complete_shipment?shipment='+shipment+'&orders='+orderUuids+'&addresses='+addressIds,
        success: function(data){
          if(data.success){
            $('.add-order-success').text('Order shipped!')
            $('.shipment-orders').remove()
            $('.complete-shipment').remove()
            $('.available-orders').remove()
            $('.completion-button-div').append($('<a href="/needs_shipping" class="btn">').text('New Shipment'))
          } else {
            $('.add-order-error').text(data.message)
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
    if(orderUuids.length == 0) {
      addressId = null
    }
    if(addressId == div.attr('data-address') || addressId == null) {
      $('.add-order-error-div').fadeOut()
      addOrderClick(div)
    } else {
      $('.add-order-error-div').fadeIn()
    }
  })
}

function exitErrorDiv(){
  $('.exit-error-div').click(function(){
    $('.add-order-error-div').fadeOut()
  })
}

function addOrderClick(div){
  div.attr('class', 'border remove-order pointer')
  var commitUuid = div.attr('data-uuid')
  var retailerId = div.attr('data-retailer')
  var address = div.attr('data-address')
  var orderDiv = div.parent().clone()
  div.parent().remove()
  $('.shipment-orders').append(orderDiv)
  orderUuids.push(commitUuid)
  addressIds.push(address)
  if(orderUuids.length == 1){
    $('.complete-shipment').attr('class', 'btn complete-shipment')
    addressId = address
    $('.remove-hint').attr('class', 'remove-hint')
  }
}

function removeOrder(){
  $('body').on('click', '.remove-order', function(){
    $(this).attr('class', 'border add-order-to-shipment')
    var commitUuid = $(this).attr('data-commit')
    var addressId = $(this).attr('data-address')
    var orderDiv = $(this).parent().clone()
    $(this).parent().remove()
    $('.available-orders').append(orderDiv)
    orderUuids.pop(commitUuid)
    addressIds.pop(addressId)
    if(orderUuids.length < 1) {
      addressId = null
      $('.complete-shipment').attr('class', 'btn complete-shipment hidden')
      $('.remove-hint').attr('class', 'remove-hint hidden')
    }
  })
}
