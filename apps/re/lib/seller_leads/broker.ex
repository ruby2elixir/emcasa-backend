defmodule Re.SellerLeads.Broker do
  @moduledoc """
  Schema for broker indication seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.SellerLeads.Utm

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "broker_seller_leads" do
    field :complement, :string
    field :type, :string
    field :additional_information, :string

    embeds_one :utm, Re.SellerLeads.Utm

    belongs_to :address, Re.Address,
      references: :uuid,
      foreign_key: :address_uuid,
      type: Ecto.UUID

    belongs_to :broker, Re.User,
      references: :uuid,
      foreign_key: :broker_uuid,
      type: Ecto.UUID

    belongs_to :owner, Re.OwnerContact,
      references: :uuid,
      foreign_key: :owner_uuid,
      type: Ecto.UUID

    timestamps()
  end

  @types ~w(Apartamento Casa Cobertura)
  @required ~w(type address_uuid broker_uuid owner_uuid)a
  @optional ~w(complement additional_information)a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> cast_embed(:utm, with: &Utm.changeset/2)
    |> validate_required(@required)
    |> validate_inclusion(:type, @types)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
