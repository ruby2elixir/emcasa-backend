defmodule Re.Development do
  @moduledoc """
  Module for land developments.
  """

  use Ecto.Schema

  import Ecto.Changeset

  schema "developments" do
    field :name, :string
    field :title, :string
    field :status, :string
    field :builder, :string
    field :description, :string
    belongs_to :address, Re.Address

    timestamps()
  end

  @statuses ~w(pre-launch planning building delivered)

  @required ~w(name title status builder description address_id)a

  def changeset(struct, params) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_inclusion(:status, @statuses,
      message: "should be one of: [#{Enum.join(@statuses, " ")}]"
    )
  end
end
