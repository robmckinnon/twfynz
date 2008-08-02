== TheyWorkForYou.co.nz (twfynz)

Not ready for other developers just to pick up and run with, as the data
is not committed with this repository.

Email me if you're really interested. My email address is listed at
the development blog: http://blog.theyworkforyou.co.nz/

== Install steps

If the message above didn't put you off here are some install steps.

First make sure you have git installed on your machine <http://git.or.cz/>.
Also be sure to have Ruby installed <http://www.ruby-lang.org/>. Then:

 sudo gem install morph --no-rdoc --no-ri
 sudo gem install hpricot --no-rdoc --no-ri
 sudo gem install json --no-rdoc --no-ri

 sudo apt-get build-dep imagemagick
 wget ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz
 tar xvzf ImageMagick.tar.gz
 cd ImageMagick-6.4.2/
 ./configure --disable-openmp
 make
 sudo make install

 sudo gem install rmagick --no-rdoc --no-ri
 sudo gem install sparklines --no-rdoc --no-ri
 cd ..
 rm -rf ImageMagick*

 git clone git://github.com/robmckinnon/twfynz.git

 cd twfynz/
 git submodule init
 git submodule update   # pulls in rails, rspec and haml

 cd config/
 cp database.yml.example database.yml
 vi database.yml        # edit database.yml as required
 sudo mysqladmin create twfynz_test
 sudo mysqladmin create twfynz_development
 sudo mysqladmin create twfynz_production

 rake gems:install      # repeat until all gems installed
 rake gems              # should show all gems installed [I]

 rake db:migrate        # creates tables in development environment
 rake db:test:clone_structure    # creates tables in test environment
 rake spec              # runs specs -> should be green!

 ./script/server        # go to http://localhost:3000/ in browser

You won't have any data, but should see a few pages render in browser.

== Contact

You can contact me at my email address listed on
the development blog: http://blog.theyworkforyou.co.nz/


sudo mongrel_rails cluster::configure -e production \ -p 8000 -N 3 -c /var/www/twfynz -a 127.0.0.1 \ --user www-data --group www-data
