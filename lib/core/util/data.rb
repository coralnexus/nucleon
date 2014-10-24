
module Nucleon
module Util
#
# == Data utilities
#
# The Nucleon::Util::Data class defines various tools for working with data in
# the Nucleon system.
#
# It implements:
# 1. Type checkers
# 2. Basic data translators
# 3. Data transformations
# 4. Other utilities
#
class Data

  #*****************************************************************************
  # Type checking

  # Check if given value is undefined.
  #
  # It currently checks for: (our definition of undefined)
  # * *nil*
  # * Symbols: *:undef*, *:undefined*
  # * Strings: "*undef*", "*UNDEF*", "*Undef*", "*nil*", "*NIL*", "*Nil*"
  #
  # This method was created to provide an easy way for us to load and work with
  # configurations from text formats, such as JSON.
  #
  # * *Parameters*
  #   - [ANY] *value*  Value to check if undefined
  #
  # * *Returns*
  #   - [Boolean]  Returns true if value is undefined, false otherwise
  #
  # * *Errors*
  #
  def self.undef?(value)
    if value.nil? ||
      (value.is_a?(Symbol) && value == :undef || value == :undefined) ||
      (value.is_a?(String) && value.match(/^\s*(undef|UNDEF|Undef|nil|NIL|Nil)\s*$/))
      return true
    end
    return false
  end

  # Check if given value is true.
  #
  # It currently checks for: (our definition of true)
  # * *true*
  # * Symbols: *:true*
  # * Strings: "*true*", "*TRUE*", "*True*"
  #
  # This method was created to provide an easy way for us to load and work with
  # configurations from text formats, such as JSON.
  #
  # * *Parameters*
  #   - [ANY] *value*  Value to check if true
  #
  # * *Returns*
  #   - [Boolean]  Returns true if value is true, false otherwise
  #
  # * *Errors*
  #
  def self.true?(value)
    if value == true ||
      (value.is_a?(Symbol) && value == :true) ||
      (value.is_a?(String) && value.match(/^\s*(true|TRUE|True)\s*$/))
      return true
    end
    return false
  end

  # Check if given value is false.
  #
  # It currently checks for: (our definition of false)
  # * *false*
  # * Symbols: *:false*
  # * Strings: "*false*", "*FALSE*", "*False*"
  #
  # This method was created to provide an easy way for us to load and work with
  # configurations from text formats, such as JSON.
  #
  # * *Parameters*
  #   - [ANY] *value*  Value to check if false
  #
  # * *Returns*
  #   - [Boolean]  Returns true if value is false, false otherwise
  #
  # * *Errors*
  #
  def self.false?(value)
    if value == false ||
      (value.is_a?(Symbol) && value == :false) ||
      (value.is_a?(String) && value.match(/^\s*(false|FALSE|False)\s*$/))
      return true
    end
    return false
  end

  # Check if given value is empty.
  #
  # It currently checks for: (our definition of empty)
  # * ::undef?
  # * ::false?
  # * value.empty?
  #
  # This method was created to provide an easy way for us to load and work with
  # configurations from text formats, such as JSON.
  #
  # * *Parameters*
  #   - [ANY] *value*  Value to check if empty
  #
  # * *Returns*
  #   - [Boolean]  Returns true if value is empty, false otherwise
  #
  # * *Errors*
  #
  def self.empty?(value)
    if undef?(value) || false?(value) || (value.respond_to?('empty?') && value.empty?)
      return true
    end
    return false
  end

  # Check if given keys exist in data hash.
  #
  # This method allows for the easy checking of nested keys.  It takes care of
  # traversing the data structure and checking for empty recursively.
  #
  # * *Parameters*
  #   - [Hash<String, Symbol|...|ANY>] *data*  Data object to check
  #   - [Array<String, Symbol>] *keys*  Hash key path (nested keys)
  #   - [Boolean] *check_empty*  Whether to check element for emptiness
  #
  # * *Returns*
  #   - [Boolean]  Returns true if keys exist and not empty, false otherwise if check_empty
  #   - [Boolean]  Returns true if keys exist, false otherwise
  #
  # * *Errors*
  #
  # See:
  # - ::empty?
  #
  def self.exists?(data, keys, check_empty = false)
    if keys.is_a?(String) || keys.is_a?(Symbol)
      keys = [ keys ]
    end
    key = keys.shift.to_sym

    if data.has_key?(key)
      value = data[key]

      if keys.empty?
        return false if check_empty && empty?(value)
        return true
      else
        return exists?(data[key], keys)
      end
    end
    return false
  end

  #*****************************************************************************
  # Translation

  # Return hash as a symbol map.
  #
  # This method converts all hash keys to symbols.  Nested hashes are
  # recursively translated as well.
  #
  # This comes in really handy when performing operations across hashes in Ruby
  # because of the distinction between symbols and strings.
  #
  # * *Parameters*
  #   - [Hash<String, Symbol|...|ANY>] *data*  Hash data to symbolize keys
  #
  # * *Returns*
  #   - [Hash<Symbol|...|ANY>]  Returns data structure symbolized
  #
  # * *Errors*
  #
  # See also:
  # - ::string_map
  #
  def self.symbol_map(data)
    results = {}
    return data unless data

    case data
    when Hash
      data.each do |key, value|
        results[key.to_sym] = symbol_map(value)
      end
    else
      results = data
    end
    return results
  end

  # Return hash as a string map.
  #
  # This method converts all hash keys to strings.  Nested hashes are
  # recursively translated as well.
  #
  # This comes in really handy when performing operations across hashes in Ruby
  # because of the distinction between symbols and strings.
  #
  # * *Parameters*
  #   - [Hash<String, Symbol|...|ANY>] *data*  Hash data to stringify keys
  #
  # * *Returns*
  #   - [Hash<String|...|ANY>]  Returns data structure grouped by string keys
  #
  # * *Errors*
  #
  # See also:
  # - ::symbol_map
  #
  def self.string_map(data)
    results = {}
    return data unless data

    case data
    when Hash
      data.each do |key, value|
        results[key.to_s] = string_map(value)
      end
    else
      results = data
    end
    return results
  end

  # Parse a JSON string into a Ruby data object.
  #
  # This method uses the MultiJson gem to carry out the heavy lifting. We just
  # sit back and enjoy the ride.
  #
  # * *Parameters*
  #   - [String] *json_text*  JSON text string to parse into Ruby data
  #
  # * *Returns*
  #   - [nil, true, false, String, Array, Hash<String|...|ANY>]  Returns parsed data object
  #
  # * *Errors*
  #
  # See also:
  # - ::to_json
  #
  def self.parse_json(json_text)
    return MultiJson.load(json_text)
  end

  # Dump a Ruby object to a JSON string.
  #
  # This method uses the MultiJson gem to carry out the heavy lifting. We just
  # sit back and enjoy the ride.
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data to render JSON string
  #
  # * *Returns*
  #   - [String]  Returns JSON rendered data object
  #
  # * *Errors*
  #
  # See also:
  # - ::parse_json
  #
  def self.to_json(data, pretty = true)
    return MultiJson.dump(data, :pretty => pretty)
  end

  # Parse a YAML string into a Ruby data object.
  #
  # This method uses the Ruby YAML module to carry out the heavy lifting. We
  # just sit back and enjoy the ride.
  #
  # * *Parameters*
  #   - [String] *yaml_text*  YAML text string to parse into Ruby data
  #
  # * *Returns*
  #   - [nil, true, false, String, Array, Hash<String|...|ANY>]  Returns parsed data object
  #
  # * *Errors*
  #
  # See also:
  # - ::to_yaml
  #
  def self.parse_yaml(yaml_text)
    return YAML.load(yaml_text)
  end

  # Dump a Ruby object to a YAML string.
  #
  # This method uses the Ruby YAML module to carry out the heavy lifting. We
  # just sit back and enjoy the ride.
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data to render YAML string
  #
  # * *Returns*
  #   - [String]  Returns YAML rendered data object
  #
  # * *Errors*
  #
  # See also:
  # - ::parse_yaml
  #
  def self.to_yaml(data)
    return YAML.dump(data)
  end

  # Translate a value to internally standardized form.
  #
  # It currently translates:
  # * ::undef? to *undefined_value*
  # * ::true? to *true*
  # * ::false? to *false*
  # * Array (recursively)
  # * Hash (recursively)
  #
  # This method was created to provide an easy way for us to load and work with
  # configurations from text formats, such as JSON.
  #
  # * *Parameters*
  #   - [ANY] *value*  Value to internalize
  #   - [ANY] *undefined_value*  Value that represents undefined (*nil*)
  #
  # * *Returns*
  #   - [ANY]  Returns internalized value object
  #
  # * *Errors*
  #
  def self.value(value, undefined_value = nil)
    case value
    when String
      if undef?(value)
        value = undefined_value
      elsif true?(value)
        value = true
      elsif false?(value)
        value = false
      end

    when Array
      value.each_with_index do |item, index|
        value[index] = value(item, undefined_value)
      end

    when Hash
      value.each do |key, data|
        value[key] = value(data, undefined_value)
      end
    end
    return value
  end

  # Run a defined filter on a data object.
  #
  # This method ensures that a given data object meets some criteria or else
  # an empty value for that type is returned that matches the criteria.
  #
  # Currently implemented filters:
  # 1. ::array  Ensure result is an array (non arrays are converted)
  # 2. ::hash   Ensure result is a hash (non hashes are converted)
  # 3. ::string Ensure result is a string (non strings are converted)
  # 4. ::symbol Ensure result is a symbol (non symbols are converted)
  # 5. ::test   Ensure result is not empty (runs a boolean ::empty? check)
  #
  # More filters can be added by adding methods to the Nucleon::Util::Data class.
  #
  # For example:
  #
  #   module Nucleon::Util::Data
  #     def my_filter(data, default = '')
  #       # Return data modified or default
  #     end
  #   end
  #
  #   my_data = Nucleon::Util::Data.filter(my_data, :my_filter)
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data object to run through filter
  #   - [false, String] *method*  Filter method to execute or false for none
  #
  # * *Returns*
  #   - [ANY]  Returns filtered data object
  #
  # * *Errors*
  #
  def self.filter(data, method = false)
    if method && respond_to?(method.to_sym)
      return send(method.to_sym, data)
    end
    return data
  end

  # Ensure a data object is an array.
  #
  # It converts:
  # 1. Symbols to arrays
  # 2. Strings to arrays
  # 3. Splits strings on commas (if *split_string* requested)
  # 4. If no array found, returns *default*
  #
  # TODO: Parameter for string separator split
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data to ensure array
  #   - [Array] *default*  Default value if no array is found
  #   - [Boolean] *split_string*  Whether to split strings on comma
  #
  # * *Returns*
  #   - [Array]  Returns an array
  #
  # * *Errors*
  #
  # See also:
  # - ::filter (switch)
  # - ::hash
  # - ::string
  # - ::symbol
  # - ::test
  #
  def self.array(data, default = [], split_string = false)
    result = default
    if data
      case data
      when Array
        result = data
      when String
        result = [ ( split_string ? data.split(/\s*,\s*/) : data ) ]
      else
        result = [ data ]
      end
    end
    return result
  end

  # Ensure a data object is a hash.
  #
  # If data is given and it is not a hash, an empty hash is returned in it's
  # place.
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data to ensure hash
  #   - [Hash] *default*  Default value if no data is given (nil)
  #
  # * *Returns*
  #   - [Hash]  Returns a hash
  #
  # * *Errors*
  #
  # See also:
  # - ::filter (switch)
  # - ::array
  # - ::string
  # - ::symbol
  # - ::test
  #
  def self.hash(data, default = {})
    result = default
    if data
      case data
      when Hash
        result = data
      else
        result = {}
      end
    end
    return result
  end

  # Ensure a data object is a string.
  #
  # If data is given and it is not a string, the data.to_s method is called to
  # get the rendered string.
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data to ensure string
  #   - [String] *default*  Default value if no data is given (nil)
  #
  # * *Returns*
  #   - [String]  Returns a string
  #
  # * *Errors*
  #
  # See also:
  # - ::filter (switch)
  # - ::array
  # - ::hash
  # - ::symbol
  # - ::test
  #
  def self.string(data, default = '')
    result = default
    if data
      case data
      when String
        result = data
      else
        result = data.to_s
      end
    end
    return result
  end

  # Ensure a data object is a symbol.
  #
  # If data is given and it is not a symbol, the data.to_sym method is called to
  # get the generated symbol.  If data is not a string or symbol, it's class name
  # is symbolized.
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data to ensure symbol
  #   - [Symbol] *default*  Default value if no data is given (:undefined)
  #
  # * *Returns*
  #   - [Symbol]  Returns a symbol
  #
  # * *Errors*
  #
  # See also:
  # - ::filter (switch)
  # - ::array
  # - ::hash
  # - ::string
  # - ::test
  #
  def self.symbol(data, default = :undefined)
    result = default
    if data
      case data
      when TrueClass, FalseClass
        result = data ? :true : :false
      when Symbol
        result = data
      when String
        result = data.to_sym
      else
        result = data.class.to_sym
      end
    end
    return result
  end

  # Test a data object for emptiness and return boolean result.
  #
  # Uses the ::empty? method to check for emptiness.
  #
  # * *Parameters*
  #   - [ANY] *data*  Ruby data to test for emptiness
  #
  # * *Returns*
  #   - [Boolean]  Returns true if data not empty, false otherwise
  #
  # * *Errors*
  #
  # See also:
  # - ::filter (switch)
  # - ::array
  # - ::hash
  # - ::string
  # - ::symbol
  #
  def self.test(data)
    return false if Util::Data.empty?(data)
    return true
  end

  #*****************************************************************************
  # Transformation

  # Clean nil or empty values out of a hash object.
  #
  # * *Parameters*
  #   - [Hash] *data*  Ruby data to clean properties
  #   - [Boolean] *remove_empty*  Whether or not to remove empty values or just nil
  #
  # * *Returns*
  #   - [Hash]  Returns hash with all nil or empty values scrubbed (depending on *remove_empty*)
  #
  # * *Errors*
  #
  # See also:
  # - ::deep_clean (recursive clean)
  #
  def self.clean(data, remove_empty = true)
    data.keys.each do |key|
      obj = data[key]
      data.delete(key) if obj.nil? || ( remove_empty && obj.is_a?(Hash) && obj.empty? )
    end
    data
  end

  # Recursively clean nil or empty values out of a hash object.
  #
  # * *Parameters*
  #   - [Hash] *data*  Ruby data to clean properties
  #   - [Boolean] *remove_empty*  Whether or not to remove empty values or just nil
  #
  # * *Returns*
  #   - [Hash]  Returns hash with all nil or empty values scrubbed (depending on *remove_empty*)
  #
  # * *Errors*
  #
  # See also:
  # - ::clean (shallow clean)
  #
  def self.deep_clean(data, remove_empty = true)
    data.keys.each do |key|
      obj = data[key]

      if obj.nil? || ( remove_empty && obj.is_a?(Hash) && obj.empty? )
        data.delete(key)

      elsif data[key].is_a?(Hash)
        deep_clean(data[key], remove_empty)
      end
    end
    data
  end

  # Merge data objects together.
  #
  # This method relies on the merging capabilities of the deep_merge gem. It
  # switches between core Ruby shallow merge and deep_merge merges based on
  # the *basic* boolean.
  #
  # Elements at the end of the array override values for data at the beginning.
  #
  # * *Parameters*
  #   - [Array<nil, String, Symbol, Array, Hash>] *data*  Ruby data objects to merge
  #   - [Boolean] *force*  Whether or not to force override of values where types don't match
  #   - [Boolean] *basic*  Whether or not to perform a basic merge or deep (recursive) merge
  #
  # * *Returns*
  #   - [nil, String, Symbol, Array, Hash]  Returns merged data object
  #
  # * *Errors*
  #
  # See also:
  # - ::undef?
  #
  def self.merge(data, force = true, basic = true)
    value = data

    # Special case because this method is called from within Config.new so we
    # can not use Config.ensure, as that would cause an infinite loop.
    if force.is_a?(Nucleon::Config)
      basic = force.get(:basic, true)
      force = force.get(:force, true)
    end

    if data.is_a?(Array)
      value = undef?(data[0]) ? nil : data.shift.clone

      data.each do |item|
        item = undef?(item) ? nil : item.clone

        case value
        when Hash
          if basic
            if item.is_a?(Hash)
              value = value.merge(item)
            elsif force
              value = item
            end
          else
            begin
              require 'deep_merge'
              value = force ? value.deep_merge!(item) : value.deep_merge(item)

            rescue LoadError
              if item.is_a?(Hash) # Non recursive top level by default.
                value = value.merge(item)
              elsif force
                value = item
              end
            end
          end
        when Array
          if item.is_a?(Array)
            value = value.concat(item).uniq
          elsif force
            value = item
          end

        else
          value = item if force || item.is_a?(String) || item.is_a?(Symbol)
        end
      end
    end
    return value
  end

  # Interpolate values into data objects based on patterns.
  #
  # This method interpolates values into either a single string or a hash of
  # strings that are recursively processed.
  #
  # This method requires our Hash#search method defined in the mod folder.
  #
  # * *Parameters*
  #   - [String, Hash] *value*  Value to interpolate properties into
  #   - [Hash] *scope*  Property values for text replacements
  #   - [Hash] *options*  Method options
  #     - [String] *:pattern*  Regexp pattern to match intepolated properties against
  #     - [Integer] *:var_group*  Regexp group match for property name
  #     - [String] *:flags*  Optional Regexp flags
  #
  # * *Returns*
  #   - [String, Hash]  Returns interpolated string or hash of strings
  #
  # * *Errors*
  #
  # See also:
  # - Hash#search
  #
  def self.interpolate(value, scope, options = {})

    pattern = ( options.has_key?(:pattern) ? options[:pattern] : '\$(\{)?([a-zA-Z0-9\_\-]+)(\})?' )
    group   = ( options.has_key?(:var_group) ? options[:var_group] : 2 )
    flags   = ( options.has_key?(:flags) ? options[:flags] : '' )

    if scope.is_a?(Hash)
      regexp = Regexp.new(pattern, flags.split(''))

      replace = lambda do |item|
        matches = item.match(regexp)
        result  = nil

        unless matches.nil?
          replacement = scope.search(matches[group], options)
          result      = item.gsub(matches[0], replacement) unless replacement.nil?
        end
        return result
      end

      case value
      when String
        while (temp = replace.call(value))
          value = temp
        end

      when Hash
        value.each do |key, data|
          value[key] = interpolate(data, scope, options)
        end
      end
    end
    return value
  end

  # Remove keys from a given hash.
  #
  # This method first symbolizes all keys of the hash and then deletes any
  # matching elements if the *symbolize* option is given.
  #
  # * *Parameters*
  #   - [Hash] *data*  Ruby hash to remove keys from
  #   - [String, Symbol, Array] *keys*  Keys to remove from
  #   - [Boolean] *symbolize*  Whether or not to symbolize data keys before removal
  #
  # * *Returns*
  #   - [Hash]  Returns cleaned data object
  #
  # * *Errors*
  #
  # See also:
  # - ::hash
  # - ::symbol_map
  #
  def self.rm_keys(data, keys, symbolize = false)
    keys = [ keys ] unless keys.is_a?(Array)
    data = hash(data)
    data = symbol_map(data) if symbolize

    keys.each do |key|
      key = key.to_sym if symbolize
      data.delete(key)
    end
    data
  end

  # Select specific keys from a given hash.
  #
  # This method first symbolizes all keys of the hash and then deletes any
  # matching elements if the *symbolize* option is given.
  #
  # * *Parameters*
  #   - [Hash] *data*  Ruby hash to select keys from
  #   - [String, Symbol, Array] *keys*  Keys to select
  #   - [Boolean] *symbolize*  Whether or not to symbolize data keys before selection
  #
  # * *Returns*
  #   - [Hash]  Returns data object with selected keys
  #
  # * *Errors*
  #
  # See also:
  # - ::hash
  # - ::symbol_map
  #
  def self.subset(data, keys, symbolize = false)
    keys     = [ keys ] unless keys.is_a?(Array)
    data     = hash(data)
    data     = symbol_map(data) if symbolize
    new_data = {}

    keys.each do |key|
      key           = key.to_sym if symbolize
      new_data[key] = data[key] if data.has_key?(key)
    end
    new_data
  end

  #*****************************************************************************
  # Utilities

  # Prefix every element in data with prefix separated by pad.
  #
  # This method basically just does bulk prefixing.  This has come in useful in
  # quite a few applications, particularly with dealing with configurations.
  #
  # This method can recursively set prefixes for hash keys as well.
  #
  # * *Parameters*
  #   - [String] *prefix*  Prefix string to prepend to data elements
  #   - [String, Symbol, Array, Hash] *data*  Data elements to prefix
  #   - [String] *pad*  Whether or not to symbolize data keys before selection
  #
  # * *Returns*
  #   - [String, Symbol, Array, Hash]  Returns prefixed data object
  #
  # * *Errors*
  #
  # See also:
  # - ::empty?
  #
  def self.prefix(prefix, data, pad = '_')
    result = nil

    unless prefix.is_a?(Symbol) || ( prefix.is_a?(String) && ! empty?(prefix) )
      prefix = ''
    end
    prefix = prefix.to_s

    case data
    when String, Symbol
      result = ( prefix.empty? ? data.to_s : prefix + pad + data.to_s )

    when Array
      result = []
      data.each do |value|
        result << prefix(prefix, value, pad)
      end

    when Hash
      result = {}
      data.each do |key, value|
        result[prefix(prefix, key, pad)] = value
      end
    end
    return result
  end

  # Ensure a value is set one way or another depending on a test condition.
  #
  # * *Parameters*
  #   - [Boolean] *test*  Test for success / failure
  #   - [ANY] *success_value*  Value returned if test is not empty
  #   - [ANY] *failure_value*  Value returned if test is empty
  #
  # * *Returns*
  #   - [ANY]  Success or failure values depending on the outcome of test
  #
  # * *Errors*
  #
  # See also:
  # - ::empty?
  #
  def self.ensure(test, success_value = nil, failure_value = nil)
    success_value = (success_value ? success_value : test)
    failure_value = (failure_value ? failure_value : nil)

    if empty?(test)
      value = failure_value
    else
      value = success_value
    end
    return value
  end

  # Return value if not empty or else return failure value.
  #
  # * *Parameters*
  #   - [ANY] *value*  Test for success / failure
  #   - [ANY] *failure_value*  Value returned if value is empty
  #
  # * *Returns*
  #   - [ANY]  Value or failure value depending on the emptiness of value
  #
  # * *Errors*
  #
  # See:
  # - ::ensure
  #
  def self.ensure_value(value, failure_value = nil)
    return self.ensure(value, nil, failure_value)
  end
end
end
end
