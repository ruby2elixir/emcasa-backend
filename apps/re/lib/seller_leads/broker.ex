defmodule Re.SellerLeads.Broker do
  @moduledoc """
  Schema for broker indication seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.SellerLead

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "broker_seller_leads" do
    field :complement, :string
    field :type, :string
    field :additional_information, :string

    belongs_to :address, Re.Address,
      references: :uuid,
      foreign_key: :address_uuid,
      type: Ecto.UUID

    belongs_to :broker, Re.User,
      references: :uuid,
      foreign_key: :broker_uuid,
      type: Ecto.UUID

    belongs_to :owner, Re.User,
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
    |> validate_required(@required)
    |> validate_inclusion(:type, @types)
    |> generate_uuid()
  end

  def seller_lead_changeset(lead, property_owner) do
    params = %{
      source: "WebSite",
      type: lead.type,
      area: lead.area,
      maintenance_fee: lead.maintenance_fee,
      rooms: lead.rooms,
      bathrooms: lead.bathrooms,
      suites: lead.suites,
      garage_spots: lead.garage_spots,
      suggested_price: lead.suggested_price,
      user_uuid: property_owner.uuid,
      address_uuid: lead.address.uuid,
      account_salesforce_id: lead.user.salesforce_id
    }

    SellerLead.changeset(%SellerLead{}, params)
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
