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
  @confirm_path "/confirmar_cadastro/"
  @reset_path "/resetar_senha/"

  def notify_interest(%Interest{
        name: name,
        email: email,
        phone: phone,
        message: message,
        listing_id: listing_id,
        interest_type: interest_type
      }) do
    new()
    |> to(@to)
    |> from(@from)
    |> subject("Novo interesse em listagem EmCasa")
    |> html_body(
      "Nome: #{name}<br> Email: #{email}<br> Telefone: #{phone}<br> Id da listagem: #{listing_id}<br> Mensagem: #{
        message
      } <br> #{interest_type && interest_type.name}"
    )
    |> text_body(
      "Nome: #{name}\n Email: #{email}\n Telefone: #{phone}\n Id da listagem: #{listing_id}<br> Mensagem: #{
        message
      } <br> #{interest_type && interest_type.name}"
    )
  end

  def confirm(%User{name: name, email: email, confirmation_token: token}) do
    confirm_url = build_url(@confirm_path, token)

    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Confirmação de cadastro na EmCasa")
    |> html_body("#{name}, confirme seu cadastro pelo link #{confirm_url}")
    |> text_body("#{name}, confirme seu cadastro pelo link #{confirm_url}")
  end

  def change_email(%User{name: name, email: email, confirmation_token: token}) do
    confirm_url = build_url(@confirm_path, token)

    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Mudança de e-mail na EmCasa")
    |> html_body("#{name}, confirme sua mudança de e-mail pelo link #{confirm_url}")
    |> text_body("#{name}, confirme sua mudança de e-mail pelo link #{confirm_url}")
  end

  def welcome(%User{name: name, email: email}) do
    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Bem-vindo à EmCasa, #{name}")
    |> html_body("Você se cadastrou no EmCasa.")
    |> text_body("Você se cadastrou no EmCasa.")
  end

  def reset_password(%User{name: name, email: email, reset_token: token}) do
    reset_url = build_url(@reset_path, token)

    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Redefinição de senha")
    |> html_body(
      "#{name}, você requisitou mudança de senha. Acesse: #{reset_url} para definir uma nova senha."
    )
    |> text_body(
      "#{name}, você requisitou mudança de senha. Acesse: #{reset_url} para definir uma nova senha."
    )
  end

  def build_url(path, param) do
    @frontend_url
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end
end
