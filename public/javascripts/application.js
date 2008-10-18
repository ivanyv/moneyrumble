$(document).ready(function() {
  resizeLayout();

  $('#btn_new_account').boxy({ title: 'New account',
                               modal: true,
                               closeText: ' [ cancel ] ' });
  
  $('#btn_new_account').click(function() {
    //b = Boxy.get($('#dlg_new_account'));
    $('#dlg_new_account #account_name').focus();
  })
  
  $('#dlg_new_account form').ajaxComplete(function(e, xhr, settings) {
    if (settings.url != '/accounts') { return }
    $('#account_list').load('/accounts.js');
    $('#content').load('/accounts/dashboard.js');
    
    b = Boxy.get($('#dlg_new_account'))
    b.hideAndUnload();
    $('#dlg_new_account').load('/accounts/new.js', function() {
      $('#btn_new_account').boxy({ title: 'New account',
                                 modal: true,
                                 closeText: ' [ cancel ] ' });
    });
  })
})

$(window).resize(function() {
  resizeLayout()
})

function resizeLayout() {
  wh = $(window).height();
  th = $('#sections').height();
  ct = $('#container').offset().top;
  $("#content-wrapper").height(wh - ct - th - 22)
}