google.load("feeds", "1");

function render_news_feed(dom_id, feed_title, term, url) {
  url = url.replace('&output=atom','');//.replace('blogsearch_feeds','blogsearch');
  var html = '  <div class="hfeed">\n'+
            '    <h2 class="feed-title">' + feed_title + '</h2>\n'+
            '    <div class="entries">\n';

  if (results[dom_id].length > 0) {
    for (var i = 0; i < results[dom_id].length; i++) {
      var entry = results[dom_id][i];

      var content = entry.content;
      var jq = jQuery('<html><body>' + content + '</body></html>');
      var title = jq.find('a').text();
      var content = jq.find('font[@size="-1"]:eq(1)').text();
      var author = (jq.find('font[@color="#6f6f6f"]').text() + '');
      var when = jq.find('font[@size="-1"]:eq(0)').text().replace(author,'');
      author = author.split(',')[0];
      var publishedDate = entry.publishedDate;
      var link = entry.link;

      // content = (content + '').replace(term + ' Act', '<strong class="highlight">'+ term + ' Act</strong>');
      // content = content.replace(term + ' Bill', '<strong class="highlight">'+ term + ' Bill</strong>');

      html += '      <div class="hentry">\n'+
              '        <div class="entry-title"><a href="' + link + '">' + title + '</a></div>\n';
      html += '      <div><span class="vcard author">' + author + '</span>';
      html += ' <span class="published" title="' + publishedDate + '">' + when + '</span>';

      html += '</div>\n'+
              '        <div class="entry-summary">' + content + '</div>\n'+
              '      </div>\n';
    }

    html += '    </div>\n'+
            '    <div class="acknowledgement">News coverage thanks to <a href="' + url + '">Google News Search</a>.</div>\n'+
            '  </div>\n';
  } else {
    html += '      <p class="acknowledgement">No recent news items found with <a href="' + url + '">Google News Search</a>.</p>\n'+
            '    </div>\n'+
            '  </div>\n';
  }

  //  document.getElementById(dom_id).innerHTML = results[dom_id][0].content;
  document.getElementById(dom_id).innerHTML = html;
}

function render_blog_feed(dom_id, feed_title, term, url) {
  url = url.replace('&output=atom','').replace('blogsearch_feeds','blogsearch');
  var html = '  <div class="hfeed">\n'+
            '    <h2 class="feed-title">' + feed_title + '</h2>\n'+
            '    <div class="entries">\n';

  if (results[dom_id].length > 0) {

    for (var i = 0; i < results[dom_id].length; i++) {
      var entry = results[dom_id][i];
      var content = entry.contentSnippet;
      content = content.replace(term + ' Act', '<strong class="highlight">'+ term + ' Act</strong>');
      content = content.replace(term + ' Bill', '<strong class="highlight">'+ term + ' Bill</strong>');

      html += '      <div class="hentry">\n'+
              '        <div class="entry-title"><a href="' + entry.link + '">' + entry.title + '</a></div>\n';

      if ((entry.author != null) && (entry.author.length > 0) && (entry.author != 'unknown')) {
        html += '      <div><span class="vcard author">' + entry.author + '</span>';
      } else {
        html += '      <div><span class="vcard author">' + entry.link.split('/')[2].replace('www.','') + '</span>';
      }
      html += ' - <span class="published" title="' + entry.publishedDate + '">' + entry.publishedDate.substr(5,11) + '</span>';

      html += '</div>\n';
      html += '        <div class="entry-summary">' + content + '</div>\n'+
              '      </div>\n';
    }
    var ack = feed_title + ' thanks to Google AJAX Feed API'; // and Technorati RSS Search';

    html += '    </div>\n'+
            '    <div class="acknowledgement">Blog coverage thanks to <a href="' + url + '">Google Blog Search</a>.</div>\n'+
            '  </div>\n';
  } else {
    html += '      <p class="acknowledgement">No recent blog posts found with <a href="' + url + '">Google Blog Search</a>.</p>\n'+
            '    </div>\n'+
            '  </div>\n';
  }

  document.getElementById(dom_id).innerHTML = html;
}

function render_feed(dom_id, feed_title, term, url) {
  if (feed_title.indexOf('Blog') != -1) {
    render_blog_feed(dom_id, feed_title, term, url);
  } else if (feed_title.indexOf('News') != -1) {
    render_news_feed(dom_id, feed_title, term, url);
  }
}

