module Seo
  class NaiveWorker < Seo::GenericWorker

    class Cache
      TMPFILE = File.join(RAILS_ROOT, 'tmp', 'seo_naive_worker_cache')

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
      pid = Process.fork do
        super
      end
      Process.detach(pid)
    end

    def self.carefully_update_seo_terms(options)
      pid = Process.fork do
        super
      end
      Process.detach(pid)
    end

    def self.clean_old_queries(options)
      pid = Process.fork do
        super
      end
      Process.detach(pid)
    end

    private

    def self.update_progress(progress)
      super
    end

  end
end