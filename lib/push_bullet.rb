class PushBullet
  require 'httparty'

  include HTTParty
  base_uri 'https://api.pushbullet.com'
  headers 'Access-Token' => ENV['PUSHBULLET_ACCESS_TOKEN'],
          'Content-Type' => 'application/json'
  # debug_output $stdout

  def self.create_push(email: , title: 'DeFi Assistant', body: )
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
