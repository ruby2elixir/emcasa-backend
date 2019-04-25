defmodule Re.OwnerContacts do
  alias Re.{
    OwnerContact,
    Repo
  }

  def all(), do: Repo.all(OwnerContact)

  def get(uuid) do
    OwnerContact
    |> Repo.get(uuid)
    |> get_response()
  end

  def get_by_phone(phone) do
    OwnerContact
    |> Repo.get_by(phone: phone)
    |> get_response()
  end

  defp get_response(nil), do: {:error, :not_found}
  defp get_response(contact), do: {:ok, contact}

  def upsert(params) do
    upsert(%OwnerContact{}, params)
  end

  def upsert(struct, params) do
    struct
    |> Map.put(:uuid, nil)
    |> OwnerContact.changeset(params)
    |> Repo.insert(
      returning: true,
      on_conflict: {:replace, [:name, :email, :updated_at]},
      conflict_target: [:name_slug, :phone]
    )
  end
end
