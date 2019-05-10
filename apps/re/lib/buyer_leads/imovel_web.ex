defmodule Re.BuyerLeads.ImovelWeb do
  @moduledoc """
  Schema for ImovelWeb buyer leads
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

  def buyer_lead_changeset(nil), do: raise("Leads.FacebookBuyer not found")

  def buyer_lead_changeset(lead) do
    phone_number = format_phone_number(lead.phone)
    listing = Listings.get_partial_preloaded(lead.listing_id, [:address])

    BuyerLead.changeset(%BuyerLead{}, %{
      name: lead.name,
      email: lead.email,
      phone_number: lead.phone,
      origin: "imovelweb",
      location: get_location(listing),
      user_uuid: extract_user_uuid(phone_number),
      listing_uuid: get_listing_uuid(listing)
    })
  end

  defp get_location({:ok, %{address: address}}), do: "#{address.city_slug}|#{address.state_slug}"
  defp get_location(_), do: "unknown"

  defp format_phone_number(nil), do: nil

  defp format_phone_number("0" <> phone_number), do: "+55" <> phone_number

  defp format_phone_number(phone_number), do: phone_number

  defp extract_user_uuid(nil), do: nil

  defp extract_user_uuid(phone_number) do
    case Users.get_by_phone(phone_number) do
      {:ok, user} -> user.uuid
      _error -> nil
    end
  end

  defp get_listing_uuid({:ok, listing}), do: listing.uuid
  defp get_listing_uuid(_), do: nil
end
