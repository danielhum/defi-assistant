require_dependency "push_bullet"
require_dependency "momo_market_api"

class MomoListingJob < ApplicationJob
  queue_as :default

  LOW_PRICE_THRESHOLD = 750
  NUM_PAGES = 5

  def perform(*args)
    attrs = MomoListing.attribute_names.dup
    attrs.delete("id")
    now = Time.now

    list = []
    NUM_PAGES.times do |i|
      res = MomoMarketApi.auction_search(page: (i + 1))
      list += res["list"]
      sleep rand(1..5)
    end
    insert_data = list.map do |listing|
      listing.select! { |k, _| attrs.include?(k.underscore) }
      data = listing.each_with_object({}) { |(k, v), h| h[k.underscore] = v }
      data.merge({
        "raw_id" => listing["id"],
        "payload" => listing,
        "created_at" => now,
        "updated_at" => now
      })
    end
    prices = MomoListing
      .insert_all(insert_data, returning: %w[now_price]).rows.flatten

    low_price = (prices.min)/(10**9)
    if low_price <= LOW_PRICE_THRESHOLD
      PushBullet.create_push(
        body: "Momo Listing <= #{LOW_PRICE_THRESHOLD}: $#{low_price}"
      )
    end
  end
end
