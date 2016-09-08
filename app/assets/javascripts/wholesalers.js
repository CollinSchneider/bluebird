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
