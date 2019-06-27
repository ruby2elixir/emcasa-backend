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

  alias Ecto.{
    Changeset,
    Multi
  }

  def perform(%Multi{} = multi, %{"type" => "save_price_suggestion", "uuid" => uuid}) do
    listing = Repo.get_by(Listing, uuid: uuid)

    listing
    |> PriceSuggestions.suggest_price()
    |> case do
      {:ok, suggested_price} ->
        changeset = Listing.changeset(listing, %{suggested_price: suggested_price})

        multi
        |> Multi.update(:update_suggested_price, changeset)
        |> Repo.transaction()

      {:error, %Changeset{}} ->
        Repo.transaction(multi)

      error ->
        error
    end
    |> handle_error()
  end

  defp handle_error({:ok, result}), do: {:ok, result}

  defp handle_error(error) do
    Sentry.capture_message("error when performing Listings.JobQueue",
      extra: %{error: "#{Kernel.inspect(error)}"}
    )

    raise "Error when performing Listings.JobQueue"
  end
end
