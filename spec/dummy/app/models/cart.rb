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

  def shipping_address_id=(value)
    #stub
  end

  def billing_address_id=(value)
    #stub
  end
  def shipping_address
    return nil if ENV['NO_SHIPPING_ADDRESS']
    @shipping_address ||= Address.new first_name: "first",
                                      middle_names: "middle",
                                      last_name: "last",
                                      address_line_1: "shipping address 1",
                                      address_line_2: "shipping address 2",
                                      address_line_3: "shipping address 3",
                                      city: "shipping address city",
                                      state: "shipping address state",
                                      postcode: "shipping postcode",
                                      country: "GB"
  end
  def shipping_method
    nil
  end

  def tax
    0.0
  end

  def line_items
    @line_items ||= build_line_items
  end

  def total
    line_items.map(&:total).sum
  end

  def shipping_total
    0.0
  end

  def email
    nil
  end

  def email=(value)

  end

  def save!
    true
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
    { total: 100.0 }
  end
end