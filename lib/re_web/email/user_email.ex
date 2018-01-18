defmodule Re.UserEmail do
  @moduledoc """
  Module for building e-mails to send to users
  """
  import Swoosh.Email

  alias Re.Listings.Interest

  @to String.split(Application.get_env(:re, :to), "|")
  @from Application.get_env(:re, :from)

  def notify_interest(%Interest{
        name: name,
        email: email,
        phone: phone,
        message: message,
        listing_id: listing_id
      }) do
    new()
    |> to(@to)
    |> from(@from)
    |> subject("Novo interesse em listagem EmCasa")
    |> html_body(
      "Nome: #{name}<br> Email: #{email}<br> Telefone: #{phone}<br> Id da listagem: #{listing_id}<br> Mensagem: #{
        message
      }"
    )
    |> text_body(
      "Nome: #{name}\n Email: #{email}\n Telefone: #{phone}\n Id da listagem: #{listing_id}<br> Mensagem: #{
        message
      }"
    )
  end
end