function make_feed(dom_id, feed_title, term, urls) {
  if (results[dom_id] == null) {
    results[dom_id] = new Array;
  }
  counts[dom_id] = urls.length;

  for (var i = 0; i < urls.length; i++) {
    var url = urls[i];
    var feed = new google.feeds.Feed(url);
    feed.setNumEntries(16);
    feed.load(function(result) {
      if (!result.error) {
        var feed = result.feed;
        for (var i = 0; i < feed.entries.length; i++) {
          var entry = feed.entries[i];
          var link = entry['link'];
          var ignore = (link.indexOf('etrendpublishing.com') != -1) ||
              (link.indexOf('wonez.com') != -1) ||
              (link.indexOf('seekloan.info') != -1) ||
              (link.indexOf('scoopit.co.nz') != -1) ||
              (link.indexOf('newsdig.info') != -1) ||
              (link.indexOf('financialnewsblogs.com') != -1) ||
              (link.indexOf('zhch3n.com') != -1) ||
              (link.indexOf('remingtonnews.com') != -1) ||
              (link.indexOf('kygenweb-830.blogspot.com') != -1) ||
              (link.indexOf('e-standing.com') != -1) ||
              (link.indexOf('balancetransferinfo.net') != -1) ||
              (link.indexOf('inboxrobot.com') != -1) ||
              (link.indexOf('xuedagong.com') != -1) ||
              (link.indexOf('kilu3.de') != -1) ||
              (link.indexOf('newzealandstar.com') != -1) ||
              (link.indexOf('justicemiscarried.com') != -1) ||
              (link.indexOf('cytologyschool.com') != -1) ||
              (link.indexOf('animalgirlsquail.blogspot.com') != -1) ||
              (link.indexOf('veterinarynews.it') != -1) ||
              (link.indexOf('veterinarynews.it') != -1) ||
              (link.indexOf('lkv91416.blogspot.com') != -1) ||
              (link.indexOf('transport.tradeworlds.com') != -1) ||
              (link.indexOf('feeds.aucklandnews.net') != -1) ||
              (link.indexOf('britneyspearscuriousperfume.org') != -1) ||
              (link.indexOf('secrets-of-speed-reading.info') != -1) ||
              (link.indexOf('bloggernews.net') != -1) ||
              (link.indexOf('muncasterb475.blogspot.com') != -1) ||
              (link.indexOf('rssmicro.com') != -1) ||
              (link.indexOf('1-free-dyson.com') != -1) ||
              (link.indexOf('feeds.newzealandnews.net') != -1) ||
              (link.indexOf('healthworldsex.com') != -1) ||
              (link.indexOf('bradcollins.org') != -1) ||
              (link.indexOf('nathanguy.co.nz') != -1) ||
              (link.indexOf('obiecorp.com') != -1) ||
              (link.indexOf('electronics-blog.net') != -1) ||
              (link.indexOf('dodopupeqagi.blogspot.com') != -1) ||
              (link.indexOf('puffcom.blogspot.com') != -1) ||
              (link.indexOf('mp3-nef.info') != -1) ||
              (link.indexOf('coolcdn.com') != -1) ||
              (link.indexOf('bmuc.blogspot.com') != -1) ||
              (link.indexOf('tap-into-insurance.com') != -1) ||
              (link.indexOf('attorney-auto-accident.org') != -1) ||
              (link.indexOf('mondaq.com') != -1) ||
              (link.indexOf('nzpcs.co.nz') != -1) ||
              (link.indexOf('tag.seomore.com') != -1) ||
              (link.indexOf('causalgibberish.blogspot.com') != -1) ||
              (link.indexOf('yonix.org') != -1) ||
              (link.indexOf('vehicleinfoworld.org') != -1) ||
              (link.indexOf('thebeautifultruth.info') != -1) ||
              (link.indexOf('conference-zone.com') != -1) ||
              (link.indexOf('wellnessnewsnow.info') != -1) ||
              (link.indexOf('ugandanews.net') != -1) ||
              (link.indexOf('wwlra-ward-news.blogspot.com') != -1) ||
              (link.indexOf('lg-519.blogspot.com') != -1) ||
              (link.indexOf('housesandmotions.blogspot.com') != -1) ||
              (link.indexOf('life-insurance-types.blogspot.com') != -1) ||
              (link.indexOf('ddneo.com') != -1);
          if (feed_title.indexOf('Blog') != -1) {
             var title = entry.title;
             var content = entry.contentSnippet;
             if ( (link.indexOf('scoop.co.nz') != -1) ||
                  (link.indexOf('tv3.co.nz') != -1) ||
                  (title.indexOf('Scoop') != -1) ||
                  (content.indexOf('Scoop.co.nz') != -1) ||
                  (content.indexOf('Scoop - ') != -1 ) ) {
               ignore = true;
             }
          }
          if (feed_title.indexOf('News') != -1) {
            var title = entry.title;
            if ( (title.indexOf('Bill Speech') != -1) ||
                 (title.indexOf('Legislation speech') != -1) ||
                 (title.indexOf('Legislation Bill') != -1 && title.indexOf(': ') != -1) ||
                 (title.indexOf('Speech: ') != -1 && title.indexOf('Bill') != -1) ||
                 (title.indexOf('Flavell: ') != -1 && title.indexOf('Bill') != -1) ||
                 (title.indexOf('Bill, 1st Reading') != -1) ||
                 (title.indexOf('Bill, 2nd Reading') != -1) ||
                 (title.indexOf('Bill, 3rd Reading') != -1) ||
                 (title.indexOf('Bill 1st Reading') != -1) ||
                 (title.indexOf('Bill 2nd Reading') != -1) ||
                 (title.indexOf('Bill 3rd Reading') != -1) ||
                 (title.indexOf('Bill: First Reading') != -1) ||
                 (title.indexOf('Bill: Second Reading') != -1) ||
                 (title.indexOf('Bill: Third Reading') != -1) ||
                 (title.indexOf('Questions And Answers') != -1) ||
                 (title.indexOf('Questions and Answers') != -1) ||
                 (title.replace(' - Scoop.co.nz','') == jQuery.trim(document.getElementById('bill_name').innerHTML) && (link.indexOf('scoop.co.nz') != -1)) ||
                 (title.replace(' - Scoop.co.nz','') == jQuery.trim(document.getElementById('bill_name').innerHTML.replace('Amendment ','')) && (link.indexOf('scoop.co.nz') != -1)) ||
                 (title.indexOf('Oral Answer') != -1) ) {
              ignore = true;
            }
          }
          if ( !ignore ) {
            results[dom_id].push(entry);
          }
        }

        counts[dom_id] = counts[dom_id] - 1;
        if (counts[dom_id] == 0) {
          render_feed(dom_id, feed_title, term, url);
        }
      }
    });
  }
}

