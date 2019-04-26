defmodule ReWeb.Resolvers.OwnerContacts do
  @moduledoc """
  Resolver module for owner contact queries and mutations
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def per_listing(listing, _params, %{context: %{loader: loader, current_user: current_user}}) do
    with :ok <-
           Bodyguard.permit(Re.OwnerContacts, :fetch_owner_contact, current_user, current_user) do
      loader
      |> Dataloader.load(Re.OwnerContacts, :owner_contact, listing)
      |> on_load(fn loader ->
        {:ok, Dataloader.get(loader, Re.OwnerContacts, :owner_contact, listing)}
      end)
    else
      _ -> {:ok, nil}
    end
  end
end
