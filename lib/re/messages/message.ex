defmodule Re.Message do
  @moduledoc """
  Module for messages between users.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "messages" do
    field :message, :string
    field :notified, :boolean
    field :read, :boolean

    belongs_to :sender, Re.User
    belongs_to :receiver, Re.User
    belongs_to :listing, Re.Listing
    belongs_to :channel, Re.Messages.Channel

    timestamps()
  end

  @required ~w(sender_id receiver_id)a
  @optional ~w(message notified read listing_id channel_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
