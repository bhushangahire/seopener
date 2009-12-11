
class Seo::Google::WebSearch
  
  attr_reader :results

  module GooglePageSize
    LARGE = 8
    SMALL = 4
  end
  
  def initialize(query, &result_block)
    @query = query
    @block = result_block
    
    goog = GoogleAjax::Search.web(@query, :rsz=>'large')
  
    process_page_results(goog.results, 0)
  
    1.upto(7) do |page_num|
      do_page_search(page_num)
    end
  end

  private 
  
  def do_page_search(page_num)
    start = page_num * GooglePageSize::LARGE
    goog = GoogleAjax::Search.web(@query, :rsz=>'large', :start=>start)
    process_page_results( goog.results, start )
  end
  
  def process_page_results(results, page_start)
    results.each_with_index {|r,i| @block.call(r,i+page_start) if @block } 
  end

  # Results look like this:
  #
  #  #<GoogleAjax::Search::Result 
  #    title="<b>Hello world</b> program - Wikipedia, the free encyclopedia", 
  #    GsearchResultClass="GwebSearch", 
  #    cacheUrl="http://www.google.com/search?q=cache:d_LgLFnyKcsJ:en.wikipedia.org", 
  #    url="http://en.wikipedia.org/wiki/Hello_world_program", 
  #    visibleUrl="en.wikipedia.org", 
  #    titleNoFormatting="Hello world program - Wikipedia, the free encyclopedia", 
  #    content="A &quot;<b>Hello World</b>&quot; program is a computer program that prints out &quot;<b>Hello world</b>!&quot; on   a display device. It is used in many introductory tutorials for teaching a <b>...</b>", 
  #    unescapedUrl="http://en.wikipedia.org/wiki/Hello_world_program">  
  
  
end