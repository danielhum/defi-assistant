require_dependency 'push_bullet'

class PriceAlertWorker
  include Sidekiq::Worker

  PUSHBULLET_ACCOUNT_EMAIL=ENV['PUSHBULLET_ACCOUNT_EMAIL'].freeze
  
  def perform(*args)
    pairs = PriceAlert.select('DISTINCT ON (coin) coin, currency')
                      .map{ |p| [p.coin, p.currency] }
    prices = pairs.inject({}) do |h, pair|
      h[pair] = PriceAlert.new(coin: pair[0], currency: pair[1]).get_current_price
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
