# frozen_string_literal: true

require_dependency "push_bullet"
require_dependency "momo_market_api"

class MomoBoxSaleTxJob < ApplicationJob
  queue_as :default

  LOW_PRICE_THRESHOLD = ENV['MOMO_BOX_LOW_PRICE'].to_i
  MAX_PAGES = 50
  LAST_PUSH_KEY = "momo_box_sale_tx_job:last_push".freeze
  PUSH_COOLDOWN = 3600 # in seconds

  def perform(max_pages: nil)
    attrs = MomoBoxSaleTx.attribute_names.dup
    attrs.delete("id")

    list = []
    i = 0
    max_pages = max_pages || MAX_PAGES
    loop do
      res = MomoMarketApi.logs_box_tx(page: (i += 1))
      res_list = res["list"]
      list += res_list
      break if i >= max_pages || tx_exists?(txs: res_list.pluck("tx"))

      sleep rand(1..5)
    end

    now = Time.now
    insert_data = list.reverse.map do |listing|
      listing.select! { |k, _| attrs.include?(k.underscore) }
      data = listing.each_with_object({}) { |(k, v), h| h[k.underscore] = v }
      data.merge({
        "crtime" => Time.at(listing["crtime"]),
        "payload" => listing,
        "created_at" => now,
        "updated_at" => now
      })
    end
    prices = MomoBoxSaleTx
      .insert_all(insert_data, returning: %i[price]).rows.flatten

    if prices.count > 0
      lowest_price = prices.min
      if low_price?(lowest_price) && !pending_push_cooldown?
        push_notification "Momo BOX <= #{LOW_PRICE_THRESHOLD}: $#{lowest_price}"
      end
    end
  end

  private

  def tx_exists?(txs:)
    MomoBoxSaleTx.where(tx: txs).exists?
  end

  def low_price?(price)
    price/(10**9) <= LOW_PRICE_THRESHOLD
  end

  def pending_push_cooldown?
    last_push = Integer(REDIS.get(LAST_PUSH_KEY) || 0)
    (now.to_i - last_push) < PUSH_COOLDOWN
  end

  def push_notification(message)
    REDIS.set LAST_PUSH_KEY, now.to_i
    PushBullet.create_push(body: message)
  end
end
