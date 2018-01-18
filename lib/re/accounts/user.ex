defmodule Re.User do
  @moduledoc """
  Model for users.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Comeonin.Bcrypt

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:phone, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:role, :string)

    field(:confirmation_token, :string)
    field(:confirmed, :boolean)
    field(:reset_token, :string)

    has_many(:listings, Re.Listing)

    timestamps()
  end

  @roles ~w(admin user)

  @create_required ~w(name email password role confirmation_token confirmed)a
  @optional ~w(phone)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @create_required ++ @optional)
    |> validate_required(@create_required)
    |> base_changeset()
    |> hash_password()
  end

  @update_required ~w()a
  @update_optional ~w(name email password role confirmation_token confirmed phone)a

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @update_required ++ @update_optional)
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
