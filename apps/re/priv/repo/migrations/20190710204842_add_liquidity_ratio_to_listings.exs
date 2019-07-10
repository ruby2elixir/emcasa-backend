defmodule Re.Repo.Migrations.AddLiquidityRatioToListings do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :liquidity_ratio, :float
    end
  end
end
