defmodule ReWeb.Types.OwnerContact do
  @moduledoc """
  Graphql type for owner contact.
  """
  use Absinthe.Schema.Notation

  object :owner_contact do
    field :uuid, :uuid
    field :name, :string
    field :phone, :string
    field :email, :string
    field :additional_phones, list_of(:string)
    field :additional_emails, list_of(:string)
  end
end
