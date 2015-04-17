module Tunable

  module Hasher

    def self.flatten(hash, primary_key, secondary_key = nil)
      if secondary_key.nil?
        hashify_using(hash, primary_key)
      else
        double_hashify_using(hash, primary_key, secondary_key)
      end
    end

    private

    def self.hashify_using(hash, key)
      return {} if hash.empty?
      Hash[*hash.collect { |v| [v.send(key).to_sym, v.normalized_value] }.flatten]
    end

    def self.double_hashify_using(hash, primary_key, secondary_key)
      return {} if hash.empty?
      c = {}
      hash.collect { |e| c[e.send(primary_key).to_sym] = {} }
      hash.collect { |e| c[e.send(primary_key).to_sym][e.send(secondary_key).to_sym] = e.normalized_value }
      c
    end

  end

end
