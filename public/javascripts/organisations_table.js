YAHOO.example.compNull = function(a, b, x, y, comp, m, n, primary, first, second, first_reverse_sort) {
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
      if (first_reverse_sort == "y") {
        comparison = (comparison !== 0) ? comparison : comp(n[first], m[first]);
      } else {
        comparison = (comparison !== 0) ? comparison : comp(m[first], n[first]);
      }
    }
    if (second != null) {
      comparison = (comparison !== 0) ? comparison : comp(m[second], n[second]);
    }
    return comparison;
  }
};

YAHOO.example.sortCategoriesAsc = function(a, b) {
  return YAHOO.example.compNull(a, b, 1, -1, YAHOO.util.Sort.compareAsc, a, b, 'category', 'mentions', 'organisation', 'y');
};
YAHOO.example.sortCategoriesDesc = function(a, b) {
  return YAHOO.example.compNull(b, a, -1, 1, YAHOO.util.Sort.compareDesc, b, a, 'category', 'mentions', 'organisation', 'y');
};

YAHOO.example.sortSubmissionsAsc = function(a, b) {
  return YAHOO.example.compNull(b, a, 1, -1, YAHOO.util.Sort.compareAsc, a, b, 'submissions', 'organisation', 'category', 'n');
};
YAHOO.example.sortSubmissionsDesc = function(a, b) {
  return YAHOO.example.compNull(b, a, -1, 1, YAHOO.util.Sort.compareDesc, b, a, 'submissions', 'organisation', 'category', 'n');
};

YAHOO.example.sortMentionsAsc = function(a, b) {
  return YAHOO.example.compNull(b, a, -1, 1, YAHOO.util.Sort.compareDesc, b, a, 'mentions', 'organisation', 'category', 'n');
};
YAHOO.example.sortMentionsDesc = function(a, b) {
  return YAHOO.example.compNull(b, a, 1, -1, YAHOO.util.Sort.compareAsc, a, b, 'mentions', 'organisation', 'category', 'n');
};

YAHOO.example.enhanceFromMarkup = function() {
    this.columnHeaders = [
        {key:"organisation", text:"Organisation", sortable:true},
        {key:"submissions", type:"number", text:"Submission items (since Sept 2007)", sortable:true, sortOptions:{ascFunction:YAHOO.example.sortSubmissionsAsc,descFunction:YAHOO.example.sortSubmissionsDesc}},
        {key:"mentions", type:"number", text:"Debates mentioned in (since Nov 2005)", sortable:true, sortOptions:{ascFunction:YAHOO.example.sortMentionsAsc,descFunction:YAHOO.example.sortMentionsDesc}},
        {key:"category", text:"Organisational category", sortable:true, sortOptions:{ascFunction:YAHOO.example.sortCategoriesAsc,descFunction:YAHOO.example.sortCategoriesDesc}}
    ];
    this.columnSet = new YAHOO.widget.ColumnSet(this.columnHeaders);

    var portfolios = YAHOO.util.Dom.get("organisations");
    this.dataTable = new YAHOO.widget.DataTable(portfolios,this.columnSet,null,{_sName:"organisation-table"});
};

YAHOO.util.Event.onAvailable("organisations",YAHOO.example.enhanceFromMarkup,YAHOO.example.enhanceFromMarkup,true);
