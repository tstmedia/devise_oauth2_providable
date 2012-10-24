class Devise::Oauth2Providable::Scope
  attr_reader :raw_attributes
  attr_reader :name
  attr_reader :description

  extend Enumerable # I know, right?
  def self.each
    scopes.values.each { |s| yield s }
  end

  def self.[](*keys)
    final = keys.collect { |key| scopes[key] }.compact
    final.length < 2 ? final.first : final
  end

  # TODO: Automate creation of the YAML for Scopes
  def self.file
    @file ||= Rails.root.join 'config', 'scopes.yml'
  end

  # TODO Switch name back to hash if we change the file to
  # associate more than a "name"
  def self.file_as_hash
    @file_as_hash ||= YAML.load_file file
  end

  def self.names
    scopes.keys
  end

  def self.names_for_enum
    names.collect { |name| [name, name.to_s.downcase.underscore] }
  end

  def self.scopes
    @scopes ||= file_as_hash.inject({}.with_indifferent_access) do |hash, list|
      name = list[0]
      options = { name: name }.merge(list[1])
      hash[name] = new(options)
      hash
    end
  end

  def self.all
    scopes.values
  end

  def self.find_from_comma_delimiter(string)
    string.is_a?(String) ? self.[](*string.split(",")) : []
  end

  def <=>(other)
    raise ArgumentError, "Must be a Scope" unless other.is_a? Scope
    name <=> other.name
  end

  def initialize(attributes = {})
    @raw_attributes = attributes
    attributes.each do |key, value|
      instance_variable_set("@#{key}", value) if respond_to? key
    end
  end
end
