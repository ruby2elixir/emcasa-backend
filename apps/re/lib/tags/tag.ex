defmodule Re.Tag do
  @moduledoc """
  Model for tag value
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.Slugs

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "tags" do
    field :name, :string
    field :name_slug, :string
    field :category, :string

    many_to_many :listings, Re.Listing,
      join_through: Re.ListingTag,
      join_keys: [tag_uuid: :uuid, listing_uuid: :uuid],
      on_replace: :delete

    timestamps()
  end

  @required [:name, :category]

  @sluggified_attr [:name]

  @categories ~w(infrastructure location realty)

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> unique_constraint(:name_slug)
    |> validate_inclusion(:category, @categories,
      message: "should be one of: [#{Enum.join(@categories, ", ")}]"
    )
    |> generate_slugs()
    |> generate_uuid()
  end

  def generate_slugs(%{valid?: false} = changeset), do: changeset

  def generate_slugs(changeset) do
    Enum.reduce(@sluggified_attr, changeset, &Slugs.generate_slug(&1, &2))
  end

  def generate_uuid(%{data: %{uuid: nil}} = changeset) do
    change(changeset, %{uuid: UUID.uuid4()})
  end

  def generate_uuid(changeset), do: changeset
end
