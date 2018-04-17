defmodule Re.Image do
  @moduledoc """
  Module for listing images.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "images" do
    field :filename, :string
    field :position, :integer
    field :is_active, :boolean, default: true
    field :description, :string

    belongs_to :listing, Re.Listing

    timestamps()
  end

  @create_required ~w(filename position)a
  @create_optional ~w(listing_id description)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @create_required ++ @create_optional)
    |> validate_required(@create_required)
  end

  @position_required ~w(position)a
  @position_optional ~w()a

  def position_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @position_required ++ @position_optional)
    |> validate_required(@position_required)
  end

  @delete_required ~w(is_active)a
  @delete_optional ~w()a

  def delete_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @delete_required ++ @delete_optional)
    |> validate_required(@delete_required)
  end
end
