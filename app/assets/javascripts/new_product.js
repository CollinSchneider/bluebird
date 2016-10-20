
$(document).ready(function(){
  sizeSubmit()
  removeSize()
  removeVariant()
})

function sizeSubmit(){
  $('.create-size').submit(function(e){
    e.preventDefault()
    var form = $(this)
    var productUuid = form.attr('data-product')
    var size = form.find('.new-size').val()
    form.find('.submit').prop('disabled', true)
    form.find('.submit').text('Saving')
    form.find('.errors').text('')
    $.ajax({
      method: 'POST',
      url: '/api/products/create_size?size='+size+'&product='+productUuid,
      success: function(data){
        form.find('.submit').prop('disabled', false)
        form.find('.submit').text('Add Size')
        if(data.success){
          var newSize = $('<h6 class="existing-size" data-size='+data.size.id+'>').text(data.size.description)
          var removeButton = $.parseHTML('&nbsp&nbsp&nbsp&nbsp<span class="remove-size pointer" data-size='+data.size.id+'>X</span>')
          newSize.append(removeButton)
          $('.sizes').append(newSize)
          form.find('.new-size').val('')
          $('.not-applicable').hide()
          $('.next-step').show()
        } else {
          form.find('.errors').text(data.message)
        }
      }
    })
  })
}

function removeSize() {
  $('body').on('click', '.remove-size', function(){
    var size = $(this).attr('data-size')
    $.ajax({
      method: 'POST',
      url: '/api/products/remove_size?size='+size,
      success: function(data){
        if(data.success){
          $('.existing-size[data-size='+data.size.id+']').remove();
          if(data.total_sizes == 0){
            $('.not-applicable').show()
            $('.next-step').hide()
          }
        }
      }
    })
  })
}

function removeVariant() {
  $('.remove-variant').click(function(){
    var button = $(this)
    var variant = button.attr('data-variant')
    var div = button.parent().parent()
    $.ajax({
      method: 'POST',
      url: '/api/products/remove_variant?variant='+variant,
      success: function(data){
        if(data.success){
          div.remove()
        } else {
          div.find('.error').text(data.message)
        }
      }
    })
  })
}
