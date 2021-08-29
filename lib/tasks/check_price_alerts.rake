desc "task to check prices and alert if applicable"
task :run_all => :environment do
  puts "Running PriceAlertJob..."
  PriceAlertJob.perform_now
  puts "Done."

  puts "Running MomoListingJob..."
  MomoListingJob.perform_now
  puts "Done."
end
