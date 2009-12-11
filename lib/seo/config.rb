module Seo
  class Config

    @@my_domains = [ 'seopener.com' ]

    cattr_accessor :my_domains
    def self.my_domain=(domain_or_domains)
      @@my_domains = [domain_or_domains].flatten
    end

  end
end