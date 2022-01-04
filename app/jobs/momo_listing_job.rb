# frozen_string_literal: true

require_dependency "push_bullet"
require_dependency "momo_market_api"

class MomoListingJob < ApplicationJob
  queue_as :default

  LOW_PRICE_THRESHOLD = (ENV['MOMO_LOW_PRICE'] || 3000).to_i
  VERY_LOW_PRICE_THRESHOLD = (ENV['MOMO_VERY_LOW_PRICE'] || 1000).to_i
  MAX_PAGES = 10
  LAST_PUSH_KEY = "momo_listing_job:last_push".freeze
  PUSH_COOLDOWN = 3600 # in seconds
  URGENT_PUSH_COOLDOWN = 180 # in seconds

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
    limit = MomoListing.count - 5000
    if limit.positive?
      MomoListing.order(id: :asc).limit(limit).delete_all
    end
    listings = MomoListing
      .insert_all(insert_data, returning: %w[now_price hashrate]).rows
    return if listings.empty?

    cheap_price =
      listings.map { |l| price_to_dollars(l[0]) }.select do |p|
        low_price?(p, VERY_LOW_PRICE_THRESHOLD)
      end.min

    if cheap_price && should_push?(URGENT_PUSH_COOLDOWN)
      push("Very cheap Momo: $#{cheap_price}")
    end

    good_listings = listings.select { |l| l[1] > 30 } # hashrate > 30
    prices, hashrates =
      good_listings.each_with_object([[], []]) do |(price, hashrate), a|
      a[0] << price_to_dollars(price)
      a[1] << hashrate
    end
    low_price = prices.min

    if low_price && low_price?(low_price) && should_push?(PUSH_COOLDOWN)
      push("Momo Listing <= #{LOW_PRICE_THRESHOLD}: $#{low_price}")
    end
  end

  private

  def id_exists?(raw_ids:)
    MomoListing.where(raw_id: raw_ids).exists?
  end

  def price_to_dollars(price)
    price ? price/(10**9) : nil
  end

  def low_price?(price, threshold = LOW_PRICE_THRESHOLD)
    price <= threshold
  end

  def should_push?(cooldown)
    last_push = Integer(REDIS.get(LAST_PUSH_KEY) || 0)
    Time.now.to_i - last_push > cooldown
  end

  def push(body)
    Rails.logger.info "pushing! #{body}"
    now = Time.now.to_i
    REDIS.set LAST_PUSH_KEY, now
    PushBullet.create_push body: body  
  end
end
