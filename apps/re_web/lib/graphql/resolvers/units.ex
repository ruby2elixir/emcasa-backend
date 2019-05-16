defmodule ReWeb.Resolvers.Units do
  @moduledoc """
  Resolver module for units
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Developments,
    Listings,
    Units
  }

  def insert(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Units, :create_unit, current_user, params),
         {:ok, development} <- get_development(params),
         {:ok, listing} <- get_listing(params),
         {:ok, %{add_unit: new_unit}} <- Units.insert(params, development, listing) do
      {:ok, new_unit}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
    end
  end

  def update(%{uuid: uuid, input: params}, %{
        context: %{current_user: current_user}
      }) do
    with :ok <- Bodyguard.permit(Units, :update_unit, current_user, params),
         {:ok, unit} <- Units.get(uuid),
         {:ok, development} <- get_development(params),
         {:ok, listing} <- get_listing(params),
         {:ok, new_unit} <- Units.update(unit, params, development, listing) do
      {:ok, new_unit}
    end
  end

  def per_listing(listing, _params, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Units, :units, listing)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, Units, :units, listing)}
    end)
  end

  defp get_development(%{development_uuid: uuid}), do: Developments.get(uuid)
  defp get_development(_), do: {:error, :bad_request}

  defp get_listing(%{listing_id: id}), do: Listings.get(id)
  defp get_listing(_), do: {:error, :bad_request}
end
