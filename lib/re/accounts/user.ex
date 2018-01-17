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

    has_many :listings, Re.Listing

    timestamps()
  end

  @required ~w(name email password role)a
  @optional ~w(phone)a

  @roles ~w(admin user)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_email()
    |> unique_constraint(:email)
    |> validate_inclusion(:role, @roles, message: "should be one of: [#{Enum.join(@roles, " ")}]")
    |> hash_password()
  end

  defp validate_email(changeset) do
    changeset
    |> get_field(:email)
    |> EmailChecker.valid?()
    |> case do
      true -> changeset
      false -> add_error(changeset, :email, "has invalid format", [validation: :format])
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
