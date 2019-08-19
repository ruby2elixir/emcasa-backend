defmodule Re.SellerLead do
  @moduledoc """
  Schema for seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.SellerLeads.Utm

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "seller_leads" do
    field :source, :string
    field :complement, :string
    field :type, :string
    field :area, :integer
    field :maintenance_fee, :float
    field :rooms, :integer
    field :bathrooms, :integer
    field :suites, :integer
    field :garage_spots, :integer
    field :price, :float
    field :suggested_price, :float
    field :tour_option, :utc_datetime
    field :salesforce_id, :string
    field :duplicated, :string

    embeds_one :utm, Re.SellerLeads.Utm

    belongs_to :address, Re.Address,
      references: :uuid,
      foreign_key: :address_uuid,
      type: Ecto.UUID

    belongs_to :user, Re.User,
      references: :uuid,
      foreign_key: :user_uuid,
      type: Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @required ~w(source)a
  @optional ~w(complement type area maintenance_fee rooms bathrooms suites garage_spots price
               suggested_price tour_option address_uuid user_uuid salesforce_id duplicated)a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> cast_embed(:utm, with: &Utm.changeset/2)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
