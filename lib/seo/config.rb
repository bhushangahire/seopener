module Seo
  class Config

    @@my_domains = [ 'seopener.com' ]
    cattr_accessor :my_domains
    def self.my_domain=(domain_or_domains)
      @@my_domains = [domain_or_domains].flatten
    end

    @@my_site_name = 'My Site'
    cattr_accessor :my_site_name

    @@background_worker = :generic_worker
    cattr_accessor :background_worker
    def self.background_worker_class
      "Seo::#{@@background_worker.to_s.classify}".constantize
    end
    def self.background_worker_cache
      "Seo::#{@@background_worker.to_s.classify}::Cache".constantize
    end

  end
end