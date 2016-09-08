
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
