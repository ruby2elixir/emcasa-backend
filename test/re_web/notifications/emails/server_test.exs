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

    test "user_registered/1" do
      user = insert(:user)
      Server.handle_cast({UserEmail, :user_registered, [user]}, [])
      assert_email_sent(UserEmail.user_registered(user))
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

    test "price suggestion requested when price" do
      address = insert(:address)
      %{id: id} = request = insert(:price_suggestion_request, address: address, is_covered: false)

      Server.handle_info(
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
        UserEmail.price_suggestion_requested(
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

      Server.handle_info(
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
        UserEmail.price_suggestion_requested(
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
      user = insert(:user)
      address = insert(:address)

      %{id: id} =
        request =
        insert(:notify_when_covered,
          name: "naem",
          phone: "12321",
          email: "user@emcasa.com",
          message: "msg",
          address: address,
          user: user
        )

      Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"notifyWhenCovered" => %{"id" => id}}
            }
          }
        },
        []
      )

      assert_email_sent(
        UserEmail.notify_when_covered(%{
          name: request.name,
          email: request.email,
          phone: request.phone,
          message: request.message,
          address: %{
            street: address.street,
            street_number: address.street_number,
            city: address.city,
            state: address.state,
            neighborhood: address.neighborhood
          },
          user: %{
            name: user.name,
            phone: user.phone,
            email: user.email
          }
        })
      )
    end

    test "notify when covered requested and fallback to user info" do
      user = insert(:user)
      address = insert(:address)

      %{id: id} = insert(:notify_when_covered, address: address, user: user)

      Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"notifyWhenCovered" => %{"id" => id}}
            }
          }
        },
        []
      )

      assert_email_sent(
        UserEmail.notify_when_covered(%{
          name: user.name,
          email: user.email,
          phone: user.phone,
          message: nil,
          address: %{
            street: address.street,
            street_number: address.street_number,
            city: address.city,
            state: address.state,
            neighborhood: address.neighborhood
          },
          user: %{
            name: user.name,
            phone: user.phone,
            email: user.email
          }
        })
      )
    end

    test "notify when covered requested and fallback to user info but he doesn't have it" do
      user = insert(:user, email: nil, phone: nil, name: nil)
      address = insert(:address)

      %{id: id} = insert(:notify_when_covered, address: address, user: user)

      Server.handle_info(
        %Phoenix.Socket.Broadcast{
          payload: %{
            result: %{
              data: %{"notifyWhenCovered" => %{"id" => id}}
            }
          }
        },
        []
      )

      assert_email_sent(
        UserEmail.notify_when_covered(%{
          name: nil,
          email: nil,
          phone: nil,
          message: nil,
          address: %{
            street: address.street,
            street_number: address.street_number,
            city: address.city,
            state: address.state,
            neighborhood: address.neighborhood
          },
          user: %{
            name: user.name,
            phone: user.phone,
            email: user.email
          }
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

      Server.handle_info(
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
        UserEmail.tour_appointment(%{
          wants_pictures: true,
          wants_tour: true,
          options: [datetime1, datetime2],
          user: user,
          listing: listing
        })
      )
    end
  end
end
