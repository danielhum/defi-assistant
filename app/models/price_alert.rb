class PriceAlert < ApplicationRecord
  require_dependency 'live_coin_watch'

  validates_presence_of %i[coin currency price]
  after_validation :format_codes

  # returns alert message if alert triggered, else nil
  def alert(current_price)
    self.last_price ||= 0
    return nil if last_price == 0 # first check

    if last_price < price && current_price >= price
      "#{coin_pair} >= #{price}"
    elsif last_price > price && current_price <= price
      "#{coin_pair} <= #{price}"
    else
      nil
    end
  end

  def coin_pair
    "#{coin}/#{currency}"
  end

  def get_current_price
    res = LiveCoinWatch.coins_single(coin, currency)
    res['rate'].to_f
  end

  def update_last_price!(price)
    self.update(last_price: price)
  end

  private

    def format_codes
      coin.upcase!
      currency.upcase!
    end
end
