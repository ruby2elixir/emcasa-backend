defmodule Re.User do
  @moduledoc """
  Model for users.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Comeonin.Bcrypt

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string

    field :confirmation_token, :string
    field :confirmed, :boolean
    field :reset_token, :string
    field :device_token, :string

    embeds_one(
      :notification_preferences,
      Re.Accounts.NotificationPreferences,
      on_replace: :update
    )

    has_many :listings, Re.Listing

    has_many :listings_favorites, Re.Favorite
    has_many :favorited, through: [:listings_favorites, :listing]

    has_many :listings_blacklists, Re.Blacklist
    has_many :blacklisted, through: [:listings_blacklists, :listing]

    timestamps()
  end

  @roles ~w(admin user)

  @create_required ~w(name email password role confirmation_token confirmed)a
  @optional ~w(phone device_token)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @create_required ++ @optional)
    |> cast_embed(
      :notification_preferences,
      with: &Re.Accounts.NotificationPreferences.changeset/2
    )
    |> validate_required(@create_required)
    |> base_changeset()
    |> hash_password()
  end

  @update_required ~w()a
  @update_optional ~w(name email password role confirmation_token confirmed phone device_token)a

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

  @reset_required ~w(reset_token)a
  @reset_optional ~w()a

  def reset_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @reset_required ++ @reset_optional)
    |> validate_required(@reset_required)
    |> base_changeset()
  end

  @redefine_required ~w(password)a
  @redefine_optional ~w(reset_token)a

  def redefine_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @redefine_required ++ @redefine_optional)
    |> validate_required(@redefine_required)
    |> base_changeset()
    |> hash_password()
  end

  @email_required ~w(email confirmed confirmation_token)a
  @email_optional ~w()a

  def email_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @email_required ++ @email_optional)
    |> validate_required(@email_required)
    |> base_changeset()
  end

  defp base_changeset(changeset) do
    changeset
    |> validate_email()
    |> unique_constraint(:email)
    |> validate_inclusion(:role, @roles, message: "should be one of: [#{Enum.join(@roles, " ")}]")
  end

  defp validate_email(changeset) do
    changeset
    |> get_field(:email)
    |> EmailChecker.valid?()
    |> case do
      true -> changeset
      false -> add_error(changeset, :email, "has invalid format", validation: :format)
    end
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset

  defp hash_password(changeset) do
    password_hash =
      changeset
      |> get_change(:password)
      |> Bcrypt.hashpwsalt()

    put_change(changeset, :password_hash, password_hash)
  end
end
