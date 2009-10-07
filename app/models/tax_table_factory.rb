class TaxTableFactory
  def effective_tax_tables_at(time)
    # Tax table 1 will be used before Apr 09 2008
    #if time < "Wed Apr 09 08:56:03 CDT 2008".to_time then
	 if time < Time.now  
      table1 = Google4R::Checkout::TaxTable.new(false)
      table1.name = "Default Tax Table"
#      table1.create_rule do |rule|
#        # Set California tax to 8%
#        rule.area = Google4R::Checkout::UsStateArea.new("CA")
#        rule.rate = 0.08
#      end
      [ table1 ]
    else
      table2 = TaxTable.new
      # ... set rules
      [ table2 ]
    end
  end
end