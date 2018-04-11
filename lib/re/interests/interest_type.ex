defmodule Re.InterestType do
  @moduledoc """
  Schema module for interest types
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "interest_types" do
    field :name, :string

    timestamps()
  end

  @required ~w(name)a
  @optional ~w()a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
