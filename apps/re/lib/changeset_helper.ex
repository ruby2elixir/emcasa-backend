defmodule Re.ChangesetHelper do
  alias Ecto.Changeset

  def uuid_changeset(struct, params), do: Changeset.cast(struct, params, ~w(uuid)a)

  def generate_uuid(%{data: %{uuid: nil}} = changeset) do
    changeset
    |> Changeset.change(%{uuid: UUID.uuid4()})
    |> Changeset.unique_constraint(:uuid, name: :uuid)
  end

  def generate_uuid(changeset), do: Changeset.unique_constraint(changeset, :uuid, name: :uuid)
end
