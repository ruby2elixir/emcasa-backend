defmodule ReWeb.Types.Calendar do
  @moduledoc """
  GraphQL types for calendars
  """
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias ReWeb.Resolvers

  object :tour_appointment do
    field :id, :id
    field :wants_pictures, :boolean
    field :wants_tour, :boolean
    field :options, list_of(:datetime_option)

    field :user, :user, resolve: dataloader(Re.Accounts)
    field :listing, :listing, resolve: &Resolvers.Calendars.listings/3
  end

  input_object :tour_schedule_input do
    field :options, non_null(list_of(:datetime_option_input))
    field :wants_pictures, non_null(:boolean)
    field :wants_tour, non_null(:boolean)
    field :listing_id, non_null(:id)
  end

  object :datetime_option do
    field :datetime, non_null(:datetime)
  end

  input_object :datetime_option_input do
    field :datetime, non_null(:datetime)
  end

  object :calendar_queries do
    @desc "Get tour scheduling options"
    field :tour_options, list_of(:datetime), resolve: &Resolvers.Calendars.tour_options/2
  end

  object :calendar_mutations do
    @desc "Schedule Tour"
    field :tour_schedule, type: :tour_appointment do
      arg :input, non_null(:tour_schedule_input)

      resolve &Resolvers.Calendars.schedule_tour/2
    end
  end

  object :calendar_subscriptions do
    @desc "Subscribe to tour scheduling"
    field :tour_scheduled, :tour_appointment do
      config(fn _args, %{context: %{current_user: current_user}} ->
        case current_user do
          :system -> {:ok, topic: "tour_scheduled"}
          _ -> {:error, :unauthorized}
        end
      end)

      trigger :tour_schedule,
        topic: fn _ ->
          "tour_scheduled"
        end
    end
  end
end
