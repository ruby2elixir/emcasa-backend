defmodule ReWeb.Resolvers.Stats do
  @moduledoc """
  Resolver module for interests
  """
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  def interest_count(listing, _params, %{context: %{loader: loader, current_user: current_user}}) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(Re.Listings, :interests, listing)
      |> on_load(fn loader ->
        {:ok, Enum.count(Dataloader.get(loader, Re.Listings, :interests, listing))}
      end)
    else
      {:ok, nil}
    end
  end

  def in_person_visit_count(listing, _params, %{context: %{loader: loader, current_user: current_user}}) do
    if is_admin(listing, current_user) do
      loader
      |> Dataloader.load(Re.Listings, :in_person_visits, listing)
      |> on_load(fn loader ->
        {:ok, Enum.count(Dataloader.get(loader, Re.Listings, :in_person_visits, listing))}
      end)
    else
      {:ok, nil}
    end
  end

  defp is_admin(%{user_id: user_id}, %{id: user_id}), do: true
  defp is_admin(_, %{role: "admin"}), do: true
  defp is_admin(_, _), do: false
end
