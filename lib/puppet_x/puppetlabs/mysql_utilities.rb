module PuppetX
  module Puppetlabs
    class MysqlUtilities
      def self.normalized?(hash, key)
        return true if hash.key?(key)
        return false unless key =~ %r{-|_}
        other_key = key.include?('-') ? key.tr('-', '_') : key.tr('_', '-')
        return false unless hash.key?(other_key)
        hash[key] = hash.delete(other_key)
        true
      end

      def self.overlay(hash1, hash2)
        hash2.each do |key, value|
          if self.normalized?(hash1, key) && value.is_a?(Hash) && hash1[key].is_a?(Hash)
            self.overlay(hash1[key], value)
          else
            hash1[key] = value
          end
        end
      end
    end
  end
end

