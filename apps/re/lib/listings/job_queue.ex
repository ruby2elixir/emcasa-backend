defmodule Re.Listings.JobQueue do
  @moduledoc """
  Module for processing listings asynchronously
  """
  use EctoJob.JobQueue, table_name: "listings_jobs"

  alias Re.{
    Listing,
    PriceSuggestions,
    Repo
  }

  alias Ecto.Multi

  def perform(%Multi{} = multi, %{"type" => "save_price_suggestion", "uuid" => uuid}) do
    listing = Repo.get_by(Listing, uuid: uuid)

    listing
    |> PriceSuggestions.suggest_price()
    |> case do
      {:ok, suggested_price} ->
        changeset = Listing.changeset(listing, %{suggested_price: suggested_price})
        Multi.update(multi, :update_suggested_price, changeset)

      _error ->
        multi
    end
    |> Repo.transaction()
    |> log_error()
  end

  defp log_error({:ok, result}), do: {:ok, result}

  defp log_error(error) do
    Sentry.capture_message("error when performing Listings.JobQueue",
      extra: %{error: error}
    )

    error
  end
end
