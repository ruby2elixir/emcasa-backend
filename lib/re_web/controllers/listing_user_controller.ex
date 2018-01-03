defmodule ReWeb.ListingUserController do
  use ReWeb, :controller
  use Guardian.Phoenix.Controller

  alias Re.{
    User,
    UserEmail,
    ListingUser,
    Mailer
  }

  plug Guardian.Plug.EnsureAuthenticated,
    %{handler: ReWeb.SessionController}
    when action in [:create]

  def create(conn, %{"user" => user_params, "listing" => %{"id" => listing_id}}, _user, _full_claims) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset, on_conflict: :replace_all, conflict_target: :email) do
      {:ok, user} ->
        listing_user = %ListingUser{user_id: user.id, listing_id: listing_id}
        Repo.insert(listing_user)

        user
        |> UserEmail.notify_interest(listing_id)
        |> Mailer.deliver()

        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ReWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
