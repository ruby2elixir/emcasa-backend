defmodule ReWeb.Resolvers.Messages do
  @moduledoc """
  Resolver module for messages
  """
  alias Re.{
    Listings,
    Messages
  }

  def send(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :send_message, current_user, %{}) do
      Messages.send(current_user, params)
    end
  end

  def listing_user(%{listing_id: listing_id}, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :listing_user, current_user, %{}),
         {:ok, listing} <- Listings.get(listing_id) do
      {:ok, Messages.get_listing(listing, current_user)}
    end
  end
end
