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
    params =
      %{
        name: lead.name,
        email: lead.email,
        origin: "imovelweb"
      }
      |> put_location(lead)
      |> put_user_info(lead)

    BuyerLead.changeset(%BuyerLead{}, params)
  end

  defp put_location(params, lead) do
    case Listings.get_partial_preloaded(lead.listing_id, [:address]) do
      {:ok, %{address: address} = listing} ->
        params
        |> Map.put(:location, "#{address.city_slug}|#{address.state_slug}")
        |> Map.put(:listing_uuid, listing.uuid)
        |> Map.put(:neighborhood, address.neighborhood)

      {:error, :not_found} ->
        Map.put(params, :location, "unknown")
    end
  end

  defp put_user_info(params, %{phone: nil}), do: params

  defp put_user_info(params, lead) do
    phone_number = format_phone_number(lead.phone)

    phone_number
    |> Users.get_by_phone()
    |> case do
      {:ok, user} -> Map.put(params, :user_uuid, user.uuid)
      {:error, :not_found} -> params
    end
    |> Map.put(:phone_number, phone_number)
  end

  defp format_phone_number("0" <> phone_number), do: "+55" <> phone_number

  defp format_phone_number(phone_number), do: phone_number
end
