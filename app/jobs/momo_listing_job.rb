# frozen_string_literal: true

require_dependency "push_bullet"
require_dependency "momo_market_api"

class MomoListingJob < ApplicationJob
  queue_as :default

  LOW_PRICE_THRESHOLD = ENV['MOMO_LOW_PRICE'].to_i
  MAX_PAGES = 10
  LAST_PUSH_KEY = "momo_listing_job:last_push".freeze
  PUSH_COOLDOWN = 3600 # in seconds

  def perform(max_pages: nil)
    attrs = MomoListing.attribute_names.dup
    attrs.delete("id")

    list = []
    i = 0
    max_pages = max_pages || MAX_PAGES
    loop do
      res = MomoMarketApi.auction_search(page: (i += 1))
      res_list = res["list"]
      list += res_list
      break if i >= max_pages || id_exists?(raw_ids: res_list.pluck("id"))

      sleep rand(1..5)
    end

    now = Time.now
    insert_data = list.map do |listing|
      listing_data = listing.select { |k, _| attrs.include?(k.underscore) }
      data = listing_data.each_with_object({}) do |(k, v), h|
        h[k.underscore] = v
      end
      data.merge({
        "raw_id" => listing["id"],
        "payload" => listing,
        "created_at" => now,
        "updated_at" => now
      })
    end
    prices = MomoListing
      .insert_all(insert_data, returning: %w[now_price]).rows.flatten

    if prices.count > 0
      low_price = (prices.min)/(10**9)
      last_push = Integer(REDIS.get(LAST_PUSH_KEY) || 0)
      if low_price <= LOW_PRICE_THRESHOLD && (now.to_i - last_push > PUSH_COOLDOWN)
        REDIS.set LAST_PUSH_KEY, now.to_i
        PushBullet.create_push(
          body: "Momo Listing <= #{LOW_PRICE_THRESHOLD}: $#{low_price}"
        )
      end
    end
  end

  private

  def id_exists?(raw_ids:)
    MomoListing.where(raw_id: raw_ids).exists?
  end
end
