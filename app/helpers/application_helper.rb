module ApplicationHelper
  def service_price(service)
    if service.price_from_cents == service.price_to_cents
      "#{service.price_from_cents / 100} ₽"
    else
      "#{service.price_from_cents / 100}–#{service.price_to_cents / 100} ₽"
    end
  end
end
