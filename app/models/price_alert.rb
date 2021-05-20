class PriceAlert < ApplicationRecord
  require_dependency 'live_coin_watch'

  enum condition: %i[gte lte]
  validates_presence_of %i[coin currency price condition]
  after_validation :format_codes

  def alert?
    case condition
    when :gte
      current_price >= price
    when :lte
      current_price <= price
    else
      false
    end
  end

  def current_price
    res = LiveCoinWatch.coins_single(coin, currency)
    res['rate'].to_f
  end

  private

    def format_codes
      coin.upcase!
      currency.upcase!
    end
end
