defmodule ReWeb.ListingUserController do
  use ReWeb, :controller

  alias ReWeb.User
  alias ReWeb.ListingUser

  def create(conn, %{"user" => user_params, "listing" => listing_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset, on_conflict: :replace_all, conflict_target: :email) do
      {:ok, user} ->
        %{"id" => listing_id} = listing_params

        listing_user = %ReWeb.ListingUser{ user_id: user.id, listing_id: listing_id }
        Re.Repo.insert(listing_user)

        SendGrid.Email.build()
        |> SendGrid.Email.add_to("gustavo.saiani@emcasa.com")
        |> SendGrid.Email.add_to("gustavo.vaz@emcasa.com")
        |> SendGrid.Email.add_to("lucas.cardozo@emcasa.com")
        |> SendGrid.Email.add_to("camila.villanueva@emcasa.com")
        |> SendGrid.Email.put_from("gustavo.saiani@emcasa.com")
        |> SendGrid.Email.put_subject("Novo interesse em listagem EmCasa")
        |> SendGrid.Email.put_text("Nome: #{user.name}\n Email: #{user.email}\n Telefone: #{user.phone}\n Id da listagem: #{listing_id}")
        |> SendGrid.Mailer.send()

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
