YAHOO.example.enhanceFromMarkup = function() {
    this.columnHeaders = [
        {key:"name", text:"Sort by name", sortable:true},
        {key:"event", text:"Recent event", sortable:false},
        {key:"date", type:"date", text:"Sort by date", sortable:true},
        {key:"trackers", type:"number", text:"Sort by <br /> others <br /> tracking", sortable:true}
    ];
    this.columnSet = new YAHOO.widget.ColumnSet(this.columnHeaders);

    var trackings = YAHOO.util.Dom.get("trackings");
    this.dataTable = new YAHOO.widget.DataTable(trackings,this.columnSet,null,{_sName:"items_tracked"});
};

YAHOO.util.Event.onAvailable("trackings",YAHOO.example.enhanceFromMarkup,YAHOO.example.enhanceFromMarkup,true);
