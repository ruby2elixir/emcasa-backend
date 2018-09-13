defmodule Re.Stats.ReportsTest do
  use Re.ModelCase

  import Re.Factory

  alias Re.Stats.Reports

  describe "users_to_be_notified/0" do
    test "get users with active listings only" do
      %{id: id1} = insert(:user, listings: [build(:listing)])
      insert(:user, listings: [build(:listing, is_active: false)])
      %{id: id3} = insert(:user, listings: [build(:listing, is_active: false), build(:listing)])
      insert(:user)

      assert [%{id: ^id1}, %{id: ^id3, listings: [_listing]}] = Reports.users_to_be_notified()
    end

    test "get users with email notifications enabled only" do
      %{id: id1} =
        insert(
          :user,
          notification_preferences: %{email: true, app: true},
          listings: [build(:listing)]
        )

      insert(
        :user,
        notification_preferences: %{email: false, app: true},
        listings: [build(:listing)]
      )

      %{id: id2} =
        insert(
          :user,
          notification_preferences: %{email: true, app: false},
          listings: [build(:listing)]
        )

      insert(
        :user,
        notification_preferences: %{email: false, app: false},
        listings: [build(:listing)]
      )

      assert [%{id: ^id1}, %{id: ^id2}] = Reports.users_to_be_notified()
    end

    test "do not get admins" do
      %{id: id} = insert(:user, listings: [build(:listing)])
      insert(:user, listings: [build(:listing)], role: "admin")

      assert [%{id: ^id}] = Reports.users_to_be_notified()
    end
  end

  describe "get_listings_stats/2" do
    test "get only last month's stats" do
      now = Timex.now()

      listing = insert(:listing)
      insert_list(5, :listing_visualisation, listing: listing)

      insert_list(
        5,
        :listing_visualisation,
        listing: listing,
        inserted_at: Timex.shift(now, months: -2)
      )

      insert_list(5, :tour_visualisation, listing: listing)

      insert_list(
        5,
        :tour_visualisation,
        listing: listing,
        inserted_at: Timex.shift(now, months: -2)
      )

      insert_list(5, :in_person_visit, listing: listing)

      insert_list(
        5,
        :in_person_visit,
        listing: listing,
        inserted_at: Timex.shift(now, months: -2)
      )

      insert_list(5, :listings_favorites, listing: listing)

      insert_list(
        5,
        :listings_favorites,
        listing: listing,
        inserted_at: Timex.shift(now, months: -2)
      )

      insert_list(5, :interest, listing: listing)
      insert_list(5, :interest, listing: listing, inserted_at: Timex.shift(now, months: -2))

      assert %{
               listings_visualisations_count: 5,
               tour_visualisations_count: 5,
               in_person_visits_count: 5,
               listings_favorites_count: 5,
               interests_count: 5
             } = Reports.get_listings_stats(listing, now)
    end
  end
end
