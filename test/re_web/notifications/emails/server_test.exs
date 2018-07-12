defmodule ReWeb.Notifications.Emails.ServerTest do
  use Re.ModelCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.{
    Listing,
    Repo
  }

  alias ReWeb.Notifications.{
    Emails.Server,
    ReportEmail,
    UserEmail
  }

  describe "handle_cast/2" do
    test "notify_interest/1" do
      interest = insert(:interest, interest_type: build(:interest_type))
      Server.handle_cast({UserEmail, :notify_interest, [interest]}, [])
      interest = Repo.preload(interest, :interest_type)
      assert_email_sent(UserEmail.notify_interest(interest))
    end

    test "notify_interest/1 with online scheduling" do
      interest =
        insert(:interest, interest_type: build(:interest_type, name: "Agendamento online"))

      Server.handle_cast({UserEmail, :notify_interest, [interest]}, [])
      interest = Repo.preload(interest, :interest_type)
      email = UserEmail.notify_interest(interest)
      assert_email_sent(email)
      assert [{"", "contato@emcasa.com"}] == email.to
    end

    test "confirm/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :confirm, [user]}, [])
      assert_email_sent(UserEmail.confirm(user))
    end

    test "change_email/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :change_email, [user]}, [])
      assert_email_sent(UserEmail.change_email(user))
    end

    test "welcome/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :welcome, [user]}, [])
      assert_email_sent(UserEmail.welcome(user))
    end

    test "user_registered/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :user_registered, [user]}, [])
      assert_email_sent(UserEmail.user_registered(user))
    end

    test "reset_password/1" do
      user = insert(:user, reset_token: UUID.uuid4())
      Server.handle_cast({UserEmail, :reset_password, [user]}, [])
      assert_email_sent(UserEmail.reset_password(user))
    end

    test "listing_added/2" do
      user = insert(:user)
      listing = insert(:listing)
      Server.handle_cast({UserEmail, :listing_added, [user, listing]}, [])
      assert_email_sent(UserEmail.listing_added(user, listing))
    end

    test "listing_added/2 should not notify when user email is not confirmed" do
      user = insert(:user, confirmed: false)
      listing = insert(:listing)
      Server.handle_cast({UserEmail, :listing_added, user, listing}, [])
      assert_email_not_sent(UserEmail.listing_added(user, listing))
    end

    test "listing_added_admin/2" do
      user = insert(:user)
      listing = insert(:listing)
      Server.handle_cast({UserEmail, :listing_added_admin, [user, listing]}, [])
      assert_email_sent(UserEmail.listing_added_admin(user, listing))
    end

    test "listing_updated/2" do
      user = insert(:user)
      listing = insert(:listing, price: 950_000, rooms: 3)
      %{changes: changes} = Listing.changeset(listing, %{price: 1_000_000, rooms: 4}, "user")
      Server.handle_cast({UserEmail, :listing_updated, [user, listing, changes]}, [])
      assert_email_sent(UserEmail.listing_updated(user, listing, changes))
    end

    test "price_updated/2" do
      user1 = insert(:user)
      user2 = insert(:user)
      user3 = insert(:user, notification_preferences: %{email: false})
      user4 = insert(:user, confirmed: false)
      listing = insert(:listing, price: 950_000)
      insert(:listings_favorites, user: user1, listing: listing)
      insert(:listings_favorites, user: user2, listing: listing)
      insert(:listings_favorites, user: user3, listing: listing)
      insert(:listings_favorites, user: user4, listing: listing)

      Server.handle_cast({UserEmail, :price_updated, 1_000_000, listing}, [])
      assert_email_sent(UserEmail.price_updated(user1, 1_000_000, listing))
      assert_email_sent(UserEmail.price_updated(user2, 1_000_000, listing))
      assert_email_not_sent(UserEmail.price_updated(user3, 1_000_000, listing))
      assert_email_not_sent(UserEmail.price_updated(user4, 1_000_000, listing))
    end

    test "monthly_report/2" do
      user = insert(:user)
      listing1 =
        :listing
        |> build(user: user)
        |> Map.put(:listings_visualisations_count, 3)
        |> Map.put(:tour_visualisations_count, 2)
        |> Map.put(:in_person_visits_count, 4)
        |> Map.put(:listings_favorites_count, 5)
        |> Map.put(:interests_count, 8)

      listing2 =
        :listing
        |> build(user: user)
        |> Map.put(:listings_visualisations_count, 4)
        |> Map.put(:tour_visualisations_count, 12)
        |> Map.put(:in_person_visits_count, 4)
        |> Map.put(:listings_favorites_count, 3)
        |> Map.put(:interests_count, 0)

      Server.handle_cast({ReportEmail, :monthly_report, [user, [listing1, listing2]]}, [])
      assert_email_sent(ReportEmail.monthly_report(user, [listing1, listing2]))
    end
  end

  describe "handle_info/2" do
    test "contact requested by anonymous" do
      %{id: id} =
        insert(
          :contact_request,
          name: "mahname",
          email: "mahemail@emcasa.com",
          phone: "123321123",
          message: "cool website"
        )

      Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{result: %{data: %{"contactRequested" => %{"id" => id}}}}
        },
        []
      )

      assert_email_sent(
        UserEmail.contact_request(%{
          name: "mahname",
          email: "mahemail@emcasa.com",
          phone: "123321123",
          message: "cool website"
        })
      )
    end

    test "contact requested by user" do
      user = insert(:user)
      %{id: id} = insert(:contact_request, message: "cool website", user: user)

      Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{result: %{data: %{"contactRequested" => %{"id" => id}}}}
        },
        []
      )

      assert_email_sent(
        UserEmail.contact_request(%{
          name: user.name,
          email: user.email,
          phone: user.phone,
          message: "cool website"
        })
      )
    end

    test "contact requested by user with new email" do
      user = insert(:user)

      %{id: id} =
        insert(
          :contact_request,
          message: "cool website",
          user: user,
          email: "different@email.com"
        )

      Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{result: %{data: %{"contactRequested" => %{"id" => id}}}}
        },
        []
      )

      assert_email_sent(
        UserEmail.contact_request(%{
          name: user.name,
          email: "different@email.com",
          phone: user.phone,
          message: "cool website"
        })
      )
    end
  end
end
