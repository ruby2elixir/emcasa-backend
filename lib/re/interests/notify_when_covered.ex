defmodule Re.Interests.NotifyWhenCovered do
  @moduledoc """
  Schema for storing interest in non-covered regions
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "notify_when_covered" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    belongs_to :user, Re.User
    belongs_to :address, Re.Address

    timestamps()
  end

  @required ~w(address_id)a
  @optional ~w(name email phone message user_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
