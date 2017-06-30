defmodule Re.Listing do
  use Re.Web, :model

  schema "listings" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:description, :name])
    |> validate_required([:description, :name])
  end
end
