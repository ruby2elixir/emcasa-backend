defmodule Re.SellerLead do
  @moduledoc """
  Schema for seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "seller_leads" do
    field :street, :string
    field :street_number, :string
    field :city, :string
    field :state, :string
    field :neighborhood, :string
    field :postal_code, :string
    field :name, :string
    field :phone, :string
    field :email, :string
    field :source, :string
    field :complement, :string
    field :type, :string
    field :area, :string
    field :maintenance_fee, :float
    field :rooms, :integer
    field :bathrooms, :integer
    field :suites, :integer
    field :garage_spots, :integer
    field :value, :string
    field :tour_option, :utc_datetime

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
