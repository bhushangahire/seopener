
xml.instruct! :xml, :version=>"1.0" 

xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do |feed|
  
  feed.title   "#{request.host} #{RAILS_ENV} - SEO Tracker"
  feed.link    "rel" => "self", "href" => url_for(:only_path => false, :controller => 'seo/search_terms', :action => 'index', :format=>:atom)
  feed.link    "rel" => "alternate", "href" => url_for(:only_path => false, :controller => 'seo/search_terms')
  feed.id      url_for(:only_path => false, :controller => 'seo/search_terms')
  feed.author  { xml.name "TFS" }
  if @seo_search_terms.any?
    most_recent_update = @seo_search_terms.sort {|a,b| b.updated_at <=> a.updated_at}.first
    feed.updated most_recent_update.updated_at.beginning_of_day.strftime("%Y-%m-%dT%H:%M:%SZ")
    
    feed.entry do |entry|
      entry.title "SEO Tracker Update - #{most_recent_update.updated_at.beginning_of_day.to_formatted_s(:rfc822)}"
      entry.link "rel" => "alternate", "href" => seo_search_terms_url
      entry.id      'TFS_seo_search_term_'+most_recent_update.updated_at.beginning_of_day.to_s
      entry.author  { xml.name 'TFS' }
      entry.summary "SEO Tracker Update"
      entry.updated most_recent_update.updated_at.beginning_of_day.strftime("%Y-%m-%dT%H:%M:%SZ") 
      
      entry.content "type" => "html" do
        entry.text! seo_rss_html
      end
    end
  end
  
end