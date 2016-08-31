
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
  $('.sub-nav-triangle').css({
    display: 'none'
  })
})
