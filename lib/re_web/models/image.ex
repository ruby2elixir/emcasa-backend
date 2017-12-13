defmodule ReWeb.Image do
  @moduledoc """
  Module for listing images.
  """

  use ReWeb, :model

  schema "images" do
    field :filename, :string
    field :position, :integer
    belongs_to :listing, Re.Listing

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:filename, :position])
    |> validate_required([:filename, :position])
  end
end
