defmodule ReWeb.GraphQL.Middlewares.Visualizations do
  @moduledoc """
  Module for registering listing visualizations
  """
  @behaviour Absinthe.Middleware

  @visualizations Application.get_env(:re, :visualizations, ReStatistics.Visualizations)

  def call(%{value: nil} = res, _arg), do: res

  def call(%{value: listing, context: %{current_user: user, details: details}} = res, _arg) do
    @visualizations.listing(listing, user, details)

    res
  end
end
