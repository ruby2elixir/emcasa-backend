defmodule ReWeb.Notifications.UserEmail do
  @moduledoc """
  Module for building e-mails to send to users
  """
  import Swoosh.Email

  alias Re.{
    Interest,
    Listing,
    User
  }

  @to String.split(Application.get_env(:re, :to), "|")
  @from Application.get_env(:re, :from)
  @frontend_url Application.get_env(:re, :frontend_url)
  @admin_email "admin@emcasa.com"
  @contato_email "contato@emcasa.com"
  @confirm_path "/confirmar_cadastro/"
  @reset_path "/resetar_senha/"
  @listing_path "/imoveis/"
  @profile_path "/meu-perfil"

  def notify_interest(%Interest{
        name: name,
        email: email,
        phone: phone,
        message: message,
        listing_id: listing_id,
        interest_type: interest_type,
        inserted_at: inserted_at
      }) do
    new()
    |> to(get_to_email(interest_type))
    |> from(@from)
    |> subject("Novo interesse em listagem EmCasa")
    |> html_body(
      "Nome: #{name}<br> Email: #{email}<br> Telefone: #{phone}<br> Id da listagem: #{listing_id}<br> Mensagem: #{
        message
      } <br> #{interest_type && interest_type.name}
        <br> Inserido em (UTC): #{inserted_at}"
    )
    |> text_body(
      "Nome: #{name}\n Email: #{email}\n Telefone: #{phone}\n Id da listagem: #{listing_id}<br> Mensagem: #{
        message
      } <br> #{interest_type && interest_type.name}
        <br> Inserido em (UTC): #{inserted_at}"
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

  def user_registered(%User{name: name}) do
    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Novo usuário cadastrado")
    |> html_body("Um novo usuário realizou cadastro no EmCasa.<br>
      Nome: #{name}")
    |> text_body("Um novo usuário realizou cadastro no EmCasa.
      Nome: #{name}")
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

  def listing_added(%User{name: name, email: email}, %Listing{} = listing) do
    listing_url = build_url(@listing_path, to_string(listing.id))

    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Seu imóvel foi pré-cadastrado")
    |> html_body("Olá, #{name}.<br>
                  Já fomos notificados sobre seu pré-cadastro de imóvel.<br>
                  Ele não está visível publicamente, <a href=\"#{listing_url}\">clique aqui</a> para ver uma prévia.<br>
                  Em breve entraremos em contato.<br>
                  Equipe EmCasa")
    |> text_body("Olá, #{name}.
                  Já fomos notificados sobre seu pré-cadastro de imóvel.
                  Ele não está visível publicamente, clique no link a seguir para ver uma prévia:
                  #{listing_url}
                  Em breve entraremos em contato.
                  Equipe EmCasa")
  end

  def listing_added_admin(%User{name: name, email: email}, %Listing{} = listing) do
    listing_url = build_url(@listing_path, to_string(listing.id))

    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário cadastrou um imóvel")
    |> html_body("Nome: #{name}<br>
                  Email: #{email}<br>
                  <a href=\"#{listing_url}\">Imóvel</a><br>")
    |> text_body("Nome: #{name}
                  Email: #{email}
                  <a href=\"#{listing_url}\">Imóvel</a>")
  end

  def listing_updated(%User{name: name, email: email}, %Listing{} = listing, changes) do
    listing_url = build_url(@listing_path, to_string(listing.id))
    {changes_html, changes_txt} = build_changes(changes)

    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário modificou o imóvel")
    |> html_body("Nome: #{name}<br>
                  Email: #{email}<br>
                  <a href=\"#{listing_url}\">Imóvel</a><br>
                  #{changes_html}")
    |> text_body("Nome: #{name}
                  Email: #{email}
                  <a href=\"#{listing_url}\">Imóvel</a>
                  #{changes_txt}")
  end

  defp build_changes(changes) do
    {Enum.map(changes, fn {attr, value} -> "Atributo: #{attr}, novo valor: #{value}<br>" end),
     Enum.map(changes, fn {attr, value} -> "Atributo: #{attr}, novo valor: #{value}" end)}
  end

  def price_updated(%User{name: name, email: email}, new_price, listing) do
    listing_url = build_url(@listing_path, to_string(listing.id))

    new()
    |> to(email)
    |> from(@admin_email)
    |> subject("Um imóvel que você favoritou teve alteração de preço")
    |> html_body("Olá, #{name}<br>
                  Um imóvel que você favoritou na EmCasa sofreu alteração de preço<br>
                  Novo preço: #{CurrencyFormatter.format(new_price * 100, "BRL")}<br>
                  <a href=\"#{listing_url}\">Confira</a><br>")
    |> text_body("Olá, #{name}
                  Um imóvel que você favoritou na EmCasa sofreu alteração de preço
                  Novo preço: #{CurrencyFormatter.format(new_price * 100, "BRL")}
                  <a href=\"#{listing_url}\">Confira</a>")
  end

  defp get_to_email(%{name: "Agendamento online"}), do: @contato_email
  defp get_to_email(_), do: @to

  def contact_request(%{name: name, email: email, phone: phone, message: message}) do
    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário requisitou contato pela calculadora")
    |> html_body("Nome: #{name}<br>
                  Email: #{email}<br>
                  Telefone: #{phone}<br>
                  Mensagem: #{message}")
    |> text_body("Nome: #{name}
                  Email: #{email}
                  Telefone: #{phone}
                  Mensagem: #{message}")
  end

  def price_suggestion_requested(request, suggested_price) do
    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário requisitou sugestão de preço pelo lead magnet")
    |> html_body("Nome: #{request.name}<br>
                  Email: #{request.email}<br>
                  Area: #{request.area}<br>
                  Quartos: #{request.rooms}<br>
                  Banheiros: #{request.bathrooms}<br>
                  Vagas: #{request.garage_spots}<br>
                  Rua: #{request.address.street}<br>
                  Número: #{request.address.street_number}<br>
                  #{unless request.is_covered, do: "Área fora de cobertura"}<br>
                  Preço sugerido: #{suggested_price || "Rua não coberta"}")
    |> text_body("Nome: #{request.name}
                  Email: #{request.email}
                  Area: #{request.area}
                  Quartos: #{request.rooms}
                  Banheiros: #{request.bathrooms}
                  Vagas: #{request.garage_spots}
                  Rua: #{request.address.street}
                  Número: #{request.address.street_number}
                  #{unless request.is_covered, do: "Área fora de cobertura"}
                  Preço sugerido: #{suggested_price || "Rua não coberta"}")
  end

  def message_sent(%{email: sender_email}, %{email: receiver_email}, message) do
    url = build_url(@profile_path, "")

    new()
    |> to(receiver_email)
    |> from(sender_email)
    |> subject("Você recebeu uma nova mensagem")
    |> html_body("Mensagem: #{message}<br>
                  De: #{sender_email}<br>
                  Se você não quer mais receber e-mails, desabilite suas notificações <a href=\"#{url}\">no seu perfil</a><br>")
    |> text_body("""
      Mensagem: #{message}
      De: #{sender_email}
      Se você não quer mais receber e-mails, desabilite suas notificações <a href=\"#{url}\">no seu perfil</a><br>
      """)
  end
end
