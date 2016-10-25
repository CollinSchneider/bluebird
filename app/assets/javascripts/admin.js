$(document).ready(function(){
  approveUser()
})

function approveUser(){
  $('.approve-user').click(function(){
    var id = $(this).attr('data')
    var user = $(this).attr('data-user')
    var div = $(this).parent()
    $.ajax({
      method: 'POST',
      url: '/api/admin/approve?id='+id+'&user='+user,
      success: function(data){
        if(data.success){
          $('.success').text(data.message)
          div.fadeOut()
        }
      }
    })
  })
}
