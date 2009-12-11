SEOpener
========

SEOpener is a rails plugin that provides web search ranking statistics and monitoring.

It provides a set of models, views, and controllers that allow you to define search terms that you care about, and then scrape the Google search results for these terms, looking for the position and PageRank of your domain.  It also collects estimated CPC and traffic statistics using a Yahoo API.


Dependencies
========

SEOpener requires the following gems:

    config.gem 'yahoo_ads_estimates'
    config.gem 'googleajax'
    config.gem 'fastercsv'


Install
========

SEOpener is a Rails Engine plugin.  You can install it using:

    script/plugin install git://github.com/jkrall/seopener.git

Once installed, you must run the setup rake task:

    rake seopener:setup

which will install the seopener.css stylesheet, and copy the migration file into your db/migrate directory.
Then, you should migrate your database to create the SEOpener tables.

    rake db:migrate


Configuration
=========

There are a couple of key configuration settings that you will need to add to your environment.rb file.
First, you will need to set your Google AJAX API key:

    # Google AJAX API Key
    GoogleAjax.api_key = 'abcdefghijklmnop...'
    GoogleAjax.referer = 'http://mysite.com'

In addition, you will need to tell SEOpener the domain and name of your site:

    Seo::Config.my_domain = 'transfs.com'
    Seo::Config.my_site_name = 'TransFS'


Background Processing of SEO Queries
==========

By default, SEOpener comes with a very naive "generic" background worker.
To process your SEO query requests, it forks a background thread and uses a temp file in RAILS_ROOT/tmp to cache data and communicate with your app.  NOTE: This is NOT a production solution!

For proper background processing of your SEO data, you will need to install a background processing engine of some kind.  There are many different flavors, but the one that I have used and recommend is Workling (with Starling).  I wrote about our experience with Workling/Starling [here](http://transfs.com/devblog/2009/04/06/goodbye-backgroundrb-hello-workling-starling/).

To hook up your own background processing engine, you will need to subclass the generic worker class in SEOpener, and provide your own glue code.  Take a look at the Seo::NaiveWorker class for a rough example of how to do this.  Once you have created your own worker subclass (which must reside in the Seo:: module namespace), then you can hook it up by specifying the class in your environment.rb config:

    Seo::Config.background_worker = :my_custom_worker

For an example of using SEOpener with Workling, see the Seo::WorklingWorker class.  It is designed to work with an SeoWorker Workling class, that contains most of the updating logic from Seo::GenericWorker.

This will get you to a working setup that allows you to run background-processed queries via a "Query!" link in the SEO interface.  In addition, you can invoke the complete updating of your SEO Terms by running the "carefully_update_seo_terms" method via a regularly schedule cron job.  This method queries some of the Google/Yahoo endpoints that require less-regular updating so that they return valid data.  It is recommended that this method be run every 10 minutes or so, and as such, it will often take a day or more to completely cycle through updating all of your terms.

--------------




This plugin was developed by [Joshua Krall](http://github.com/jkrall) at [TransFS.com](http://transfs.com), and released to the community as an open-source project.  More info can be found at the [TransFS.com Development Blog](http://transfs.com/devblog).

Copyright (c) 2009 TransFS.com, released under the MIT license
