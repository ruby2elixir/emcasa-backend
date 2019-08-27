defmodule Re.Shortlist do
  @moduledoc """
  Model for shortlists entity
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "shortlists" do
    field :opportunity_id, :string
    field :account_name, :string
    field :owner_name, :string

    many_to_many :listings, Re.Listing,
      join_through: "listings_shortlists",
      join_keys: [shortlist_uuid: :uuid, listing_uuid: :uuid],
      on_replace: :delete

    timestamps()
  end

  @required ~w(opportunity_id)a
  @optional ~w(account_name owner_name)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> Re.ChangesetHelper.generate_uuid()
  end
end
