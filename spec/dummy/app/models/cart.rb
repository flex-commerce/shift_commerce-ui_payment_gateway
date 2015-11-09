class Cart
  extend ActiveModel::Model
  attr_accessor :id, :total
  def self.find(id)
    new(default_attributes)
  end

  def initialize(attrs)
    attrs.each do |attr, value|
      send("#{attr}=", value)
    end
  end
  private

  def self.default_attributes
    { total: 100.0 }
  end
end