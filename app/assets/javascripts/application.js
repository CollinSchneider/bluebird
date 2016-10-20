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
})

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
        // replaceWithGif($('.pagination').text())
        $('.pagination').text("Loading...")
        console.log('getting?');
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
    var submitButton = $(this).find('.submit-button')
    if(submitButton){
      var width = submitButton.width()
      submitButton.val('')
      submitButton.prop('disabled', true)
      submitButton.attr('class', 'submitted-button btn')
      submitButton.width(width)
    }
  })
}

function buttonLoad(){
  $('.button-load').click(function(){
    console.log('button click');
    var width = $(this).width()
    $(this).text('')
    $(this).prop('disabled', true)
    $(this).attr('class', 'submitted-button btn')
    $(this).width(width)
  })
}
