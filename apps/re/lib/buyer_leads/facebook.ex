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
    BuyerLeads.FacebookClient
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
    {:ok, listing_uuid} = extract_listing_uuid(lead.lead_id)

    BuyerLead.changeset(%BuyerLead{}, %{
      name: lead.full_name,
      email: lead.email,
      phone_number: lead.phone_number,
      origin: "facebook",
      location: get_location(lead.location),
      budget: lead.budget,
      user_uuid: extract_user_uuid(lead.phone_number),
      listing_uuid: listing_uuid,
      neighborhood: lead.neighborhoods
    })
  end

  defp get_location("SP"), do: "sao-paulo|sp"
  defp get_location("RJ"), do: "rio-de-janeiro|rj"
  defp get_location(_), do: "unknown"

  defp extract_user_uuid(nil), do: nil

  defp extract_user_uuid(phone_number) do
    case Users.get_by_phone(phone_number) do
      {:ok, user} -> user.uuid
      _error -> nil
    end
  end

  defp extract_listing_uuid(lead_id) do
    with {:facebook_client_call, {:ok, %{body: body}}} <-
           {:facebook_client_call, FacebookClient.get_lead(lead_id)},
         {:ok, %{"retailer_item_id" => listing_id}} <- Jason.decode(body),
         {:ok, listing} <- Re.Listings.get(listing_id) do
      {:ok, listing.uuid}
    else
      {:facebook_client_call, error} ->
        raise "Error calling FacebookClient. Error: #{Kernel.inspect(error)}"

      _error ->
        {:ok, nil}
    end
  end
end
