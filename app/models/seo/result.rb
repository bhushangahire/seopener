class Seo::Result < ActiveRecord::Base
  set_table_name :seo_results
  belongs_to :search_term_query, :class_name=>'Seo::SearchTermQuery', :foreign_key=>'seo_search_term_query_id'

  named_scope :ordered, :order=>'position ASC'
  named_scope :is_my_domain, :conditions=>[
    Seo::Config.my_domains.collect {|domain| 'domain_url = ?' }.join(' OR '),
    *Seo::Config.my_domains
  ]
end
