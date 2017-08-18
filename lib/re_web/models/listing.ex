defmodule ReWeb.Listing do
  @moduledoc """
  Model for listings, that is, each apartment or real estate piece on sale.
  """

  use Re.Web, :model

  schema "listings" do
    field :description, :string
    field :name, :string
    field :rooms, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:description, :name, :rooms])
    |> validate_required([:description, :name])
  end
end
