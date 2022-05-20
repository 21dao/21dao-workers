namespace :job do
  task cdn: :environment do
    CdnUploadJob.perform_now
  end

  task finalize_exchange: :environment do
    FinalizeExchangeJob.perform_now
  end

  task finalize_formfunction: :environment do
    FinalizeFormfunctionJob.perform_now
  end

  task finalize_holaplex: :environment do
    FinalizeHolaplexJob.perform_now
  end

  task uri: :environment do
    ImageFromUriJob.perform_now
  end

  task update_exchange: :environment do
    UpdateExchangeJob.perform_now
  end

  task update_formfunction: :environment do
    UpdateFormfunctionJob.perform_now
  end

  task update_holaplex: :environment do
    UpdateHolaplexJob.perform_now
  end

  task update_listings: :environment do
    UpdateListingsJob.perform_now
  end
end
