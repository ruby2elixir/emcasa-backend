defmodule ReWeb.Resolvers.BuyerLeads do
  @moduledoc """
  Resolver module for buyer leads
  """
  alias Re.BuyerLeads

  def create_budget(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(BuyerLeads, :create_buyer_lead, current_user, params),
         {:ok, _} <- BuyerLeads.create_budget(params, current_user) do
      {:ok, %{message: "ok"}}
    end
  end

  def create_empty_search(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(BuyerLeads, :create_buyer_lead, current_user, params),
         {:ok, _} <- BuyerLeads.create_empty_search(params, current_user) do
      {:ok, %{message: "ok"}}
    end
  end
end
