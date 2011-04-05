class SpreeGoogleCheckoutHooks < Spree::ThemeSupport::HookListener
  insert_after :outside_cart_form, 'shared/google_checkout_bar'
  
  insert_after :admin_orders_index_headers do
    %(
      <% if Billing::GoogleCheckout.current -%>
      <th><%= t(:google_checkout_status) %></th>
      <% end -%>
    )
  end
  
  insert_after :admin_orders_index_rows, 'admin/shared/google_checkout_status'
end
