class Seo::SearchTermQuery < ActiveRecord::Base
  set_table_name :seo_search_term_queries
  has_many :results, :class_name=>'Seo::Result', :foreign_key=>'seo_search_term_query_id', :dependent=>:destroy
  belongs_to :my_domain_result, :class_name=>'Seo::Result'
  belongs_to :search_term, :class_name=>'Seo::SearchTerm', :foreign_key=>'seo_search_term_id'

  named_scope :chronological, :order=>'created_at DESC'
  named_scope :recent, :conditions=>['created_at > ?', 2.month.ago], :order=>'created_at DESC'
  named_scope :old, :conditions=>['created_at < ?', 2.month.ago], :order=>'created_at DESC'
  named_scope :over_days, lambda { |ndays| { :conditions=>['created_at > ?', ndays.days.ago], :order=>'created_at DESC' }} do
    def avg_for_attribute(attr)
      _sum = self.sum(attr).to_f
      _sum = 0.0 if _sum.nil?
      _count = self.count(:conditions=>"#{attr} IS NOT NULL")
      _count = 1.0 if _count.nil? or _count==0.0
      _sum / _count
    end
  end

  attr_accessor :callback_block

  def process!(&callback_block)
    @callback_block = callback_block

    # Do the web search, creating and storing the results
    Seo::Google::WebSearch.new(self.term, &(self.method(:process_callback)) )

    # go through the results and look for transfs.com
    my_domain = self.results.ordered.is_my_domain.first
    if not my_domain.nil?
      self.my_domain_position = my_domain.position
      self.my_domain_result = my_domain
    end

    self.save!
  end

  def term
    self.search_term.term
  end

  def process_callback(result, position)
      r = Seo::Result.create( :title => result.titleNoFormatting,
                              :content => result.content,
                              :url => result.unescapedUrl,
                              :domain_url => result.visibleUrl[/\w+\.\w+$/],
                              :position => position+1
                            )
      results << r

      @callback_block.call( (position+1).to_f/64.0*100.0 ) if @callback_block
  end

  def to_csv(options={})
    output = ''
    results.each do |result|
      data = [
  			result.position,
        result.url,
        result.title,
        result.domain_url,
      ]
      output += FasterCSV.generate_line(data, options)
    end
    output
  end

  def to_csv_headers(options={})
    [
			'position',
      'url',
      'title',
      'domain_url',
    ]
  end


end
