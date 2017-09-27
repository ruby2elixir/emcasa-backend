defmodule ReWeb.User do
  @moduledoc """
  Model for users.
  """

  use ReWeb, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :phone])
    |> validate_required([])
  end
end
