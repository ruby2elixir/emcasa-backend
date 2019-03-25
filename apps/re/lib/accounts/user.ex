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

    embeds_one(
      :notification_preferences,
      Re.Accounts.NotificationPreferences,
      on_replace: :update
    )

    has_many :listings, Re.Listing

    has_many :listings_favorites, Re.Favorite
    has_many :favorited, through: [:listings_favorites, :listing]

    timestamps()
  end

  @roles ~w(admin user)

  @update_required ~w()a
  @update_optional ~w(name email role phone device_token)a

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
    |> generate_uuid()
    |> unique_constraint(:uuid, name: :uuid)
  end

  def uuid_changeset(struct, params), do: cast(struct, params, ~w(uuid)a)

  defp base_changeset(changeset) do
    changeset
    |> validate_email()
    |> validate_inclusion(:role, @roles, message: "should be one of: [#{Enum.join(@roles, " ")}]")
  end

  defp validate_email(changeset) do
    changeset
    |> get_field(:email)
    |> check_email(changeset)
  end

  defp check_email(nil, changeset), do: changeset

  defp check_email(email, changeset) do
    case EmailChecker.valid?(email) do
      true -> changeset
      false -> add_error(changeset, :email, "has invalid format", validation: :format)
    end
  end

  defp generate_uuid(%{data: %{uuid: nil}} = changeset) do
    Ecto.Changeset.change(changeset, %{uuid: UUID.uuid4()})
  end

  defp generate_uuid(changeset), do: changeset
end
