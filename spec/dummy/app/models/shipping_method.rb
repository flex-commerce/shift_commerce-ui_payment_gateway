class ShippingMethod
  extend ActiveModel::Model
  attr_accessor :id, :label, :price, :description, :tax

  def initialize(attrs)
    attrs.each do |attr, value|
      send("#{attr}=", value)
    end
  end

  def self.all
    [new(default_attributes)]
  end


  def self.default_attributes
    { label: "free", price: 0.0, description: "Free Shipping", tax: 0.0 }
  end
end