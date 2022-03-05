namespace :auctions do
  task exchange: :environment do
    UpdateExchangeJob.perform_now
  end

  task finalize_exchange: :environment do
    FinalizeExchangeJob.perform_now
  end

  task holaplex: :environment do
    UpdateHolaplexJob.perform_now
  end

  task finalize_holaplex: :environment do
    FinalizeHolaplexJob.perform_now
  end

  task formfunction: :environment do
    UpdateFormfunctionJob.perform_now
  end

  task finalize_formfunction: :environment do
    FinalizeFormfunctionJob.perform_now
  end
end
