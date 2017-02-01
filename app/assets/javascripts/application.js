// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require jquery
//= require materialize-sprockets
$(document).ready(function(){
  formLoad()
  buttonLoad()
  pagination()
  mouseOvers()
  productHover()
  exitBanner()
  fadeOutBanner()
})

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

function exitBanner(){
  $('.exit-banner').click(function(){
    $('.banner').fadeOut('slow')
  })
}

function fadeOutBanner(){
  if($('.banner')){
    setTimeout(function(){
      $('.banner').fadeOut('slow')
    }, 10000)
  }
}

function productHover(){
  $('.product').mouseover(function(){
    var variants = $(this).find('.variant-images')
    if(variants){
      variants.css({display: 'inherit'})
    }
  })
  $('.product').mouseleave(function(){
    var variants = $(this).find('.variant-images')
    if(variants){
      variants.css({display: 'none'})
    }
  })
  $('.sub-var-image').mouseover(function(){
    console.log("sub var hover");
    var main = $(this).parent().parent().parent().parent().find('.main-prod-image')
    var thisSrc = $(this).attr('src')
    $(this).attr('src', main.attr('src'))
    main.attr('src', thisSrc)
  })
}

function slideOut(div){
  var windowWidth = $(window).width()
  div.animate({
    marginLeft: windowWidth + 100
  })
  setTimeout(function(){
    div.remove()
  }, 750)
}

  function mouseOvers(){
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
  }

function pagination(){
  if($('.pagination').length){
    $(window).scroll(function(){
      var url = $('.pagination .next_page').attr('href')
      if(url && $(window).scrollTop() > $(document).height() - $(window).height() - 10) {
        $('.pagination').text("Loading...")
        $.getScript(url)
      }
    })
  }
}

function replaceWithGif(something) {
  var gif = $('<img class="responsive=img loading-gif" src="/images/loading.gif"/>')
  something.replaceWith(gif)
}

function formLoad(){
  $('form').submit(function(){
    var form = $(this);
    var submitButton = form.find('.submit-button');
    if(submitButton){
      var submitBtn = form.find('.submit-button');
      var width = submitBtn.width();
      submitBtn.val('');
      submitBtn.prop('disabled', true);
      submitBtn.addClass('submitted-button');
      submitBtn.width(width);
    }
  })
}

function buttonLoad(){
  $('.button-load').click(function(){
    var width = $(this).width()
    $(this).text('')
    $(this).prop('disabled', true)
    $(this).addClass('submitted-button')
    $(this).width(width)
  })
}
