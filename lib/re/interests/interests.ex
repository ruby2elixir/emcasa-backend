defmodule Re.Interests do
  @moduledoc """
  Context to manage operation between users and listings
  """

  alias Re.{
    Interest,
    Interests.ContactRequest,
    InterestType,
    Repo,
    User
  }

  import Ecto.Query

  def show_interest(listing_id, params) do
    params = Map.put(params, "listing_id", listing_id)

    %Interest{}
    |> Interest.changeset(params)
    |> Repo.insert()
  end

  def preload(interest), do: Repo.preload(interest, :interest_type)

  def get_types do
    Repo.all(from it in InterestType, where: it.enabled == true)
  end

  def request_contact(params, user) do
    %ContactRequest{}
    |> ContactRequest.changeset(params)
    |> attach_user(user)
    |> Repo.insert()
  end

  defp attach_user(changeset, %User{id: id}),
    do: ContactRequest.changeset(changeset, %{user_id: id})

  defp attach_user(changeset, _), do: changeset
end
