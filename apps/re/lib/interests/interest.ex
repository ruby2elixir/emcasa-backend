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

    belongs_to :listing, Re.Listing
    belongs_to :interest_type, Re.InterestType

    timestamps()
  end

  @required ~w(name phone listing_id)a
  @optional ~w(email message interest_type_id uuid)a

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
    phone_number = format(interest.phone)

    BuyerLead.changeset(%BuyerLead{}, %{
      name: interest.name,
      phone_number: phone_number,
      email: interest.email,
      origin: "site",
      location: get_location(interest.listing),
      listing_uuid: interest.listing.uuid,
      user_uuid: extract_user_uuid(phone_number),
      neighborhood: get_neighborhood(interest.listing)
    })
  end

  defp get_location(%{address: address}), do: "#{address.city_slug}|#{address.state_slug}"

  defp format(nil), do: nil

  defp format(phone_number), do: String.replace(phone_number, ["(", ")", "-", " "], "")

  defp extract_user_uuid(nil), do: nil

  defp extract_user_uuid(phone_number) do
    case Users.get_by_phone(phone_number) do
      {:ok, user} -> user.uuid
      _error -> nil
    end
  end

  defp get_neighborhood(%{address: address}), do: address.neighborhood
  defp get_neighborhood(_), do: nil
end
