defmodule Re.BuyerLeads.Grupozap do
  @moduledoc """
  Schema for buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias Re.{
    Accounts.Users,
    BuyerLead,
    Listings
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "grupozap_buyer_leads" do
    field :lead_origin, :string
    field :timestamp, :utc_datetime
    field :origin_lead_id, :string
    field :origin_listing_id, :string
    field :client_listing_id, :string
    field :name, :string
    field :email, :string
    field :ddd, :string
    field :phone, :string
    field :message, :string

    timestamps()
  end

  @required ~w(client_listing_id)a
  @optional ~w(lead_origin timestamp origin_lead_id origin_listing_id
    name email ddd phone message)a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)

  def buyer_lead_changeset(nil), do: raise("Leads.GrupozapBuyer not found")

  def buyer_lead_changeset(gzb) do
    phone_number = concat_phone_number(gzb)
    listing = Listings.get_partial_preloaded(gzb.client_listing_id, [:address])

    BuyerLead.changeset(%BuyerLead{}, %{
      name: gzb.name,
      email: gzb.email,
      phone_number: phone_number,
      origin: gzb.lead_origin,
      location: get_location(listing),
      user_uuid: extract_user_uuid(phone_number),
      listing_uuid: get_listing_uuid(listing)
    })
  end

  defp get_location({:ok, %{address: address}}), do: "#{address.city_slug}|#{address.state_slug}"
  defp get_location(_), do: "unknown"

  defp concat_phone_number(%{ddd: _ddd, phone: nil}), do: "not informed"

  defp concat_phone_number(%{ddd: nil, phone: phone}), do: "+55" <> phone

  defp concat_phone_number(%{ddd: ddd, phone: phone}), do: "+55" <> ddd <> phone

  defp extract_user_uuid("not informed"), do: nil

  defp extract_user_uuid(phone_number) do
    case Users.get_by_phone(phone_number) do
      {:ok, user} -> user.uuid
      _error -> nil
    end
  end

  defp get_listing_uuid({:ok, listing}), do: listing.uuid
  defp get_listing_uuid(_), do: nil
end
