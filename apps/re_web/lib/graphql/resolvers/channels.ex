defmodule ReWeb.Resolvers.Channels do
  @moduledoc """
  Resolver module for channels
  """
  alias Re.{
    Listings,
    Messages,
    Messages.Channels
  }

  def all(params, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :index, current_user, params) do
      channels =
        params
        |> Map.put(:current_user_id, current_user.id)
        |> Channels.all()

      {:ok, channels}
    end
  end

  def get_listing(channel, _, %{context: %{current_user: current_user}}) do
    with :ok <- Bodyguard.permit(Messages, :listing, current_user, %{}) do
      Listings.get(channel.listing_id)
    end
  end
end
