defmodule ReWeb.Resolvers.Interests do
  @moduledoc """
  Resolver module for interests queries and mutations
  """
  alias Re.{
    Interests,
    PriceSuggestions
  }

  alias ReIntegrations.Simulators

  def create_interest(%{input: params}, _) do
    Interests.show_interest(params)
  end

  def request_contact(params, %{context: %{current_user: current_user}}) do
    Interests.request_contact(params, current_user)
  end

  def request_price_suggestion(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Interests, :request_price_suggestion, current_user) do
      Interests.request_price_suggestion(params, current_user)
    end
  end

  def price_suggestion(%{input: params}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Interests, :price_suggestion, current_user) do
      PriceSuggestions.suggest_price(params)
    end
  end

  def notify_when_covered(params, _), do: Interests.notify_when_covered(params)

  def simulate(%{input: input}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Simulators, :simulate, current_user) do
      Simulators.simulate(input)
    end
  end
end
