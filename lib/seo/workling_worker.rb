module Seo
  class WorklingWorker < Seo::GenericWorker

    class Cache
      def self.set(key, value)
        Workling.return.set(key, value)
      end
      def self.get(key)
        Workling.return.get(key)
      end
    end

    def self.run_seo_queries(options)
      ::SeoWorker.async_run_seo_queries(options)
    end

    def self.carefully_update_seo_terms(options)
      ::SeoWorker.async_carefully_update_seo_terms(options)
    end

    def self.clean_old_queries(options)
      ::SeoWorker.async_clean_old_queries(options)
    end

  end
end