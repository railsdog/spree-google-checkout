Deface::Override.new(
  :virtual_path => "spree/orders/edit",
  :name => "google_checkout_outside_cart_form",
  :insert_bottom => '[data-hook="outside_cart_form"]',
  :partial => "spree/shared/google_checkout_bar",
  :disabled => false)


Deface::Override.new(
  :virtual_path => "spree/admin/orders/index",
  :name => "google_checkout_admin_orders_index_headers",
  :insert_bottom => "[data-hook='admin_orders_index_headers'], #admin_orders_index_headers[data-hook]",
  :text => "<th><%= t(:google_checkout_status) %></th>",
  :disabled => false)

Deface::Override.new(
  :virtual_path => "spree/admin/orders/index",
  :name => "google_checkout_admin_orders_index_rows",
  :insert_bottom => "[data-hook='admin_orders_index_rows'], #admin_orders_index_rows[data-hook]",
  :partial => "spree/admin/shared/google_checkout_status",
  :disabled => false)

