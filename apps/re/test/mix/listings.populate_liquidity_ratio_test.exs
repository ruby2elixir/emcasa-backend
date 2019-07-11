defmodule Mix.Tasks.Re.Listings.PopulateLiquidityRatioTest do
  use Re.ModelCase

  alias Mix.Tasks.Re.Listings.PopulateLiquidityRatio

  alias Re.{
    Listing,
    Repo
  }

  setup do
    Mix.shell(Mix.Shell.Process)

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
    end)

    :ok
  end

  describe "run/1" do
    test "update district" do
      %Listing{
        status: "active",
        price: 1_000_000,
        suggested_price: 1_000_000.00
      }
      |> Repo.insert()

      PopulateLiquidityRatio.run(nil)
      listing = Listing |> Repo.one()
      assert listing.liquidity_ratio == 0
    end
  end
end
