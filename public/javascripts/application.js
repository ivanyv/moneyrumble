$(document).ready(function() {
  resizeLayout();

  $('#btn_new_account').boxy({ title: 'New account',
                               modal: true,
                               closeText: ' [ cancel ] ' });
  
  $('#btn_new_account').click(function() {
    //b = Boxy.get($('#dlg_new_account'));
    $('#dlg_new_account #account_name').focus();
  })
  
  attachAjaxHandler();

  $('.rounded').corners('6px');
})

$(window).resize(function() {
  resizeLayout()
})

function attachAjaxHandler() {
  $('#dlg_new_account form').ajaxComplete(function(e, xhr, settings) {
    onNewAccountSubmit(e, xhr, settings);
  })
}

function onNewAccountSubmit(e, xhr, settings) {
  if (settings.url == '/accounts') {
    $('#account_list').load('/accounts.js');
    $('#content').load('/accounts/dashboard.js');
    
    b = Boxy.get($('#dlg_new_account'))
    b.hideAndUnload();

    reloadDlgNewAccount();
  }
  if (settings.url == '/accounts/new.js') {
    
  }
  if (settings.url == '/accounts.js') {
    $('.rounded').corners('6px');
  }
}

function resizeLayout() {
  wh = $(window).height();
  th = $('#sections').height();
  ct = $('#container').offset().top;
  $("#content-wrapper").height(wh - ct - th - 22)
}

function reloadDlgNewAccount() {
  $('#dlg_new_account').load('/accounts/new.js', function() {
    $('#btn_new_account').boxy({ title: 'New account',
                               modal: true,
                               closeText: ' [ cancel ] ' })
  })
}