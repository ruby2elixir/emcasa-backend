defmodule Re.BuyerLeads.Facebook do
  @moduledoc """
  Schema for facebook buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias Re.{
    Accounts.Users,
    BuyerLead,
    BuyerLeads.FacebookClient,
    Listings
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "facebook_buyer_leads" do
    field :full_name, :string
    field :email, :string
    field :phone_number, :string
    field :neighborhoods, :string
    field :timestamp, :utc_datetime
    field :lead_id, :string
    field :location, :string
    field :budget, :string

    timestamps()
  end

  @required ~w(full_name email phone_number timestamp lead_id location)a
  @optional ~w(neighborhoods budget)a
  @params @required ++ @optional
  @locations ~w(RJ SP)

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> validate_inclusion(:location, @locations,
      message: "should be one of: [#{Enum.join(@locations, " ")}]"
    )
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)

  def buyer_lead_changeset(nil), do: raise("Leads.FacebookBuyer not found")

  def buyer_lead_changeset(lead) do
    params =
      %{
        name: lead.full_name,
        email: lead.email,
        phone_number: lead.phone_number,
        origin: "facebook",
        budget: lead.budget,
        neighborhood: lead.neighborhoods
      }
      |> put_location(lead)
      |> put_user_info(lead)

    BuyerLead.changeset(%BuyerLead{}, params)
  end

  defp put_location(params, %{lead_id: lead_id, location: location}) do
    lead_id
    |> get_listing()
    |> case do
      {:ok, %{address: address} = listing} ->
        params
        |> Map.put(:location, "#{address.city_slug}|#{address.state_slug}")
        |> Map.put(:listing_uuid, listing.uuid)

      {:error, _} ->
        Map.put(params, :location, get_location(location))
    end
  end

  defp put_user_info(params, %{phone_number: nil}), do: params

  defp put_user_info(params, %{phone_number: phone_number}) do
    case Users.get_by_phone(phone_number) do
      {:ok, user} ->
        Map.put(params, :user_uuid, user.uuid)

      {:error, :not_found} ->
        params
    end
    |> Map.put(:phone_number, phone_number)
  end

  defp get_location("SP"), do: "sao-paulo|sp"
  defp get_location("RJ"), do: "rio-de-janeiro|rj"
  defp get_location(_), do: "unknown"

  defp get_listing(lead_id) do
    with {:ok, %{body: body}} <- FacebookClient.get_lead(lead_id),
         {:ok, listing_id} <- get_retailer_item_id(body) do
      Listings.get_partial_preloaded(listing_id, [:address])
    end
  end

  defp get_retailer_item_id(body) do
    case Jason.decode(body) do
      {:ok, %{"retailer_item_id" => listing_id}} -> {:ok, listing_id}
      {:ok, _} -> {:error, :not_found}
      error -> error
    end
  end
end
