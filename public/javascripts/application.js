$(document).ready(function() {
  resizeLayout();
  $('#btn_new_account').boxy({ title: 'New account',
                               modal: true,
                               closeText: ' [ cancel ] ' });

  $('#btn_new_account').click(function() {
    b = Boxy.get($('#dlg_new_account'));
    //b.resize(10,10);
    //b.tween(200, 200);
  })
  
  $('#dlg_new_account form').ajaxComplete(function(e, xhr, settings) {
    $('#account_list').load('/accounts.js');
    Boxy.get($('#dlg_new_account')).hide();
  })
})

$(window).resize(function() {
  resizeLayout()
})

function resizeLayout() {
  wh = $(window).height();
  th = $('#sections').height();
  ct = $('#container').offset().top;
  $("#content").height(wh - ct - th - 22)
}