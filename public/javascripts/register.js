$(document).ready(function() {
  $('#register').jqGrid({
    url:'/accounts/5/transactions.xml',
    datatype: 'xml',
    mtype: 'GET',
    colNames:['amount','date', 'num','notes'],
    colModel :[
      {name:'amount', index:'amount', width:55},
      {name:'date', index:'date', width:90},
      {name:'number', index:'number', width:80, align:'right'},
      {name:'notes', index:'notes', width:150, sortable:false} ],
    pager: jQuery('#pager'),
    rowNum:10,
    rowList:[10,20,30],
    sortname: 'date',
    sortorder: "desc",
    viewrecords: true,
    imgpath: '/stylesheets/basic/images',
    caption: 'My first grid'
  });
})