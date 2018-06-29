defmodule Re.Interests.ContactRequest do
  @moduledoc """
  Schema for contact request
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "contact_requests" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    belongs_to :user, Re.User

    timestamps()
  end

  @attrs ~w(name email phone message user_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attrs)
  end
end
