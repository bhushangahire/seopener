module Seo
  class GenericWorker

    class Cache
      TMPFILE = File.join(RAILS_ROOT, 'tmp', 'seo_generic_worker_cache')

      def self.set(key, value)
        yaml_data = File.exists?(TMPFILE) ? YAML.load_file(TMPFILE) : {}
        yaml_data[key] = value
        File.open(TMPFILE, 'w') {|f| f.write yaml_data.to_yaml }
      end
      def self.get(key)
        yaml_data = File.exists?(TMPFILE) ? YAML.load_file(TMPFILE) : {}
        yaml_data[key]
      end
    end

    def self.run_seo_queries(options)
      Seo::GenericWorker::Cache.set("seo_options", options)
      pid = Process.fork do
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
      Process.detach(pid)
    end

    def self.carefully_update_seo_terms(options)
      pid = Process.fork do
        search_term = Seo::SearchTerm.sorted_by_careful_update.first
        RAILS_DEFAULT_LOGGER.info "----- Carefully updating SEO Term:#{search_term.term} index:#{search_term.careful_update_index}"
        search_term.carefully_update_data!
      end
      Process.detach(pid)
    end

    def self.clean_old_queries(options)
      pid = Process.fork do
        RAILS_DEFAULT_LOGGER.info "----- Cleaning old SEO Results"
        Seo::SearchTermQuery.old.destroy_all
      end
      Process.detach(pid)
    end

    private

    def self.update_progress(progress)
      options = Seo::GenericWorker::Cache.get("seo_options")
      Seo::GenericWorker::Cache.set("seo_#{options[:search_term_id]}_progress", progress)
    end

  end
end