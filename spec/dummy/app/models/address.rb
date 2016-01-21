class Address
  extend ActiveModel::Model
  attr_accessor :id, :first_name, :middle_names, :last_name, :address_line_1, :address_line_2, :address_line_3, :city, :state, :postcode, :country, :preferred_billing, :preferred_shipping
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
    { first_name: "first", last_name: "last", middle_names: "middle", address_line_1: "address line 1", country: "GB" }
  end

end