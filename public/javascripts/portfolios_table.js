var sortSparlines = function(a, b, desc) {
  var comp = YAHOO.util.Sort.compare;
  return comp(a.getData('count'), b.getData('count'), desc);
};

YAHOO.util.Event.addListener(window, "load", function() {
  YAHOO.example.EnhanceFromMarkup = new function() {
    var myColumnDefs = [
      {key:"portfolio",  label:"Portfolio",  sortable:true},
      {key:"count",  label:"Questions count*", formatter:"number", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC} }
    ];
    this.myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("portfolio-table"));
    this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
    this.myDataSource.responseSchema = {
      fields: [{key:"portfolio"},
              {key:"count", parser:YAHOO.util.DataSource.parseNumber}
      ]
    };
    this.myDataTable = new YAHOO.widget.DataTable("portfolios", myColumnDefs, this.myDataSource,
      {sortedBy:{key:"portfolio",dir:"desc"}}
    );
  };
});
