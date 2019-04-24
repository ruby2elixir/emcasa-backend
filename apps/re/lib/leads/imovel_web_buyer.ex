defmodule Re.Leads.ImovelWebBuyer do
  @moduledoc """
  Schema for ImovelWeb buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias Re.{
    Accounts.Users,
    Leads.Buyer,
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

    Buyer.changeset(%Buyer{}, %{
      name: lead.name,
      email: lead.email,
      phone_number: lead.phone,
      origin: "imovelweb",
      user_uuid: extract_user_uuid(phone_number),
      listing_uuid: extract_listing_uuid(lead.listing_id)
    })
  end

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

  defp extract_listing_uuid(id) do
    case Listings.get(id) do
      {:ok, listing} -> listing.uuid
      _error -> nil
    end
  end
end
