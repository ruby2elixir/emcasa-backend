defmodule Re.Messages.Channels.Channel do
  @moduledoc """
  Module for grouping messages into a channel.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "channels" do
    belongs_to :participant1, Re.User
    belongs_to :participant2, Re.User
    belongs_to :listing, Re.Listing

    has_many :messages, Re.Message

    timestamps()
  end

  @attributes ~w(participant1_id participant2_id listing_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @attributes)
    |> validate_required(@attributes)
    |> unique_constraint(:listing_id, name: :topic)
  end
end
