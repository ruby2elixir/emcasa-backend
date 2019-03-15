defmodule ReWeb.Resolvers.Units do
  @moduledoc """
  Resolver module for units
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Re.{
    Units
  }

  def per_listing(listing, _params, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(Units, :units, listing)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, Units, :units, listing)}
    end)
  end
end
