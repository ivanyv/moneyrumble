$(document).ready(function() {
  $('#register').jqGrid({
    url: grid_url,
    datatype: 'xml',
    mtype: 'GET',
    colNames:['Num','Date', 'Payee','Payment', 'Deposit', 'Balance', ''],
    colModel :[
      {name:'number', index:'number', width:30, align:'right', editable:true},
      {name:'date', index:'date', width:40, align:'center', editable:true},
      {name:'payee', index:'payee', width:90, align:'left'},
      {name:'payment', index:'payment', width:45, align:'right'},
      {name:'deposit', index:'deposit', width:45, align:'right'},
      {name:'balance', index:'balance', width:45, sortable: false, align:'right'},
      {name:'dummy', index:'dummy', width:8, sortable: false, align:'right'} ],
    cellEdit: true,
    cellurl: cell_edit_url,
    sortname: 'date',
    sortorder: "asc",
    viewrecords: true,
    imgpath: '/images/grid',
    gridComplete: resizeGrid,
    afterSaveCell: function(id, name, val, iRow, iCol) {
      if (name == $('#register').getGridParam('sortname')) {
        $('#register').trigger('reloadGrid');
      }
    }
  });
  
  $(window).resize(function() {
    resizeGrid()
  })

  $('#new-transaction > ul').tabs();
  
  $('#new-transaction form').ajaxComplete(function(e, xhr, settings) {
    if (settings.url != '/accounts/' + current_account + '/transactions') { return }
    $('#register').trigger('reloadGrid');
    $('#account_list').load('/accounts.js');
  })
})

function resizeGrid() {
  $('#register').setGridWidth($('#account-register').width());
  $('#register').setGridHeight($('#content-wrapper').height() - 262);
}