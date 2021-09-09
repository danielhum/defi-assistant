# frozen_string_literal: true

class HerokuDbMaintenance < ApplicationJob
  queue_as :default
  MAX_ROWS = 9000

  def perform
    count = MomoListing.count + MomoBoxSaleTx.count
    if count >= MAX_ROWS
      deleted = 0
      [MomoBoxSaleTx, MomoListing].each do |rel|
        deleted += rel.where("created_at < ?", 10.days.ago).delete_all
      end
      puts "#{self.class.name} deleted #{deleted} rows."
    else
      puts "#{self.class.name} #{count} rows, no need to clear."
    end
  end
end