function initialize() {
  var bill = document.getElementById('bill_name').innerHTML;
  var act = bill.replace(' Bill',' Act');

  var restriction = '';
  var words = bill.split(' ').length;
  if (words < 4) {
    restriction = '+site:nz';
  }
  if (words > 6) {
    bill = bill.replace(' Bill','');
    bill = bill.replace(' Amendment','');
  }

  results = new Object;
  counts = new Object;

  var bill_item = escape(bill);
//  var act_item = escape(act);

  while (bill_item.indexOf('%20') != -1) {
    bill_item = bill_item.replace('%20','+');
  }

  make_feed('news_feed', 'News coverage', bill, [
    "http://news.google.co.nz/news?hl=en&ned=nz&ie=UTF-8&scoring=n&q=%22" + bill_item + "%22" + restriction + "&output=atom"]);
//    "http://news.google.co.nz/news?hl=en&ned=nz&ie=UTF-8&scoring=d&q=%22" + act_item + "%22" + restriction + "&output=atom",
//    "http://news.google.co.nz/news?hl=en&ned=nz&ie=UTF-8&scoring=d&q=%22" + bill_item + "%22" + restriction + "&output=atom"]);

  make_feed('blog_feed', 'Blog coverage', bill, [
    "http://blogsearch.google.co.nz/blogsearch_feeds?hl=en&scoring=d&q=%22" + bill_item + "%22" + restriction + "&ie=utf-8&num=10&output=atom"]);

//    "http://feeds.technorati.com/feed/posts/tag/%22" + bill_item + "%22"]);
//    "http://blogsearch.google.co.nz/blogsearch_feeds?hl=en&scoring=d&q=%22" + act_item + "%22&ie=utf-8&num=10&output=atom",
//    "http://feeds.technorati.com/feed/posts/tag/%22" + act_item + "%22",
}

google.setOnLoadCallback(initialize);
