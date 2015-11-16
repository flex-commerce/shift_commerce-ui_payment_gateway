class Order
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

  def shipping_address
    @shipping_address ||= Address.new name: "shipping name",
                                      address_line_1: "shipping address 1",
                                      address_line_2: "shipping address 2",
                                      address_line_3: "shipping address 3",
                                      city: "shipping address city",
                                      state: "shipping address state",
                                      postcode: "shipping postcode",
                                      country: "GB"
  end

  private

  def self.default_attributes
    { total: 100.0 }
  end
end