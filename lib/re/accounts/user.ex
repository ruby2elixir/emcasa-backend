defmodule Re.User do
  @moduledoc """
  Model for users.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :password, :string
    field :role, :string

    timestamps()
  end

  @required ~w(name email password role)
  @optional ~w(phone)a
  @roles ~w(admin user)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> validate_inclusion(:role, @roles)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def passwordless_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :phone])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end
end
