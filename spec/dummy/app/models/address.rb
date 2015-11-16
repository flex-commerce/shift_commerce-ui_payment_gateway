class Address
  extend ActiveModel::Model
  attr_accessor :id, :name, :address_line_1, :address_line_2, :address_line_3, :city, :state, :postcode, :country, :preferred_billing, :preferred_shipping
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
    { name: "address name", address_line_1: "address line 1", country: "GB" }
  end

end