class Devise::Oauth2Providable::Scope
  attr_reader :raw_attributes
  attr_reader :name

  extend Enumerable # I know, right?
  def self.each
    scopes.values.each { |s| yield s }
  end

  def self.[](key)
    scopes[key]
  end

  # TODO: Automate creation of the YAML for Scopes
  def self.file
    @file ||= Rails.root.join 'config', 'scopes.yml'
  end

  # TODO Switch name back to hash if we change the file to
  # associate more than a "name"
  def self.file_as_list
    @file_as_list ||= YAML.load_file file
  end

  def self.names
    scopes.keys
  end

  def self.names_for_enum
    names.collect { |name| [name, name.to_s.downcase.underscore] }
  end

  def self.scopes
    @scopes ||= file_as_list.inject({}.with_indifferent_access) do |hash, name|
      hash[name] = new(name: name)
      hash
    end
  end

  def self.all
    scopes.values
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
