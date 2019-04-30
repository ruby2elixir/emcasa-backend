defmodule Re.Development do
  @moduledoc """
  Module for land developments.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "developments" do
    field :name, :string
    field :phase, :string
    field :builder, :string
    field :description, :string
    field :floor_count, :integer
    field :units_per_floor, :integer
    field :elevators, :integer

    belongs_to :address, Re.Address

    has_many :units, Re.Unit
    has_many :images, Re.Image
    has_many :listings, Re.Listing

    timestamps()
  end

  @phases ~w(pre-launch planning building delivered)

  @required ~w(name phase builder description address_id)a

  @optional ~w(floor_count units_per_floor elevators)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:phase, @phases,
      message: "should be one of: [#{Enum.join(@phases, " ")}]"
    )
    |> Re.ChangesetHelper.generate_uuid()
  end
end
