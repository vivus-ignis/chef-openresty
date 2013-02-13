actions :create, :delete

def initialize(*args)
  super
  @action = :create
end

attribute :name,               :kind_of => String, :name_attribute => true
attribute :template,           :kind_of => String
attribute :options,            :kind_of => Hash
