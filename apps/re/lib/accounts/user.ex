defmodule Re.User do
  @moduledoc """
  Model for users.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string, default: "user"

    field :device_token, :string
    field :account_kit_id, :string

    field :type, :string, default: "property_owner"
    field :salesforce_id, :string

    embeds_one(
      :notification_preferences,
      Re.Accounts.NotificationPreferences,
      on_replace: :update
    )

    has_many :listings, Re.Listing

    has_many(:broker_leads, Re.SellerLeads.Broker, foreign_key: :broker_uuid, references: :uuid)

    has_many :listings_favorites, Re.Favorite
    has_many :favorited, through: [:listings_favorites, :listing]

    many_to_many :districts, Re.Addresses.District,
      join_through: Re.BrokerDistrict,
      join_keys: [user_uuid: :uuid, district_uuid: :uuid],
      on_replace: :delete

    timestamps()
  end

  @roles ~w(admin user)
  @types ~w(property_owner partner_broker)

  @phone_regex ~r/^\+55[0-9]{11}$/
  @update_required ~w()a
  @update_optional ~w(name email role phone device_token type salesforce_id)a

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @update_required ++ @update_optional)
    |> cast_embed(
      :notification_preferences,
      with: &Re.Accounts.NotificationPreferences.changeset/2
    )
    |> validate_required(@update_required)
    |> base_changeset()
  end

  @account_kit_required ~w(account_kit_id phone role)a
  @account_kit_optional ~w(name email)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def account_kit_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @account_kit_required ++ @account_kit_optional)
    |> cast_embed(
      :notification_preferences,
      with: &Re.Accounts.NotificationPreferences.changeset/2
    )
    |> validate_required(@account_kit_required)
    |> unique_constraint(:account_kit_id)
    |> Re.ChangesetHelper.generate_uuid()
  end

  @create_required ~w(role phone)a
  @create_optional ~w(name email device_token type salesforce_id)a

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @create_required ++ @create_optional)
    |> validate_required(@create_required)
    |> base_changeset()
    |> Re.ChangesetHelper.generate_uuid()
  end

  defp base_changeset(changeset) do
    changeset
    |> validate_email()
    |> validate_phone()
    |> validate_inclusion(:role, @roles)
    |> validate_inclusion(:type, @types)
  end

  defp validate_email(changeset) do
    changeset
    |> get_field(:email)
    |> check_email(changeset)
  end

  defp validate_phone(changeset) do
    changeset
    |> get_field(:phone)
    |> check_phone(changeset)
  end

  defp check_phone(nil, changeset), do: changeset

  defp check_phone(phone, changeset) do
    case String.match?(phone, @phone_regex) do
      true -> changeset
      false -> add_error(changeset, :phone, "has invalid format: #{phone}", validation: :format)
    end
  end

  defp check_email(nil, changeset), do: changeset

  defp check_email(email, changeset) do
    case EmailChecker.valid?(email) do
      true -> changeset
      false -> add_error(changeset, :email, "has invalid format", validation: :format)
    end
  end
end
