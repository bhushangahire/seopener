class CreateSeoTables < ActiveRecord::Migration
  def self.up

    create_table "seo_results", :force => true do |t|
      t.string   "url"
      t.integer  "position"
      t.integer  "seo_search_term_query_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.string   "content"
      t.string   "domain_url"
    end

    add_index "seo_results", ["created_at"], :name => "index_seo_results_on_created_at"
    add_index "seo_results", ["position"], :name => "index_seo_results_on_position"
    add_index "seo_results", ["seo_search_term_query_id"], :name => "index_seo_results_on_seo_search_term_query_id"
    add_index "seo_results", ["updated_at"], :name => "index_seo_results_on_updated_at"

    create_table "seo_search_term_queries", :force => true do |t|
      t.integer  "my_domain_position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "seo_search_term_id"
      t.integer  "my_domain_result"
      t.integer  "my_domain_result_id"
    end

    add_index "seo_search_term_queries", ["created_at"], :name => "index_seo_search_term_queries_on_created_at"
    add_index "seo_search_term_queries", ["seo_search_term_id"], :name => "index_seo_search_term_queries_on_seo_search_term_id"
    add_index "seo_search_term_queries", ["my_domain_position"], :name => "index_seo_search_term_queries_on_my_domain_position"
    add_index "seo_search_term_queries", ["my_domain_result"], :name => "index_seo_search_term_queries_on_my_domain_result"
    add_index "seo_search_term_queries", ["my_domain_result_id"], :name => "index_seo_search_term_queries_on_my_domain_result_id"
    add_index "seo_search_term_queries", ["updated_at"], :name => "index_seo_search_term_queries_on_updated_at"

    create_table "seo_search_terms", :force => true do |t|
      t.string   "term"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "my_domain_rank"
      t.integer  "top_rank"
      t.integer  "top_domain_rank"
      t.string   "yahoo_impressions"
      t.string   "yahoo_clicks"
      t.string   "yahoo_maxcpc"
      t.datetime "careful_updated_at"
      t.integer  "careful_update_index", :default => 0
      t.integer  "my_domain_position"
      t.float    "avg_my_domain_position"
      t.datetime "last_query_date"
    end

  end

  def self.down
    drop_table "seo_results"
    drop_table "seo_search_term_queries"
    drop_table "seo_search_terms"  end
end


