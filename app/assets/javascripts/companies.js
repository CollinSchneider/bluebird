$(document).ready(function(){
  messageCompany()
})

function messageCompany(){
  $('.contact-company').submit(function(e){
    e.preventDefault()
    var form = $(this)
    var message = form.find('.message').val()
    var submitButton = form.find('.btn')
    var company = form.attr('data-company')
    var url = window.location.pathname
    submitButton.prop('disabled', true)
    $.ajax({
      method: 'POST',
      url: url+'?message='+message+'&company='+company,
      success: function(){
        form.parent().append($('<h5>').text('Message sent!'))
        form.hide()
      }
    })
  })
}
