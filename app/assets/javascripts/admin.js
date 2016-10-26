$(document).ready(function(){
  approveUser()
})

function approveUser(){
  $('.approve-user').click(function(){
    var user = $(this).attr('data-uuid')
    var div = $(this).parent()
    $.ajax({
      method: 'POST',
      url: '/api/admin/approve?uuid='+user,
      success: function(data){
        if(data.success){
          $('.success').text(data.message)
          div.fadeOut()
        }
      }
    })
  })
}
