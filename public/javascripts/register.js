$(document).ready(function() {
  $('#register').jqGrid({
    url: grid_url,
    datatype: 'xml',
    mtype: 'GET',
    colNames:['Del', 'Num','Date', 'Payee','Payment', 'Deposit', 'Balance', ''],
    colModel :[
      {name:'del', index:'del', width:13, align:'center', sortable:false},
      {name:'number', index:'number', width:30, align:'right', editable:true},
      {name:'date', index:'date', width:40, align:'center', editable:true, sorttype: 'date'},
      {name:'payee', index:'payee', width:90, align:'left'},
      {name:'payment', index:'payment', width:45, align:'right'},
      {name:'deposit', index:'deposit', width:45, align:'right'},
      {name:'balance', index:'balance', width:45, sortable: false, align:'right'},
      {name:'dummy', index:'dummy', width:2, sortable: false } ],
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
    },
    loadComplete: function() {
      var grid = $("#register");
      var ids = grid.getDataIDs();
      for (var i = 0; i < ids.length; i++) {
        var cl = ids[i];
        de = "<a title='Delete' href='#' onclick=\"$.post('" + cell_edit_url + "', {id:" + cl + ", destroy: true}, function(data){ reloadGridAndAccounts(); }, 'text');\"><img src='/images/delete.png' /></a>";
        grid.setRowData(ids[i], {del: de});
      }
      negs = $('.negative');
      for (var i = 0; i < negs.length; i++) {
        $(negs[i]).removeClass('negative');
        $(negs[i]).addClass('negative');
      }
    },
    subGrid: true,
    subGridUrl : grid_detail_url,
    subGridModel :[
      { name : [ 'Notes' ],
        width : [ '100%' ],
        params : [ 'date' ]}
    ]
  });
  
  $(window).resize(function() {
    resizeGrid()
  })

  $('#new-transaction > ul').tabs();
  
  $('#new-transaction form').ajaxComplete(function(e, xhr, settings) {
    skip = settings.url != '/accounts/' + current_account + '/transactions' &&
           settings.url != '/accounts/' + current_account + '/transactions/update_attr' &&
           settings.url != '/accounts/' + current_account + '/deposits' &&
           settings.url != '/accounts/' + current_account + '/deposits/update_attr' &&
           settings.url != '/accounts/' + current_account + '/payments' &&
           settings.url != '/accounts/' + current_account + '/payments/update_attr'
    if (skip) { return }
    reloadGridAndAccounts();
  })
})

function resizeGrid() {
  $('#register').setGridWidth($('#account-register').width());
  $('#register').setGridHeight($('#content-wrapper').height() - 272);
}

function reloadGridAndAccounts() {
  $('#register').trigger('reloadGrid');
  $('#account_list').load('/accounts.js');
}