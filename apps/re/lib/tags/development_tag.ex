defmodule Re.DevelopmentTag do
  @moduledoc """
  Model that resolve relation between development and tag.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false

  schema "developments_tags" do
    belongs_to :listing, Re.Development,
      type: Ecto.UUID,
      foreign_key: :development_uuid,
      references: :uuid,
      primary_key: true

    belongs_to :tag, Re.Tag,
      type: Ecto.UUID,
      foreign_key: :tag_uuid,
      references: :uuid,
      primary_key: true

    timestamps(type: :utc_datetime)
  end

  @params ~w(development_uuid tag_uuid)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
