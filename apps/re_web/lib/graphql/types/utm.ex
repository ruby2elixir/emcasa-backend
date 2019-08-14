defmodule ReWeb.Types.Utm do
  @moduledoc """
  GraphQL types for utm
  """
  use Absinthe.Schema.Notation

  object :utm do
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string
  end

  input_object :input_utm do
    field :campaign, :string
    field :medium, :string
    field :source, :string
    field :initial_campaign, :string
    field :initial_medium, :string
    field :initial_source, :string
  end
end
