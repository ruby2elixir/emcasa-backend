defmodule Re.SellerLeads.SiteLead do
  @moduledoc """
  Schema for site's seller leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "site_seller_leads" do
    field :complement, :string
    field :type, :string
    field :maintenance_fee, :float
    field :suites, :integer
    field :price, :integer

    belongs_to :price_request, Re.PriceSuggestions.Request
    belongs_to :tour_appointment, Re.Calendars.TourAppointment

    timestamps(type: :utc_datetime)
  end

  @types ~w(Apartamento Casa Cobertura)

  @required ~w(price_request_id tour_appointment_id)a
  @optional ~w(complement type maintenance_fee suites price)a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> validate_inclusion(:type, @types, message: "should be one of: [#{Enum.join(@types, " ")}]")
    |> generate_uuid()
    |> validate_attributes()
  end

  @more_than_zero_attributes ~w(maintenance_fee suites price)a

  defp validate_attributes(changeset) do
    Enum.reduce(@more_than_zero_attributes, changeset, &greater_than/2)
  end

  defp greater_than(attr, changeset) do
    validate_number(changeset, attr, greater_than_or_equal_to: 0)
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
