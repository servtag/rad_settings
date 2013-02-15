require 'yaml'

class RadSettings < Hash

  class << self

    def source(value = nil)
      @source ||= value
    end

    def namespace(value = nil)
      @namespace ||= value
    end

    def load!
      @instance = nil
      create_accessors!
      instance
    end

    def instance
      @instance ||= load
    end

    def load
      self[YAML.load_file(source)[namespace]]
    end

    def [](hash)
      return instance[hash] unless hash.is_a?(Hash)

      res = super(hash)

      res.keys.each do |key|
        define_method key.to_s do
          value = self[key.to_s] || self[key.to_sym]
          value.is_a?(Hash) ? self.class[value] : value
        end
      end

      res
    end

    def create_accessors!
      instance.keys.each do |key|
        singleton_class.class_eval do
          define_method key.to_s do
            instance.send(key)
          end
        end
      end
    end

    def to_hash
      Hash[self.instance]
    end

  end

  def to_hash
    Hash[self]
  end

end