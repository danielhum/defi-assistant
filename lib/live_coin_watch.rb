class LiveCoinWatch
  require 'httparty'

  include HTTParty
  base_uri 'https://api.livecoinwatch.com'
  headers 'x-api-key' => ENV['LIVECOINWATCH_API_KEY'],
          'Content-Type' => 'application/json'
  # debug_output $stdout

  def self.coins_single(code, currency=:USD, meta=false)
    post("/coins/single",
      body: {
        code: code.upcase,
        currency: currency.upcase,
        meta: meta
      }.to_json
    )
  end
end
