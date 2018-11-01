defmodule ReIntegrations.Notifications.Emails.ServerTest do
  use Re.ModelCase

  import Re.Factory
  import Swoosh.TestAssertions

  alias Re.{
    Listing,
    Repo
  }

  alias ReIntegrations.Notifications.Emails

  describe "handle_cast/2" do
    test "notify_interest/1" do
      interest = insert(:interest, interest_type: build(:interest_type))
      Emails.Server.handle_cast({Emails.User, :notify_interest, [interest]}, [])
      interest = Repo.preload(interest, :interest_type)
      assert_email_sent(Emails.User.notify_interest(interest))
    end

    test "notify_interest/1 with online scheduling" do
      interest =
        insert(:interest, interest_type: build(:interest_type, name: "Agendamento online"))

      Emails.Server.handle_cast({Emails.User, :notify_interest, [interest]}, [])
      interest = Repo.preload(interest, :interest_type)
      email = Emails.User.notify_interest(interest)
      assert_email_sent(email)
      assert [{"", "contato@emcasa.com"}] == email.to
    end

    test "user_registered/1" do
      user = insert(:user)
      Emails.Server.handle_cast({Emails.User, :user_registered, [user]}, [])
      assert_email_sent(Emails.User.user_registered(user))
    end

    test "listing_added_admin/2" do
      user = insert(:user)
      listing = insert(:listing)
      Emails.Server.handle_cast({Emails.User, :listing_added_admin, [user, listing]}, [])
      assert_email_sent(Emails.User.listing_added_admin(user, listing))
    end

    test "listing_updated/2" do
      user = insert(:user)
      listing = insert(:listing, price: 950_000, rooms: 3)
      %{changes: changes} = Listing.changeset(listing, %{price: 1_000_000, rooms: 4}, "user")
      Emails.Server.handle_cast({Emails.User, :listing_updated, [user, listing, changes]}, [])
      assert_email_sent(Emails.User.listing_updated(user, listing, changes))
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

      Emails.Server.handle_cast(
        {Emails.Report, :monthly_report, [user, [listing1, listing2]]},
        []
      )

      assert_email_sent(Emails.Report.monthly_report(user, [listing1, listing2]))
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

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{result: %{data: %{"contactRequested" => %{"id" => id}}}}
        },
        []
      )

      assert_email_sent(
        Emails.User.contact_request(%{
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

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{result: %{data: %{"contactRequested" => %{"id" => id}}}}
        },
        []
      )

      assert_email_sent(
        Emails.User.contact_request(%{
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

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{result: %{data: %{"contactRequested" => %{"id" => id}}}}
        },
        []
      )

      assert_email_sent(
        Emails.User.contact_request(%{
          name: user.name,
          email: "different@email.com",
          phone: user.phone,
          message: "cool website"
        })
      )
    end

    test "price suggestion requested when price" do
      address = insert(:address)
      %{id: id} = request = insert(:price_suggestion_request, address: address, is_covered: false)

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"priceSuggestionRequested" => %{"id" => id, "suggestedPrice" => 10.10}}
            }
          }
        },
        []
      )

      assert_email_sent(
        Emails.User.price_suggestion_requested(
          %{
            name: request.name,
            email: request.email,
            area: request.area,
            rooms: request.rooms,
            bathrooms: request.bathrooms,
            garage_spots: request.garage_spots,
            address: %{
              street: address.street,
              street_number: address.street_number
            },
            is_covered: false
          },
          10.10
        )
      )
    end

    test "price suggestion requested for not covered street" do
      address = insert(:address)
      %{id: id} = request = insert(:price_suggestion_request, address: address, is_covered: true)

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"priceSuggestionRequested" => %{"id" => id, "suggestedPrice" => nil}}
            }
          }
        },
        []
      )

      assert_email_sent(
        Emails.User.price_suggestion_requested(
          %{
            name: request.name,
            email: request.email,
            area: request.area,
            rooms: request.rooms,
            bathrooms: request.bathrooms,
            garage_spots: request.garage_spots,
            address: %{
              street: address.street,
              street_number: address.street_number
            },
            is_covered: true
          },
          nil
        )
      )
    end

    test "notify when covered requested" do
      %{id: id} =
        request =
        insert(:notify_when_covered,
          name: "naem",
          phone: "12321",
          email: "user@emcasa.com",
          message: "msg",
          state: "SP",
          city: "São Pauo",
          neighborhood: "Morumbi"
        )

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"notificationCoverageAsked" => %{"id" => id}}
            }
          }
        },
        []
      )

      assert_email_sent(
        Emails.User.notification_coverage_asked(%{
          name: request.name,
          email: request.email,
          phone: request.phone,
          message: request.message,
          state: request.state,
          city: request.city,
          neighborhood: request.neighborhood,
        })
      )
    end

    test "should notify when user schedules a tour appointment" do
      datetime1 = %Re.Calendars.Option{datetime: ~N[2018-05-29 10:00:00]}
      datetime2 = %Re.Calendars.Option{datetime: ~N[2018-05-29 11:00:00]}
      user = insert(:user)
      listing = insert(:listing, user: user)

      %{id: tour_appointment_id} =
        insert(:tour_appointment,
          wants_pictures: true,
          wants_tour: true,
          options: [datetime1, datetime2],
          listing: listing,
          user: user
        )

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"tourScheduled" => %{"id" => tour_appointment_id}}
            }
          }
        },
        []
      )

      assert_email_sent(
        Emails.User.tour_appointment(%{
          wants_pictures: true,
          wants_tour: true,
          options: [datetime1, datetime2],
          user: user,
          listing: listing
        })
      )
    end

    test "should notify when user shows interest in a listing" do
      interest_type = insert(:interest_type)
      listing = insert(:listing)

      %{id: interest_id} =
        interest = insert(:interest, listing: listing, interest_type: interest_type)

      Emails.Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"interestCreated" => %{"id" => interest_id}}
            }
          }
        },
        []
      )

      assert_email_sent(Emails.User.notify_interest(interest))
    end
  end
end
