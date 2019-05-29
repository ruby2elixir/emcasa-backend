defmodule ReWeb.Resolvers.BuyerLeads do
  @moduledoc """
  Resolver module for seller leads
  """

  def create_budget(_, %{context: %{current_user: nil}}), do: {:error, :unauthorized}
  def create_budget(_, %{context: %{current_user: _}}), do: {:ok, %{message: "ok"}}
end
