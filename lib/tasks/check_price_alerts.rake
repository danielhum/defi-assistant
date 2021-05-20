desc "task to check prices and alert if applicable"
task :check_price_alerts => :environment do
  puts "Checking prices..."
  PriceAlertWorker.new.perform
  puts "Done."
end
