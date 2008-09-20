YAHOO.example.compNull = function(a, b, desc, primary, first, first_dir, second, second_dir) {
  if(!YAHOO.lang.isValue(a)) {
    return (!YAHOO.lang.isValue(b)) ? 0 : 1;
  } else if(!YAHOO.lang.isValue(b)) {
    return -1;
  }

  var comp = YAHOO.util.Sort.compare;
  var comparison = comp(a.getData(primary), b.getData(primary), desc);

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

var sortCategories = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'category', 'mentions', true, 'organisation', false);
};

var sortSubmissions = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'submissions', 'organisation', false, 'category', false);
};

var sortDonations = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'donations', 'organisation', false, 'category', false);
};

var sortMentions = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'mentions', 'organisation', false, 'category', false);
};

var sortMentions = function(a, b, desc) {
  return YAHOO.example.compNull(a, b, desc, 'mentions', 'organisation', false, 'category', false);
};

var myFormatCurrency = function(elCell, oRecord, oColumn, oData) {
  if(oData == 0) {
    elCell.innerHTML = '-';
  } else {
    elCell.innerHTML = YAHOO.util.Number.format(oData, {prefix:'$', decimalPlaces:0, decimalSeparator:'.', thousandsSeparator:',', suffix:''});
  }
};

YAHOO.util.Event.addListener(window, "load", function() {
  YAHOO.example.EnhanceFromMarkup = new function() {
    var myColumnDefs = [
      {key:"organisation", label:"Organisation",  sortable:true},
      {key:"submissions",  label:"Submission<br /> items", sortable:true, sortOptions:{sortFunction:sortSubmissions, defaultDir:YAHOO.widget.DataTable.CLASS_DESC} },
      {key:"mentions",     label:"Debates<br /> mentioned in", sortable:true, sortOptions:{sortFunction:sortMentions, defaultDir:YAHOO.widget.DataTable.CLASS_DESC} },
      {key:"donations",    label:"Donations", sortable:true, formatter:myFormatCurrency, sortOptions:{sortFunction:sortDonations, defaultDir:YAHOO.widget.DataTable.CLASS_DESC} },
      {key:"category",     label:"Category", sortable:true, sortOptions:{sortFunction:sortCategories} }
    ];
    this.myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("organisation-table"));
    this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
    this.myDataSource.responseSchema = {
      fields: [{key:"organisation", parser:YAHOO.util.DataSource.parseString},
              {key:"submissions", parser:YAHOO.util.DataSource.parseNumber},
              {key:"mentions", parser:YAHOO.util.DataSource.parseNumber},
              {key:"donations", parser:YAHOO.util.DataSource.parseNumber},
              {key:"category", parser:YAHOO.util.DataSource.parseString}
      ]
    };
    this.myDataTable = new YAHOO.widget.DataTable("organisations", myColumnDefs, this.myDataSource,
      {sortedBy:{key:"mentions",dir:"desc"}}
    );
  };
});
