defmodule ReWeb.Resolvers.Interests do
  @moduledoc """
  Resolver module for interests queries and mutations
  """
  alias Re.Interests

  def request_contact(params, %{context: %{current_user: current_user}}) do
    Interests.request_contact(params, current_user)
  end

  def request_price_suggestion(params, %{context: %{current_user: current_user}}) do
    case Interests.request_price_suggestion(params, current_user) do
      {:ok, request, {:ok, suggested_price}} ->
        {:ok, Map.put(request, :suggested_price, suggested_price)}

      {:ok, request, {:error, :street_not_covered}} ->
        {:ok, Map.put(request, :suggested_price, nil)}

      error ->
        error
    end
  end
end
