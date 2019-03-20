defmodule Re.Development do
  @moduledoc """
  Module for land developments.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "developments" do
    field :name, :string
    field :title, :string
    field :phase, :string
    field :builder, :string
    field :description, :string

    belongs_to :address, Re.Address

    has_many :units, Re.Unit
    has_many :images, Re.Image
    has_many :listings, Re.Listing

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
    |> generate_uuid()
  end

  defp generate_uuid(%{data: %{uuid: nil}} = changeset) do
    Ecto.Changeset.change(changeset, %{uuid: UUID.uuid4()})
  end

  defp generate_uuid(changeset), do: changeset
end
