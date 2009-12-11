module Seo::SearchTermsHelper

  def up_down_or_level(val, avg_val, reverse=false)
    return nil if val.nil? or avg_val.nil?
    if reverse
      return :down if (val - avg_val) > 0.0001
      return :up if (avg_val - val) > 0.0001
    else
      return :up if (val - avg_val) > 0.0001
      return :down if (avg_val - val) > 0.0001
    end
    return :level
  end

  def seo_up_or_down_classname(up_or_down)
    return 'gray' if up_or_down.nil?
    return 'red' if up_or_down==:down
    return 'green' if up_or_down==:up
    return ''
  end

  def seo_up_or_down_class(search_term, attr)
    avg_attr = ('avg_'+attr.to_s).to_sym
    val = search_term.send(attr)
    avg_val = search_term.send(avg_attr)
    up_or_down = up_down_or_level(val, avg_val)
    seo_up_or_down_classname(up_or_down)
  end

  def seo_chart_html(search_term, attr, reverse=false)
    avg_attr = ('avg_'+attr.to_s).to_sym
    val = search_term.send(attr)
    avg_val = search_term.send(avg_attr)
    up_or_down = up_down_or_level(val, avg_val, reverse)

    if up_or_down
      if up_or_down==:up
        color = '88DD88'
      elsif up_or_down==:down
        color = 'DD8888'
      else
        color = '000000'
      end
      sparkline_data = search_term.google_sparkline_data(attr)
      minmax = sparkline_data.delete_if {|a| a.nil?}
      minmax = [minmax.min, minmax.max]
      minmax = [minmax[0].to_f - 1, minmax[0].to_f + 1] if minmax[0].to_f==minmax[1].to_f
      minmax[0] = 0.0 if minmax[0].nil?
      minmax[1] = 0.0 if minmax[1].nil?
      minmax.sort!
      image_src = "http://chart.apis.google.com/chart?" +
                    [
                    "chs=50x15",
                    "chco=#{color}",
                    "cht=ls",
                    "chd=t:#{sparkline_data.collect{|d| d.to_s}.join(',')}",
                    "chds=#{minmax[0]},#{minmax[1]}",
                    "chls=3,1,0"
                    ].join('&')
      image_tag image_src, :alt=>"#{attr} Trendline", :style=>"position: relative; top: 5px; margin-top: -10px;"
    else
      ''
    end
  end

  def seo_rss_html
    html = admin_css
    html += render :partial=>'seo/search_terms/seo_search_term_table.html.erb'
  end

end
