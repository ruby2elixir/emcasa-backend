defmodule Re.Leads.ImovelWebBuyer do
  @moduledoc """
  Schema for ImovelWeb buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "imovelweb_buyer_leads" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :listing_id, :string

    timestamps()
  end

  @required ~w(name email phone listing_id)a
  @optional ~w()a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
