module OrdersHelper
  # Badge de statut coloré
  def order_status_badge(order)
    badge_class = case order.status
    when 'pending' then 'bg-secondary'
    when 'paid' then 'bg-success'
    when 'processing' then 'bg-info'
    when 'shipped' then 'bg-primary'
    when 'delivered' then 'bg-success'
    when 'cancelled' then 'bg-danger'
    when 'refunded' then 'bg-warning'
    else 'bg-secondary'
    end

    status_text = order.status.capitalize

    content_tag(:span, status_text, class: "badge #{badge_class}")
  end

  # Icône de statut
  def order_status_icon(order)
    icon_class = case order.status
    when 'pending' then 'fa-clock'
    when 'paid' then 'fa-check-circle'
    when 'processing' then 'fa-box'
    when 'shipped' then 'fa-truck'
    when 'delivered' then 'fa-home'
    when 'cancelled' then 'fa-times-circle'
    when 'refunded' then 'fa-undo'
    else 'fa-question-circle'
    end

    content_tag(:i, '', class: "fas #{icon_class}")
  end

  # Formater le montant
  def format_price(amount)
    number_to_currency(amount, unit: '€', format: '%n %u', precision: 2)
  end
end
