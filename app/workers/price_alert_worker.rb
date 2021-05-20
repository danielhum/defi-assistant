require_dependency 'push_bullet'

class PriceAlertWorker
  include Sidekiq::Worker

  PUSHBULLET_ACCOUNT_EMAIL=ENV['PUSHBULLET_ACCOUNT_EMAIL'].freeze
  
  def perform(*args)
    PriceAlert.find_each do |price_alert|
      price = price_alert.get_current_price
      alert = price_alert.alert(price)
      PushBullet.create_push(email: PUSHBULLET_ACCOUNT_EMAIL, body: alert) if alert
      price_alert.update_last_price!(price)
    end
  end
end
