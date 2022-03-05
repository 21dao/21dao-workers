namespace :start do
  task all_jobs: :environment do
    UpdateExchangeJob.delay(run_at: 5.seconds.from_now).perform_later
    UpdateHolaplexJob.delay(run_at: 10.seconds.from_now).perform_later
    UpdateFormfunctionJob.delay(run_at: 20.seconds.from_now).perform_later

    ImageFromUriJob.delay(run_at: 30.seconds.from_now).perform_later

    FinalizeExchangeJob.delay(run_at: 1.minute.from_now).perform_later
    FinalizeHolaplexJob.delay(run_at: 90.seconds.from_now).perform_later
    FinalizeFormfunctionJob.delay(run_at: 2.minutes.from_now).perform_later
  end
end
