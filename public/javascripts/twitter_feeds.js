var dateExp = new RegExp('([0-9][0-9][0-9][0-9])');
var timeExp = new RegExp('([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])T([0-9][0-9])([0-9][0-9])([0-9][0-9]).*');

window.TimeIs = function() {;}

window.TimeIs.prototype = {
  get_local_time_for_date: function(time, alt) {
    var system_date = Date.parse(time);
    if (system_date) {
      var user_date = new Date();
      var delta_minutes = Math.floor((user_date - system_date) / (60 * 1000));
      var distance = this.distance_of_time_in_words(delta_minutes);
      if (delta_minutes < 0) {
        return distance + " from now";
      } else {
        return distance + " ago";
      }
    } else {
      return alt;
    }
  },

  // a vague copy of rails' inbuilt function,
  // but a bit more friendly with the hours.
  distance_of_time_in_words: function(minutes) {
    if (minutes.isNaN) return "";
    minutes = Math.abs(minutes);
    if (minutes < 1) return 'less than a minute';
    if (minutes < 50) return minutes.toString() + ' minute' + (minutes == 1 ? '' : 's');
    if (minutes < 90) return 'about one hour';
    if (minutes < 1080) return Math.round(minutes / 60).toString() + " hours";
    if (minutes < 1440) return 'one day';
    if (minutes < 2880) return 'about one day';
    if (minutes > 525600) return 'over a year';
    if (minutes > 43776) {
      months = Math.round(minutes / 43776)
      return months.toString() + " month" + (months == 1 ? '' : 's');
    } else {
      return Math.round(minutes / 1440).toString() + " days";
    }
  }
}

function hyperlink(txt) {
  var regUrl = /(^|[^>\"\/])(http:\/\/|www\.)(?:[^\"])\S*([\s\)\!]|$)/gi;
  var regUrlTail = /[\!\)\]\.\?]+$/g;
  txt = txt.replace(regUrl, function($href,$start,$urlStart,$end,$pos,$txt) {
    if(!$href) {
      return '';
    }
    if($start) {
      $href = $href.substr(1,$href.length-1);
    }
    if($end) {
      $href = $href.substr(0,$href.length-1);
    }
    var trail = $href.match(regUrlTail);
    if(trail) {
      $href = $href.replace(regUrlTail,'');
    }
    if($href.search(/http/i)!=0) {
      $href = 'http://' + $href;
    }
    var link = $start + '<a href="' + $href + '">' + $href.replace('http://','') + '</a>' + (trail?trail[0]:'') + $end;
    return link; // add the start and trail+end back on
  });
  return txt;
};

function replace_all(text, old, replace) {
  while(text.indexOf(old) > 0) { text = text.replace(old,replace); }
  return text;
}

function render_feed(results, dom_id, feed_title) {
  var entry;
  var html = '<div class="hfeed">\n'+
             '  <h2 class="feed-title">' + feed_title + '</h2>\n'+
             '  <div class="entries">\n';

  if (results.length > 0) {
    for (var i = 0; i < results.length; i++) {
      entry = results[i];
      var content = entry.text.replace('Via Beehive: ','');
      var title = hyperlink(content);
      var author = entry.user.screen_name;
      var publishedDate = entry.created_at;
      var user_link = "http://twitter.com/" + author;
      var link = user_link + "/statuses/" + entry.id;
      var img = entry.user.profile_image_url;
      var timeIs = new window.TimeIs();
      var when = timeIs.get_local_time_for_date(publishedDate, publishedDate);

      html += '  <div class="hentry">\n'+
              '    <div class="entry-title">'+
              '      <img style="border: 0; float: left; margin-right: 0.5em;" width="24" height="24" src="' + img + '"></img>'+
              '      <span class="vcard author"><a href="'+user_link+'">' + author + '</a></span> ' +
                     title +
              '      <span class="published" title="' + publishedDate + '"><a href="' + link + '">' + when + '</a></span>'+
              '    </div>\n';
      html += '\n'+
              '  </div>\n';
              //'  <div class="entry-summary">' + content + '</div>\n'+
    }

    html +=   '</div>\n'+
              '<div class="acknowledgement">Tweets thanks to <a href="http://twitter.com/twfynz">Twitter and @twfynz</a>.</div>';
  } else {
    html +=   '</div>\n';
  }
  html +=   '</div>\n';

  document.getElementById(dom_id).innerHTML = html;
}

function get_json() {
  var url = "/friends_timeline.json";

  new Ajax.Request(url, {
    method: 'get',
    onSuccess: function(response) {
      var status = replace_all(response.statusText,' ','');
      if (status == 'OK') {
        var json = response.responseText;
        var data = eval('(' + json + ')');
        render_feed(data, 'twitter_feed', "From Twitter")
      }
    }
  });
}

Event.observe(window, 'load', function() { get_json(); } );
