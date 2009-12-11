module Seo
  class GenericWorker

    class Cache
      def self.set(key, value)
      end
      def self.get(key)
      end
    end

    def self.run_seo_queries(options)
      Seo::Config.background_worker_cache.set("seo_options", options)

      search_term_id = options[:search_term_id]
      RAILS_DEFAULT_LOGGER.info "----- Query Google for SEO Results, id: #{search_term_id}"

      if search_term_id.nil?
        search_terms = Seo::SearchTerm.ordered
      else
        search_terms = [ Seo::SearchTerm.find(search_term_id) ]
      end

      search_terms.each do |search_term|
        RAILS_DEFAULT_LOGGER.info "----- Querying: #{search_term.term}"
        search_term.query!( &(self.method(:update_progress)) )
        update_progress(100.0)
      end
    end

    def self.carefully_update_seo_terms(options)
      search_term = Seo::SearchTerm.sorted_by_careful_update.first
      RAILS_DEFAULT_LOGGER.info "----- Carefully updating SEO Term:#{search_term.term} index:#{search_term.careful_update_index}"
      search_term.carefully_update_data!
    end

    def self.clean_old_queries(options)
      RAILS_DEFAULT_LOGGER.info "----- Cleaning old SEO Results"
      Seo::SearchTermQuery.old.destroy_all
    end

    protected

    def self.update_progress(progress)
      options = Seo::Config.background_worker_cache.get("seo_options")
      Seo::Config.background_worker_cache.set("seo_#{options[:search_term_id]}_progress", progress)
    end

  end
end