class Order
  extend ActiveModel::Model
  attr_accessor :id, :total, :cart_id, :transaction_attributes, :order_ip_address
  def self.find(id)
    new(default_attributes)
  end

  def initialize(attrs)
    attrs.each do |attr, value|
      send("#{attr}=", value)
    end
  end

  def self.create(attrs={})
    new(default_attributes.merge(attrs))
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

  def line_items
    @line_items ||= build_line_items
  end

  def total
    line_items.map(&:total).sum
  end

  private

  def build_line_items
    results = []
    10.times do |idx|
      results << LineItem.new(title: "Line item #{idx} name")
    end
    results
  end

  def self.default_attributes
    { total: 100.0, id: 1 }
  end
end