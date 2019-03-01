defmodule Re.Development do
  @moduledoc """
  Module for land developments.
  """

  use Ecto.Schema

  import Ecto.Changeset

  schema "developments" do
    field :name, :string
    field :title, :string
    field :phase, :string
    field :builder, :string
    field :description, :string

    belongs_to :address, Re.Address
    has_many :images, Re.Image

    timestamps()
  end

  @phases ~w(pre-launch planning building delivered)

  @required ~w(name title phase builder description address_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_inclusion(:phase, @phases,
      message: "should be one of: [#{Enum.join(@phases, " ")}]"
    )
  end
end
