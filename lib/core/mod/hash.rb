#
# Hash class additions
#
# Over time these may get depreciated in favor of other solutions.
#
class Hash

  # Search for a key (potentially recursively) in a given hash.
  #
  # This method uses strict matching between string and symbol key types.  They
  # must be the same type or they will not match.
  #
  # * *Parameters*
  #   - [String, Symbol] *search_key*  Key to search for in hash
  #   - [Hash<String, Symbol|ANY>] *options*  Search options
  #     - [Boolean] *:recurse*  Whether to recurse through sub hashes to find key value
  #     - [Integer] *:recurse_level*  Maximum level to recurse into nested hashes or -1 for all
  #
  # * *Returns*
  #   - [ANY]  Return value for search key if value found, nil otherwise
  #
  # * *Errors*
  #
  # See also:
  # - Nucleon::Util::Data::interpolate
  #
  def search(search_key, options = {})
    config = Nucleon::Config.ensure(options)
    value  = nil

    recurse       = config.get(:recurse, false)
    recurse_level = config.get(:recurse_level, -1)

    self.each do |key, data|
      if key == search_key
        value = data

      elsif data.is_a?(Hash) &&
        recurse && (recurse_level == -1 || recurse_level > 0)

        recurse_level -= 1 unless recurse_level == -1
        value = value.search(search_key,
          Nucleon::Config.new(config).set(:recurse_level, recurse_level)
        )
      end
      break unless value.nil?
    end
    return value
  end
end
