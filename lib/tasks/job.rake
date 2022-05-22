namespace :job do
  task cdn: :environment do
    CdnUploadJob.delay(run_at: 1.seconds.from_now).perform_later
  end

  task finalize_exchange: :environment do
    FinalizeExchangeJob.delay(run_at: 10.seconds.from_now).perform_later
  end

  task finalize_formfunction: :environment do
    FinalizeFormfunctionJob.delay(run_at: 20.seconds.from_now).perform_later
  end

  task finalize_holaplex: :environment do
    FinalizeHolaplexJob.delay(run_at: 30.seconds.from_now).perform_later
  end

  task uri: :environment do
    ImageFromUriJob.delay(run_at: 40.seconds.from_now).perform_later
  end

  task update_exchange: :environment do
    UpdateExchangeJob.delay(run_at: 50.seconds.from_now).perform_later
  end

  task update_formfunction: :environment do
    UpdateFormfunctionJob.delay(run_at: 60.seconds.from_now).perform_later
  end

  task update_holaplex: :environment do
    UpdateHolaplexJob.delay(run_at: 70.seconds.from_now).perform_later
  end

  task update_listings: :environment do
    UpdateListingsJob.delay(run_at: 80.seconds.from_now).perform_later
  end
end
