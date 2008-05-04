var Flash = new Object();

Flash.data = {};

Flash.transferFromCookies = function() {
  var data = JSON.parse(unescape(Cookie.get("flash")));
  if(!data) data = {};
  Flash.data = data;
  Cookie.erase("flash");
};

Flash.writeDataTo = function(name, element, write_blank) {
  if(Flash.data[name]) {
    var content = Flash.data[name].toString().gsub(/\+/, ' ');

    if ($(element)) {
      $(element).innerHTML = unescape(content);
      if ($(element).innerHTML.indexOf('<br>') != -1) {
        var texts = $(element).innerHTML.split('<br>');
        var last_index = texts.length - 1;
        var text = texts[last_index];
        $(element).innerHTML = text;
      }
    }
  } else if (write_blank) {
    if ($(element)) {
      $(element).innerHTML = "";
    }
  }
};
