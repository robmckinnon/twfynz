// Custom sort functionality to sort by Bills within parties
YAHOO.example.compNull = function(a, b, x, y, comp, m, n, primary, first, second) {
  var a_null = (a === null) || (typeof a == "undefined");
  var b_null = (b === null) || (typeof b == "undefined");
  if (a_null) {
    if (b_null) {
      return 0;
    } else {
      return x;
    }
  } else if (b_null) {
    return y;
  } else {
    var comparison = comp(a[primary], b[primary]);
    if (first != null) {
      comparison = (comparison !== 0) ? comparison : comp(m[first], n[first]);
    }
    if (second != null) {
      comparison = (comparison !== 0) ? comparison : comp(m[second], n[second]);
    }
    return comparison;
  }
};

YAHOO.example.sortPartiesAsc = function(a, b) {
  return YAHOO.example.compNull(a, b, 1, -1, YAHOO.util.Sort.compareAsc, a, b, 'party', 'type', 'bill');
};
YAHOO.example.sortPartiesDesc = function(a, b) {
  return YAHOO.example.compNull(a, b, -1, 1, YAHOO.util.Sort.compareDesc, b, a, 'party', 'type', 'bill');
};

YAHOO.example.sortTypesAsc = function(a, b) {
  return YAHOO.example.compNull(a, b, 1, -1, YAHOO.util.Sort.compareAsc, a, b, 'type', 'party', 'bill');
};
YAHOO.example.sortTypesDesc = function(a, b) {
  return YAHOO.example.compNull(a, b, -1, 1, YAHOO.util.Sort.compareDesc, b, a, 'type', 'party', 'bill');
};

YAHOO.example.sortDatesAsc = function(a, b) {
  return YAHOO.util.Sort.compareAsc(a.date, b.date);
};
YAHOO.example.sortDatesDesc = function(a, b) {
  return YAHOO.util.Sort.compareDesc(a.date, b.date);
};

YAHOO.example.enhanceFromMarkup = function() {
    this.columnHeaders = [
        {key:"type", text:"Bill type", sortable:true, sortOptions:{ascFunction:YAHOO.example.sortTypesAsc,descFunction:YAHOO.example.sortTypesDesc}},
        {key:"party", text:"Party of MP in charge", sortable:true, _id:"party_of_mp_in_charge", sortOptions:{ascFunction:YAHOO.example.sortPartiesAsc,descFunction:YAHOO.example.sortPartiesDesc}},
        {key:"bill", text:"Bill name", sortable:true},
        {key:"event", text:"Event", sortable:true},
        {key:"date", type:"date", text:"Event date", sortable:true, sortOptions:{ascFunction:YAHOO.example.sortDatesDesc,descFunction:YAHOO.example.sortDatesAsc}}
    ];
    this.columnSet = new YAHOO.widget.ColumnSet(this.columnHeaders);

    var bills = YAHOO.util.Dom.get("bills");
    this.dataTable = new YAHOO.widget.DataTable(bills,this.columnSet,null,{_sName:"bill-table"});
};

YAHOO.util.Event.onAvailable("bills",YAHOO.example.enhanceFromMarkup,YAHOO.example.enhanceFromMarkup,true);
