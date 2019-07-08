defmodule Re.BuyerLead do
  @moduledoc """
  Schema for buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "buyer_leads" do
    field :name, :string
    field :phone_number, :string
    field :email, :string
    field :origin, :string
    field :location, :string
    field :budget, :string
    field :neighborhood, :string
    field :url, :string
    field :user_url, :string

    belongs_to :listing, Re.Listing,
      references: :uuid,
      foreign_key: :listing_uuid,
      type: Ecto.UUID

    belongs_to :user, Re.User,
      references: :uuid,
      foreign_key: :user_uuid,
      type: Ecto.UUID

    timestamps()
  end

  @required ~w(origin)a
  @optional ~w(name email location listing_uuid user_uuid budget neighborhood url user_url phone_number)a
  @params @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
