defmodule ReWeb.Resolvers.Units do
  @moduledoc """
  Resolver module for units
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Developments,
    Units
  }

  def insert(%{input: unit_params}, %{context: %{current_user: _current_user}}) do
    with :ok <- :ok,
         # with :ok <- Bodyguard.permit(Units, :create_unit, current_user, unit_params),
         {:ok, development} <- get_development(unit_params),
         {:ok, new_unit} <- Units.insert(unit_params, development) do
      {:ok, new_unit}
    else
      {:error, _, error, _} -> {:error, error}
      error -> error
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
end
