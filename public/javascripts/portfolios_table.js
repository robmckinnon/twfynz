YAHOO.example.enhanceFromMarkup = function() {
    this.columnHeaders = [
        {key:"portfolio", text:"Sort portfolio<br /> name", sortable:true},
        {key:"sparkline", text:"Oral Question<br /> monthly activity<br /> since Nov 2005", sortable:false},
        {key:"count", type:"number", text:"Oral Questions<br /> asked since<br /> Nov 2005", sortable:true},
    ];
    this.columnSet = new YAHOO.widget.ColumnSet(this.columnHeaders);

    var portfolios = YAHOO.util.Dom.get("portfolios");
    this.dataTable = new YAHOO.widget.DataTable(portfolios,this.columnSet,null,{_sName:"portfolio-table"});
};

YAHOO.util.Event.onAvailable("portfolios",YAHOO.example.enhanceFromMarkup,YAHOO.example.enhanceFromMarkup,true);
