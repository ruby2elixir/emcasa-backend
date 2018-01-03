defmodule Re.UserEmail do
  @moduledoc """
  Module for building e-mails to send to users
  """
  import Swoosh.Email

  @to String.split(Application.get_env(:re, :to), "|")
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
