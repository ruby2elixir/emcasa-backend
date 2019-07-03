defmodule Re.Repo.Migrations.AddPricetellerFieldsToPriceRequests do
  use Ecto.Migration

  def change do
    alter table(:price_suggestion_requests) do
      add :listing_price_rounded, :float
      add :listing_price_error_q90_min, :float
      add :listing_price_error_q90_max, :float
      add :listing_price_per_sqr_meter, :float
      add :listing_average_price_per_sqr_meter, :float
    end
  end
end
