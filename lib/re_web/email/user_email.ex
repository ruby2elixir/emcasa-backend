defmodule ReWeb.UserEmail do
  @moduledoc """
  Module for building e-mails to send to users
  """
  import Swoosh.Email

  alias Re.{
    Listings.Interest,
    User
  }

  @to String.split(Application.get_env(:re, :to), "|")
  @from Application.get_env(:re, :from)
  @frontend_url Application.get_env(:re, :frontend_url)
  @admin_email "admin@emcasa.com"

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

  def confirm(%User{name: name, email: email, confirmation_token: token}) do
    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Confirmação de cadastro na EmCasa")
    |> html_body(
      "#{name}, confirme seu cadastro pelo link #{
        @frontend_url <> "/confirmar_cadastro/" <> token
      }"
    )
    |> text_body(
      "#{name}, confirme seu cadastro pelo link #{
        @frontend_url <> "/confirmar_cadastro/" <> token
      }"
    )
  end

  def welcome(%User{name: name, email: email}) do
    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Bem-vindo à EmCasa, #{name}")
    |> html_body("Você se cadastrou no EmCasa.")
    |> text_body("Você se cadastrou no EmCasa.")
  end
end
