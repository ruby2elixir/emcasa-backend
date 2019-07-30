defmodule Re.Interest do
  @moduledoc """
  Schema module for storing interest in a listing
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.{
    Accounts.Users,
    BuyerLead
  }

  schema "interests" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string

    belongs_to :listing, Re.Listing
    belongs_to :interest_type, Re.InterestType

    timestamps()
  end

  @required ~w(name phone listing_id)a
  @optional ~w(email message interest_type_id uuid campaign medium
               source initial_campaign initial_medium initial_source)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:listing_id,
      name: :interests_listing_id_fkey,
      message: "does not exist."
    )
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)

  def buyer_lead_changeset(nil), do: raise("Interest not found")

  def buyer_lead_changeset(interest) do
    params =
      %{
        name: interest.name,
        email: interest.email,
        origin: "site"
      }
      |> put_location(interest)
      |> put_user_info(interest)
      |> put_utm_info(interest)

    BuyerLead.changeset(%BuyerLead{}, params)
  end

  defp put_location(params, %{listing: %{address: address} = listing}) do
    params
    |> Map.put(:location, "#{address.city_slug}|#{address.state_slug}")
    |> Map.put(:listing_uuid, listing.uuid)
    |> Map.put(:neighborhood, address.neighborhood)
  end

  defp put_user_info(params, %{phone: nil}), do: params

  defp put_user_info(params, interest) do
    phone_number = String.replace(interest.phone, ["(", ")", "-", " "], "")

    phone_number
    |> Users.get_by_phone()
    |> do_put_user_info(params)
    |> Map.put(:phone_number, phone_number)
  end

  defp do_put_user_info({:ok, user}, params) do
    params
    |> Map.put(:user_uuid, user.uuid)
    |> Map.put(:user_url, Users.build_user_url(user))
  end

  defp do_put_user_info({:error, :not_found}, params), do: params

  defp put_utm_info(params, interest) do
    Map.put(params, :utm, %{
      campaign: interest.campaign,
      medium: interest.medium,
      source: interest.source,
      initial_campaign: interest.initial_campaign,
      initial_medium: interest.initial_medium,
      initial_source: interest.initial_source
    })
  end
end
