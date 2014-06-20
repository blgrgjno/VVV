
if [ -d /srv/www/wordpress-default ]
then
    cd /srv/www/wordpress-default
    if ! egrep -q define.*\'MULTISITE\'.*true wp-config.php
	  then
		    echo "Transforming to multisite"
		    wp core multisite-convert --title="My Network"
	  else
		    echo "Already multisite"
	  fi

	  if ! egrep -q define.*WPLANG.*nb_NO wp-config.php
	  then
		    echo "Upgrade to Norwegian version"
		    sed -i.bak "s/WPLANG',\s*'.*'/WPLANG', 'nb_NO'/" wp-config.php
		    rm wp-config.php.bak
		    wp core update
	  fi

	  # First tried to symlink in, but it was causing trouble with plugins that
	  # relay on correct basename. PHP gets confused when you basename a symlink,
	  # and return wrong path.
	  if [ ! -e /srv/www/wordpress-default/wp-content/.was-provisioned ]
	  then
		    echo "Delete wordpress-default {plugins,mu-plugins,themes} directory"
		    rm -rf /srv/www/wordpress-default/wp-content/{plugins,mu-plugins,themes}
		    # only works on never version of git (after 2012)
		    cd /srv/www/wordpress-default/wp-content
		    git init .
		    git remote add -f origin https://github.com/blgrgjno/main-blog-network.git
		    git config core.sparsecheckout true
		    echo plugins/ >> .git/info/sparse-checkout
		    echo mu-plugins/ >> .git/info/sparse-checkout
		    echo themes/ >> .git/info/sparse-checkout
		    git pull origin master
		    # also ensure the default theme is installed
		    wp theme install twentyfourteen
		    touch /srv/www/wordpress-default/wp-content/.was-provisioned
	  else
		    echo "Updating wordpress-default plugins"
		    cd /srv/www/wordpress-default/wp-content
		    git pull origin master
	  fi
fi
