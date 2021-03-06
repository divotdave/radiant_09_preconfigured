require 'uri'
require 'rack/cache/metastore'
require 'rack/cache/entitystore'

module Rack::Cache

  # Maintains a collection of MetaStore and EntityStore instances keyed by
  # URI. A single instance of this class can be used across a single process
  # to ensure that only a single instance of a backing store is created per
  # unique storage URI.
  class Storage
    def initialize
      @metastores = {}
      @entitystores = {}
    end

    def resolve_metastore_uri(uri)
      @metastores[uri.to_s] ||= create_store(MetaStore, uri)
    end

    def resolve_entitystore_uri(uri)
      @entitystores[uri.to_s] ||= create_store(EntityStore, uri)
    end

    def clear
      @metastores.clear
      @entitystores.clear
      nil
    end

  private
    def create_store(type, uri)
      uri = URI.parse(uri) unless uri.respond_to?(:scheme)
      if type.const_defined?(uri.scheme.upcase)
        klass = type.const_get(uri.scheme.upcase)
        klass.resolve(uri)
      else
        fail "Unknown storage provider: #{uri.to_s}"
      end
    end

  public
    @@singleton_instance = new
    def self.instance
      @@singleton_instance
    end
  end

end
