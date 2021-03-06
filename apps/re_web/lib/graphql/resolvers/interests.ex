defmodule ReWeb.Resolvers.Interests do
  @moduledoc """
  Resolver module for interests queries and mutations
  """
  alias Re.Interests

  alias ReIntegrations.Simulators

  def create_interest(%{input: params}, _) do
    Interests.show_interest(params)
  end

  def request_contact(params, %{context: %{current_user: current_user}}) do
    Interests.request_contact(params, current_user)
  end

  def simulate(%{input: input}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Simulators, :simulate, current_user) do
      Simulators.simulate(input)
    end
  end
end
