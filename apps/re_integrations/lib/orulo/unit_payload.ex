defmodule ReIntegrations.Orulo.UnitPayload do
  @moduledoc """
  Schema for Orulo units sincronization
  """
  use Ecto.Schema

  import Ecto.Changeset

  @schema_prefix "re_integrations"
  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "orulo_unit_payloads" do
    field :building_id, :string
    field :typology_id, :string
    field :payload, :map

    timestamps()
  end

  @required ~w(building_id typology_id payload)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
