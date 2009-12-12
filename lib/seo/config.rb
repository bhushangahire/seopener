module Seo
  class Config

    class SettingsStruct < OpenStruct
      def [](k)
        self.send(k)
      end
      def []=(k, v)
        self.send("#{k}=", v)
      end
    end

    @@settings = SettingsStruct.new YAML.load_file(File.join(RAILS_ROOT, 'config', 'seopener.yml'))

    def self.my_domains
      @@settings[:my_domains] ||= []
      ([@@settings[:my_domain]] + @@settings[:my_domains]).uniq.delete_if {|d| d.nil?}
    end

    def self.background_worker_class
      "Seo::#{@@settings[:background_worker].to_s.classify}".constantize
    end
    def self.background_worker_cache
      "Seo::#{@@settings[:background_worker].to_s.classify}::Cache".constantize
    end

    def self.method_missing(method, *args)
      if @@settings.respond_to?(method)
        return @@settings.send(method, args)
      end
      super
    end

  end
end