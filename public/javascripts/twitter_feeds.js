google.load("feeds", "1");

function render_feed(dom_id, feed_title, url) {
  var html = '  <div class="hfeed">\n'+
            '    <h2 class="feed-title">' + feed_title + '</h2>\n'+
            '    <div class="entries">\n';
  if (results[dom_id].length > 0) {
    for (var i = 0; i < results[dom_id].length; i++) {
      var entry = results[dom_id][i];

      var content = entry.content;
      var title = entry.title;
      var author = content.split(':')[0];
      var when = 'recently';
      var publishedDate = entry.publishedDate;
      var link = entry.link;

      html += '      <div class="hentry">\n'+
              '        <div class="entry-title"><a href="' + link + '">' + title + '</a></div>\n';
      html += '      <div><span class="vcard author">' + author + '</span>';
      html += ' <span class="published" title="' + publishedDate + '">' + when + '</span>';

      html += '</div>\n'+
              //'        <div class="entry-summary">' + content + '</div>\n'+
              '      </div>\n';
    }

    html += '    </div>\n'+
            '    <div class="acknowledgement">Tweets thanks to <a href="http://twitter.com/twfynz">Twitter and @twfynz</a>.</div>\n'+
            '  </div>\n';
  } else {
    html += '      <p class="acknowledgement">No recent news items found with <a href="' + url + '">Google News Search</a>.</p>\n'+
            '    </div>\n'+
            '  </div>\n';
  }

  document.getElementById(dom_id).innerHTML = html;
}

function make_feed(dom_id, feed_title, urls) {
  if (results[dom_id] == null) {
    results[dom_id] = new Array;
  }
  counts[dom_id] = urls.length;

  for (var i = 0; i < urls.length; i++) {
    var url = urls[i];
    var feed = new google.feeds.Feed(url);
    feed.setNumEntries(20);
    feed.load(function(result) {
      if (!result.error) {
        var feed = result.feed;
        for (var i = 0; i < feed.entries.length; i++) {
          var entry = feed.entries[i];
          var link = entry['link'];
          results[dom_id].push(entry);
        }

        counts[dom_id] = counts[dom_id] - 1;
        if (counts[dom_id] == 0) {
          render_feed(dom_id, feed_title, url);
        }
      }
    });
  }
}

function initialize() {
  results = new Object;
  counts = new Object;
  make_feed('twitter_feed', 'From Twitter', ["http://theyworkforyou.co.nz/friends_timeline.atom"]);
}

google.setOnLoadCallback(initialize);
