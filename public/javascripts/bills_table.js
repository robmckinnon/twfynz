var three_letter_month = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
var myFormatDate = function(cell, record, column, date) {
  cell.innerHTML = date.getDate() + " " + three_letter_month[date.getMonth()] + " " + date.getFullYear();
};

YAHOO.example.compNull = function(a, b, desc, primary, first, first_dir, second, second_dir) {
  if(!YAHOO.lang.isValue(a)) {
    return (!YAHOO.lang.isValue(b)) ? 0 : 1;
  } else if(!YAHOO.lang.isValue(b)) {
    return -1;
  }

  var comp = YAHOO.util.Sort.compare;
  var a_primary = a.getData(primary);
  var b_primary = b.getData(primary);

  if (primary == 'event') {
    a_primary = events_list.indexOf(a_primary);
    b_primary = events_list.indexOf(b_primary);
  }
  var comparison = comp(a_primary, b_primary, desc);

  if (comparison == 0 && first != null) {
    var a_first = a.getData(first);
    var b_first = b.getData(first);
    comparison = comp(a_first, b_first, first_dir);
  }
  if (comparison == 0 && second != null) {
    var a_second = a.getData(second);
    var b_second = b.getData(second);
    comparison = comp(a_second, b_second, second_dir);
  }
  return comparison;
};

var sortPartiesFunction = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'party', 'bill', false, 'type', false);
};

var sortTypesFunction = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'type', 'bill', false, 'party', false);
};

var events_list = ["Introduction","First Reading","Second Reading","Submissions Due","SC Reports","In Committee","Third Reading"]

var sortEventsFunction = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'event', 'bill', false, 'party', false);
};

var sortDatesFunction = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'date', 'bill', false, 'party', false);
}

YAHOO.util.Event.addListener(window, "load", function() {
  YAHOO.example.EnhanceFromMarkup = new function() {
    var myColumnDefs = [
      {key:"type",  label:"Type",  sortable:true, sortOptions:{sortFunction:sortTypesFunction} },
      {key:"party", label:"Party", sortable:true, sortOptions:{sortFunction:sortPartiesFunction} },
      {key:"bill",  label:"Bill",  sortable:true },
      {key:"event", label:"Event", sortable:true, sortOptions:{sortFunction:sortEventsFunction} },
      {key:"date",  label:"Event date", formatter: myFormatDate, sortable:true, sortOptions:{sortFunction:sortDatesFunction, defaultDir:YAHOO.widget.DataTable.CLASS_DESC} }
    ];
    this.myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("bill-table"));
    this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
    this.myDataSource.responseSchema = {
      fields: [{key:"type"},
              {key:"party"},
              {key:"bill"},
              {key:"event"},
              {key:"date", parser:YAHOO.util.DataSource.parseDate}
      ]
    };
    this.myDataTable = new YAHOO.widget.DataTable("bills", myColumnDefs, this.myDataSource,
      {sortedBy:{key:"bill",dir:"desc"}}
    );
  };
});
