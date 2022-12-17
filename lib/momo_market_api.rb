class MomoMarketApi
  require 'httparty'

  include HTTParty
  base_uri 'https://nftapi.bitsplus.cn'
  headers 'accept' => 'application/json, text/plain, */*',
          'origin' => 'https://www.mobox.io',
          'referer' => 'https://www.mobox.io/',
          'sec-fetch-dest' => 'empty',
          'sec-fetch-mode' => 'cors',
          'sec-fetch-site' => 'cross-site',
          'sec-gpc' => '1',
          'user-agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '\
            'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36'
          
  # debug_output $stdout

  # type: 5 - Epic, 4 - Rare
  def self.auction_search(page: 1, type: 5)
    # call full URL to match browser request
    get("/auction/search/BNB?page=#{page}&limit=15&"\
      "category=&vType=#{type}&sort=-time&pType=")
  end

  def self.logs_box_tx(page: 1)
    get("/gem_auction/logs?&page=#{page}&limit=50&filter=2")
  end
end
