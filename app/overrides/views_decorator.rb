Deface::Override.new(
  :virtual_path => "orders/edit",
  :name => "google_checkout_outside_cart_form",
  :insert_after => "[data-hook='outside_cart_form'], #outside_cart_form[data-hook]",
  :partial => "shared/google_checkout_bar",
  :disabled => false)


Deface::Override.new(
  :virtual_path => "admin/orders/index",
  :name => "google_checkout_admin_orders_index_headers",
  :insert_bottom => "[data-hook='admin_orders_index_headers'], #admin_orders_index_headers[data-hook]",
  :text => "<th><%= t(:google_checkout_status) %></th>",
  :disabled => false)

Deface::Override.new(
  :virtual_path => "admin/orders/index",
  :name => "google_checkout_admin_orders_index_rows",
  :insert_bottom => "[data-hook='admin_orders_index_rows'], #admin_orders_index_rows[data-hook]",
  :partial => "admin/shared/google_checkout_status",
  :disabled => false)

