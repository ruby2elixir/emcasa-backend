defmodule Re.SellerLeads.NotifyWhenCovered do
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

    field :state, :string
    field :city, :string
    field :neighborhood, :string

    timestamps()
  end

  @required ~w(state city neighborhood)a
  @optional ~w(name email phone message)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
