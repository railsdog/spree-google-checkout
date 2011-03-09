Order.class_eval do
  def restock_inventory
    inventory_units.each do |inventory_unit|
      inventory_unit.restock!
    end
  end
end
