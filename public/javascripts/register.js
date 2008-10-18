$(document).ready(function() {
  $('#register').jqGrid({
    url: grid_url,
    datatype: 'xml',
    mtype: 'GET',
    colNames:['amount','date', 'num','notes'],
    colModel :[
      {name:'amount', index:'amount', width:55},
      {name:'date', index:'date', width:90},
      {name:'number', index:'number', width:80, align:'right'},
      {name:'notes', index:'notes', width:150, sortable:false} ],
    sortname: 'date',
    sortorder: "desc",
    viewrecords: true,
    imgpath: '/images/grid',
    gridComplete: resizeGrid
  });
  
  $(window).resize(function() {
    resizeGrid()
  })
})

function resizeGrid() {
  $('#register').setGridWidth($('#account-register').width());
  $('#register').setGridHeight($('#content-wrapper').height() - 120);
}