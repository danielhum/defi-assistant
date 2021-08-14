class PushBullet
  require 'httparty'

  include HTTParty
  base_uri 'https://api.pushbullet.com'
  headers 'Access-Token' => ENV['PUSHBULLET_ACCESS_TOKEN'],
          'Content-Type' => 'application/json'
  # debug_output $stdout

  PUSHBULLET_ACCOUNT_EMAIL=ENV['PUSHBULLET_ACCOUNT_EMAIL'].freeze

  def self.create_push(
    email: PUSHBULLET_ACCOUNT_EMAIL, title: 'DeFi Assistant', body: 
  )
    post("/v2/pushes",
      body: {
        email: email,
        type: :note,
        title: title,
        body: body
      }.to_json
    )
  end
end
