class LineItem
  extend ActiveModel::Model
  attr_accessor :title, :unit_quantity, :container_id, :item_type, :item_id, :unit_price, :tracking_url, :order_status, :taxes

  def initialize(attrs = {})
    default_attrs.merge(attrs).each do |attr, value|
      send("#{attr}=", value)
    end
  end

  def total
    unit_price * unit_quantity
  end

  private
  def default_attrs
    {
      title: "Line Item Title",
      unit_quantity: 2,
      unit_price: 2.00,
      taxes: 0.12
    }
  end

end