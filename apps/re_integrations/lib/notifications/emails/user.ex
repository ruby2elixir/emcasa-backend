defmodule ReIntegrations.Notifications.Emails.User do
  @moduledoc """
  Module for building e-mails to send to users
  """
  import Swoosh.Email

  alias Re.{
    Calendars,
    Interest,
    Listing,
    User
  }

  @to String.split(Application.get_env(:re_integrations, :to), "|")
  @from Application.get_env(:re_integrations, :from)
  @frontend_url Application.get_env(:re_integrations, :frontend_url)
  @admin_email "admin@emcasa.com"
  @contato_email "contato@emcasa.com"
  @listing_path "/imoveis/"

  def notify_interest(%Interest{
        name: name,
        email: email,
        phone: phone,
        message: message,
        listing: listing = %{address: address},
        inserted_at: inserted_at
      }) do
    new()
    |> to(@contato_email)
    |> from(@from)
    |> subject("Novo interesse em listagem EmCasa")
    |> html_body("Nome: #{name}<br>
        Email: #{email}<br>
        Telefone: #{phone}<br>
        Id da listagem: #{listing.id}<br>
        Valor: #{listing.price}<br>
        Cidade: #{address.city}<br>
        Bairro: #{address.neighborhood}<br>
        Mensagem: #{message} <br>
        Inserido em (UTC): #{inserted_at}")
    |> text_body("Nome: #{name}\n
        Email: #{email}\n
        Telefone: #{phone}\n
        Id da listagem: #{listing.id}\n
        Valor: #{listing.price}\n
        Cidade: #{address.city}\n
        Bairro: #{address.neighborhood}\n
        Mensagem: #{message} \n
        Inserido em (UTC): #{inserted_at}")
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

  def build_url(path, param) do
    @frontend_url
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end

  def listing_added_admin(%User{name: name, email: email, phone: phone}, %Listing{} = listing) do
    listing_url = build_url(@listing_path, to_string(listing.id))

    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário cadastrou um imóvel")
    |> html_body("Nome: #{name}<br>
                  Email: #{email}<br>
                  Telefone: #{phone}<br>
                  <a href=\"#{listing_url}\">Imóvel</a><br>")
    |> text_body("Nome: #{name}
                  Email: #{email}
                  Telefone: #{phone}
                  <a href=\"#{listing_url}\">Imóvel</a>")
  end

  def listing_updated(listing, user, changes) do
    listing_url = build_url(@listing_path, to_string(listing.id))
    {changes_html, changes_txt} = build_changes(changes)

    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário modificou o imóvel")
    |> html_body("Nome: #{user.name}<br>
                  Email: #{user.email || "sem e-mail"}<br>
                  Telefone: #{user.phone || "sem telefone"}<br>
                  <a href=\"#{listing_url}\">Imóvel</a><br>
                  #{changes_html}")
    |> text_body("Nome: #{user.name}\n
                  Email: #{user.email || "sem e-mail"}\n
                  Telefone: #{user.phone || "sem telefone"}\n
                  <a href=\"#{listing_url}\">Imóvel</a>
                  #{changes_txt}")
  end

  def new_site_seller_lead(
        %{price_request: %{user: user, address: address} = price_request} = site_lead
      ) do
    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Novo seller lead de #{address.city}, #{address.state} em #{address.neighborhood}")
    |> html_body("Nome: #{user.name}<br>
                  Email: #{user.email}<br>
                  Telefone: #{user.phone}<br>
                  Área: #{price_request.area}<br>
                  Quartos: #{price_request.rooms}<br>
                  Banheiros: #{price_request.bathrooms}<br>
                  Vagas: #{price_request.garage_spots}<br>
                  Rua: #{address.street}<br>
                  Número: #{address.street_number}<br>
                  Complemento: #{site_lead.complement}<br>
                  Bairro: #{address.neighborhood}<br>
                  Cidade: #{address.city}<br>
                  Estado: #{address.state}<br>
                  CEP: #{address.postal_code}<br>
                  Preço: #{site_lead.price}<br>
                  Condomínio: #{site_lead.maintenance_fee}<br>
                  ")
    |> text_body("Nome: #{user.name}
                  Email: #{user.email}
                  Telefone: #{user.phone}
                  Área: #{price_request.area}
                  Quartos: #{price_request.rooms}
                  Banheiros: #{price_request.bathrooms}
                  Vagas: #{price_request.garage_spots}
                  Rua: #{address.street}
                  Número: #{address.street_number}
                  Bairro: #{address.neighborhood}
                  Cidade: #{address.city}
                  Estado: #{address.state}
                  CEP: #{address.postal_code}
                  Preço: #{site_lead.price}
                  Condomínio: #{site_lead.maintenance_fee}
                  ")
  end

  defp build_changes(changes) do
    {Enum.map(changes, fn {attr, value} -> "Atributo: #{attr}, novo valor: #{value}<br>" end),
     Enum.map(changes, fn {attr, value} -> "Atributo: #{attr}, novo valor: #{value}" end)}
  end

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

  def notification_coverage_asked(%{
        name: name,
        email: email,
        phone: phone,
        message: message,
        state: state,
        city: city,
        neighborhood: neighborhood
      }) do
    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário pediu pra ser notificado quando cobrirmos uma região")
    |> html_body("Nome: #{name}<br>
                  Email: #{email}<br>
                  Telefone: #{phone}<br>
                  Mensagem: #{message}<br>
                  Cidade: #{city}<br>
                  Estado: #{state}<br>
                  Bairro: #{neighborhood}<br>")
    |> text_body("Nome: #{name}
                  Email: #{email}
                  Telefone: #{phone}
                  Mensagem: #{message}
                  Cidade: #{city}
                  Estado: #{state}
                  Bairro: #{neighborhood}")
  end

  def tour_appointment(%{
        wants_pictures: wants_pictures,
        wants_tour: wants_tour,
        options: options,
        user: user,
        site_seller_lead: %{price_request: %{address: address} = price_request} = site_seller_lead
      }) do
    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário pediu concluir a inserção do imóvel")
    |> html_body("Nome: #{user.name}<br>
                  Telefone: #{user.phone}<br>
                  #{wants_pictures(wants_pictures)}<br>
                  #{wants_tour(wants_tour)}<br>
                  Área: #{price_request.area}<br>
                  Quartos: #{price_request.rooms}<br>
                  Banheiros: #{price_request.bathrooms}<br>
                  Vagas: #{price_request.garage_spots}<br>
                  Rua: #{address.street}<br>
                  Número: #{address.street_number}<br>
                  Bairro: #{address.neighborhood}<br>
                  Cidade: #{address.city}<br>
                  Estado: #{address.state}<br>
                  CEP: #{address.postal_code}<br>
                  Preço: #{site_seller_lead.price}<br>
                  Opções de horário: #{options(options)}")
    |> text_body("Nome: #{user.name}<br>
                  Telefone: #{user.phone}<br>
                  #{wants_pictures(wants_pictures)}<br>
                  #{wants_tour(wants_tour)}<br>
                  Área: #{price_request.area}<br>
                  Quartos: #{price_request.rooms}<br>
                  Banheiros: #{price_request.bathrooms}<br>
                  Vagas: #{price_request.garage_spots}<br>
                  Rua: #{address.street}<br>
                  Número: #{address.street_number}<br>
                  Bairro: #{address.neighborhood}<br>
                  Cidade: #{address.city}<br>
                  Estado: #{address.state}<br>
                  CEP: #{address.postal_code}<br>
                  Preço: #{site_seller_lead.price}<br>
                  Opções de horário: #{options(options)}")
  end

  defp wants_pictures(true), do: "Foto profissional: <b>Sim</b>"
  defp wants_pictures(false), do: "Foto profissional: <b>Não</b>"
  defp wants_tour(true), do: "Tour 3D: <b>Sim</b>"
  defp wants_tour(false), do: "Tour 3D: <b>Não</b>"

  defp options(options) do
    options
    |> Enum.map(fn %{datetime: datetime} -> Calendars.format_datetime(datetime) end)
    |> Enum.join("<br>\n")
  end

  def price_suggestion_requested(%{user: user} = request, suggested_price) do
    new()
    |> to(@to)
    |> from(@admin_email)
    |> subject("Um usuário requisitou sugestão de preço pelo lead magnet")
    |> html_body("Nome: #{request.name}<br>
                  Phone: #{user.phone}<br>
                  Area: #{request.area}<br>
                  Quartos: #{request.rooms}<br>
                  Banheiros: #{request.bathrooms}<br>
                  Vagas: #{request.garage_spots}<br>
                  Suítes: #{request.suites}<br>
                  Tipo: #{request.type}<br>
                  Condomínio: #{request.maintenance_fee}<br>
                  Rua: #{request.address.street}<br>
                  Número: #{request.address.street_number}<br>
                  #{unless request.is_covered, do: "Área fora de cobertura"}<br>
                  Preço sugerido: #{suggested_price || "Rua não coberta"}")
    |> text_body("Nome: #{request.name}
                  Phone: #{user.phone}
                  Area: #{request.area}
                  Quartos: #{request.rooms}
                  Banheiros: #{request.bathrooms}
                  Vagas: #{request.garage_spots}
                  Suítes: #{request.suites}
                  Tipo: #{request.type}
                  Condomínio: #{request.maintenance_fee}
                  Rua: #{request.address.street}
                  Número: #{request.address.street_number}
                  #{unless request.is_covered, do: "Área fora de cobertura"}
                  Preço sugerido: #{suggested_price || "Rua não coberta"}")
  end
end
