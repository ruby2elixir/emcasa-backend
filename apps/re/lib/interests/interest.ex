defmodule Re.Interest do
  @moduledoc """
  Schema module for storing interest in a listing
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "interests" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :email, :string
    field :phone, :string
    field :message, :string

    belongs_to :listing, Re.Listing
    belongs_to :interest_type, Re.InterestType

    timestamps()
  end

  @required ~w(name listing_id)a
  @optional ~w(email phone message interest_type_id uuid)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:listing_id,
      name: :interests_listing_id_fkey,
      message: "does not exist."
    )
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
