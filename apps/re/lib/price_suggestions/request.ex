defmodule Re.PriceSuggestions.Request do
  @moduledoc """
  Schema for storing price suggestion request
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "price_suggestion_requests" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :email, :string

    field :area, :integer
    field :rooms, :integer
    field :bathrooms, :integer
    field :garage_spots, :integer
    field :suites, :integer
    field :maintenance_fee, :float
    field :type, :string
    field :is_covered, :boolean
    field :suggested_price, :float
    field :listing_price_rounded, :float
    field :listing_price_error_q90_min, :float
    field :listing_price_error_q90_max, :float
    field :listing_price_per_sqr_meter, :float
    field :listing_average_price_per_sqr_meter, :float

    belongs_to :address, Re.Address
    belongs_to :user, Re.User

    belongs_to :seller_lead, Re.SellerLead,
      references: :uuid,
      foreign_key: :seller_lead_uuid,
      type: Ecto.UUID

    timestamps()
  end

  @required ~w(address_id area rooms bathrooms garage_spots is_covered)a
  @optional ~w(name email user_id suggested_price listing_price_rounded
              listing_price_error_q90_min listing_price_error_q90_max listing_price_per_sqr_meter
              listing_average_price_per_sqr_meter suites type maintenance_fee seller_lead_uuid)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
