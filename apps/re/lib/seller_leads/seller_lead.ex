defmodule Re.SellerLead do
  @moduledoc """
  Schema for seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "seller_leads" do
    field :source, :string
    field :complement, :string
    field :type, :string
    field :area, :string
    field :maintenance_fee, :float
    field :rooms, :integer
    field :bathrooms, :integer
    field :suites, :integer
    field :garage_spots, :integer
    field :price, :float
    field :tour_option, :utc_datetime

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

  @required ~w(origin)a
  @optional ~w(street street_number city state neighborhood postal_code name phone email source
               complement type area maintenance_fee rooms bathrooms suites garage_spots value
               tour_option)a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
