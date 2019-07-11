defmodule Mix.Tasks.Re.Listings.PopulateLiquidityRatio do
  @moduledoc """
  Insert liquidity ratio to all active listings.
  """
  use Mix.Task

  require Logger

  alias Re.{
    Listing,
    Listings.Liquidity,
    Repo
  }

  alias Ecto.Changeset
  import Ecto.Query

  @shortdoc "Set liquidity ratio to all active listings"

  def run(_) do
    Mix.Task.run("app.start")

    listings = Repo.all(from(l in Listing, where: l.status == ^"active"))

    Enum.each(listings, fn listing ->
      listing
      |> Changeset.change(liquidity_ratio: calculate_liquidity_ratio(listing))
      |> Repo.update()
      |> case do
        {:error, error} ->
          Mix.shell().info(
            "Failed to add liquidity ratio to listing #{listing.id}, error: #{error}"
          )

        {:ok, _} ->
          nil
      end
    end)
  end

  defp calculate_liquidity_ratio(%Listing{price: price, suggested_price: suggested_price}) do
    Liquidity.calculate(price, suggested_price)
  end
end
