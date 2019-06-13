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
    params =
      %{
        name: gzb.name,
        email: gzb.email,
        origin: gzb.lead_origin
      }
      |> put_location(gzb)
      |> put_user_info(gzb)

    BuyerLead.changeset(%BuyerLead{}, params)
  end

  defp put_location(params, gzb) do
    case Listings.get_partial_preloaded(gzb.client_listing_id, [:address]) do
      {:ok, %{address: address} = listing} ->
        params
        |> Map.put(:location, "#{address.city_slug}|#{address.state_slug}")
        |> Map.put(:listing_uuid, listing.uuid)
        |> Map.put(:neighborhood, address.neighborhood)

      {:error, :not_found} ->
        params
    end
  end

  defp put_user_info(params, gzb) do
    phone_number = concat_phone_number(gzb)

    phone_number
    |> Users.get_by_phone()
    |> case do
      {:ok, user} ->
        params
        |> Map.put(:user_uuid, user.uuid)
        |> Map.put(:user_url, Users.build_user_url(user))

      {:error, :not_found} ->
        params
    end
    |> Map.put(:phone_number, phone_number)
  end

  defp concat_phone_number(%{ddd: _ddd, phone: nil}), do: "not informed"

  defp concat_phone_number(%{ddd: nil, phone: phone}), do: "+55" <> phone

  defp concat_phone_number(%{ddd: ddd, phone: phone}), do: "+55" <> ddd <> phone
end
