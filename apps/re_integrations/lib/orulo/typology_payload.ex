defmodule ReIntegrations.Orulo.TypologyPayload do
  @moduledoc """
  Schema for Orulo typology sincronization
  """
  use Ecto.Schema

  import Ecto.Changeset

  @schema_prefix "re_integrations"
  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "orulo_typology_payloads" do
    field :external_id, :integer
    field :payload, :map

    timestamps()
  end

  @required ~w(external_id payload)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
