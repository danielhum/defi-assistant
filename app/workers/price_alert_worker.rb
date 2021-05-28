require_dependency 'push_bullet'

class PriceAlertWorker
  include Sidekiq::Worker

  PUSHBULLET_ACCOUNT_EMAIL=ENV['PUSHBULLET_ACCOUNT_EMAIL'].freeze
  
  def perform(*args)
    price_alerts = PriceAlert.select(:coin, :currency)
                             .group(:coin, :currency)
    prices = price_alerts.inject({}) do |h, p|
      h[[p.coin, p.currency]] = p.get_current_price
      h
    end

    PriceAlert.find_each do |price_alert|
      price = prices[[price_alert.coin, price_alert.currency]]
      alert = price_alert.alert(price)
      PushBullet.create_push(email: PUSHBULLET_ACCOUNT_EMAIL, body: alert) if alert
      price_alert.update_last_price!(price)
    end
  end
end
