class Seo::SearchTerm < ActiveRecord::Base
  set_table_name :seo_search_terms
  has_many :search_term_queries, :class_name=>'Seo::SearchTermQuery',
                                 :foreign_key=>'seo_search_term_id',
                                 :dependent=>:destroy

  named_scope :ordered, lambda { |*order|
            { :order => order.flatten.first || 'term ASC' }
          }
  named_scope :sorted_by_careful_update, :order=>'careful_updated_at ASC'
  named_scope :with_queries, :include=>:search_term_queries

  serialize :yahoo_impressions
  serialize :yahoo_clicks
  serialize :yahoo_maxcpc
  validates_presence_of :term

  AVG_DAYS = 10

  def query!(&callback_block)
    query = self.search_term_queries.create
    query.process!(&callback_block)
    self.my_domain_position = self.search_term_queries.recent.first.my_domain_position unless self.search_term_queries.recent.empty?
    self.avg_my_domain_position = self.search_term_queries.over_days(AVG_DAYS).avg_for_attribute(:my_domain_position) unless self.search_term_queries.over_days(AVG_DAYS).empty?
    self.last_query_date = Time.now unless self.search_term_queries.recent.empty?
    self.updated_at = Time.now
    self.save!
  end

  def google_sparkline_data(axis, num_days = AVG_DAYS)
    return [0.0] if self.search_term_queries.empty?
    self.search_term_queries.over_days(num_days).collect {|q| q.send(axis) }.reverse
  end

  def carefully_update_data!

    if self.careful_update_index == 0
      query = self.search_term_queries.recent.first
      unless query.nil?
        result = query.my_domain_result
        self.my_domain_rank = result.nil? ? 0 : Seo::Google::PageRank.new(result.url).page_rank
      end

    elsif self.careful_update_index == 1
      query = self.search_term_queries.recent.first
      unless query.nil?
        result = query.results.ordered.first
        self.top_rank = result.nil? ? 0 : Seo::Google::PageRank.new(result.url).page_rank
      end

    elsif self.careful_update_index == 2
      query = self.search_term_queries.recent.first
      unless query.nil?
        result = query.results.ordered.first
        self.top_domain_rank = result.nil? ? 0 : Seo::Google::PageRank.new(result.domain_url).page_rank
      end

    elsif self.careful_update_index == 3
      result = Yahoo::AdsEstimates.new(self.term)
      self.yahoo_impressions = result.nil? ? [] : result.impressions
      self.yahoo_clicks = result.nil? ? [] : result.clicks
      self.yahoo_maxcpc = result.nil? ? [] : result.max_cpcs

      self.careful_updated_at = Time.now
    end

    self.careful_update_index = (self.careful_update_index + 1) % 4
    self.save
  end

end
