defmodule Re.UserEmail do
  import Swoosh.Email

  alias Re.Mailer

  @to Application.get_env(:re, :to) |> String.split("|")
  @from Application.get_env(:re, :from)

  def notify_interest(user, listing_id) do
    new()
    |> to(@to)
    |> from(@from)
    |> subject("Novo interesse em listagem EmCasa")
    |> html_body("Nome: #{user.name}<br> Email: #{user.email}<br> Telefone: #{user.phone}<br> Id da listagem: #{listing_id}")
    |> text_body("Nome: #{user.name}\n Email: #{user.email}\n Telefone: #{user.phone}\n Id da listagem: #{listing_id}")
  end
end
