defmodule Re.SellerLeads.JobQueueTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory
  import Re.CustomAssertion

  alias Re.{
    PriceSuggestions.Request,
    Repo,
    SellerLead,
    SellerLeads.JobQueue,
    User
  }

  alias Ecto.Multi

  describe "price_suggestion_request" do
    test "process lead" do
      %{uuid: address_uuid} = address = insert(:address)
      %{uuid: user_uuid} = user = insert(:user)

      %{uuid: uuid} =
        price_suggestion_request =
        insert(:price_suggestion_request,
          address: address,
          user: user
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "create_lead_salesforce")
      assert seller.uuid
      assert seller.user_uuid == user_uuid
      assert seller.address_uuid == address_uuid
      assert seller.source == "WebSite"
      assert seller.complement == nil
      assert seller.type == price_suggestion_request.type
      assert seller.area == price_suggestion_request.area
      assert seller.maintenance_fee == price_suggestion_request.maintenance_fee
      assert seller.rooms == price_suggestion_request.rooms
      assert seller.bathrooms == price_suggestion_request.bathrooms
      assert seller.suites == price_suggestion_request.suites
      assert seller.garage_spots == price_suggestion_request.garage_spots
      assert seller.price == nil
      assert seller.suggested_price == price_suggestion_request.suggested_price

      assert request = Repo.get_by(Request, uuid: uuid)
      assert request.seller_lead_uuid == seller.uuid
    end

    test "save name in user when nil" do
      address = insert(:address)
      %{uuid: user_uuid} = user = insert(:user, name: nil)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          name: "mah name",
          address: address,
          user: user
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "create_lead_salesforce")
      assert user = Repo.get_by(User, uuid: user_uuid)
      assert user.name == "mah name"
    end

    test "save email in user when nil" do
      address = insert(:address)
      %{uuid: user_uuid} = user = insert(:user, email: nil)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          email: "mahemail@emcasa.com",
          address: address,
          user: user
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "create_lead_salesforce")
      assert user = Repo.get_by(User, uuid: user_uuid)
      assert user.email == "mahemail@emcasa.com"
    end

    test "should mark as duplicated when another lead with same address and complement exists" do
      address = insert(:address)
      user = insert(:user)

      insert(:seller_lead, address: address, complement: nil)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          address: address,
          user: user
        )

      assert {:ok, %{insert_seller_lead: seller}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller.duplicated == "almost_sure"
      assert Kernel.length(seller.duplicated_entities) == 1
    end

    test "should not mark as duplicated when another lead with other address and complement exists" do
      address = insert(:address)
      user = insert(:user)

      %{uuid: uuid} =
        insert(:price_suggestion_request,
          address: address,
          user: user
        )

      assert {:ok, %{insert_seller_lead: seller}} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_price_suggestion_request",
                 "uuid" => uuid
               })

      assert seller.duplicated == "maybe"
      assert Kernel.length(seller.duplicated_entities) == 0
    end
  end

  describe "site_seller_lead" do
    test "process lead" do
      %{uuid: uuid} =
        site_seller_lead =
        insert(:site_seller_lead,
          price_request:
            build(:price_suggestion_request,
              seller_lead: build(:seller_lead),
              address: build(:address),
              user: build(:user)
            )
        )

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "process_site_seller_lead",
                 "uuid" => uuid
               })

      assert seller_lead = Repo.one(SellerLead)
      assert_enqueued_job(Repo.all(JobQueue), "update_lead_salesforce")
      assert seller_lead.uuid
      assert seller_lead.complement == site_seller_lead.complement
      assert seller_lead.type == site_seller_lead.type
      assert seller_lead.maintenance_fee == site_seller_lead.maintenance_fee
      assert seller_lead.suites == site_seller_lead.suites
      assert seller_lead.price == site_seller_lead.price
    end
  end

  describe "create_lead_salesforce" do
    @uri %URI{path: "/api/v1/Lead"}

    test "create lead" do
      mock(
        HTTPoison,
        :post,
        {:ok, %{status_code: 200, body: ~s({"id": "0x01","success": true,"errors": []})}}
      )

      seller_lead =
        insert(:seller_lead,
          user: build(:user, phone: "+11999999999"),
          address: build(:address),
          tour_option: ~N[2018-09-24 09:00:00],
          inserted_at: ~N[2018-09-24 09:00:00]
        )

      body =
        ~s({) <>
          ~s("Bairro__c":"#{seller_lead.address.neighborhood}",) <>
          ~s("City":"#{seller_lead.address.city}",) <>
          ~s("Probabilidade_de_Duplicidade__c":null,) <>
          ~s("Street":"#{seller_lead.address.street}",) <>
          ~s("uuid__c":"#{seller_lead.uuid}",) <>
          ~s("RecordTypeId":"0x01",) <>
          ~s("Data_de_Criacao_do_Lead__c":"2018-09-24T09:00:00Z",) <>
          ~s("LastName":"#{seller_lead.user.name}",) <>
          ~s("Numero_de_Banheiros__c":#{seller_lead.bathrooms},) <>
          ~s("Estado_do_Imovel__c":"#{seller_lead.address.state}",) <>
          ~s("Cidade_do_Imovel__c":"#{seller_lead.address.city}",) <>
          ~s("Imovel_de_Interesse__c":null,) <>
          ~s("Complemento__c":"#{seller_lead.complement}",) <>
          ~s("Rua_do_Imovel__c":"#{seller_lead.address.street}",) <>
          ~s("Email":"#{seller_lead.user.email}",) <>
          ~s("CEP__c":"#{seller_lead.address.postal_code}",) <>
          ~s("Nome_Completo2__c":"#{seller_lead.user.name}",) <>
          ~s("Numero_de_Quartos__c":#{seller_lead.rooms},) <>
          ~s("Range_de_Compra__c":null,) <>
          ~s("Tipo_do_Imovel__c":"#{seller_lead.type}",) <>
          ~s("Tipo_de_Lead__c":"Venda",) <>
          ~s("Valor_do_Imovel__c":#{seller_lead.price || seller_lead.suggested_price},) <>
          ~s("Avaliacao_do_Imovel__c":true,) <>
          ~s("Numero_do_Imovel__c":"#{seller_lead.address.street_number}",) <>
          ~s("Suites__c":#{seller_lead.suites},) <>
          ~s("Area_do_Imovel__c":#{seller_lead.area},) <>
          ~s("Unidade_de_Negocio__c":"#{seller_lead.address.city_slug}|#{
            seller_lead.address.state_slug
          }",) <>
          ~s("Valor_do_Condominio__c":#{seller_lead.maintenance_fee},) <>
          ~s("IDs_de_Duplicados__c":"[]",) <>
          ~s("MobilePhone":"11999999999",) <>
          ~s("Data_Tour__c":"2018-09-24T09:00:00",) <>
          ~s("Numero_de_Vagas__c":#{seller_lead.garage_spots},) <>
          ~s("PostalCode":"#{seller_lead.address.postal_code}",) <>
          ~s("LeadSource":"#{seller_lead.source}",) <>
          ~s("State":"#{seller_lead.address.state}") <>
          ~s(})

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "create_lead_salesforce",
                 "uuid" => seller_lead.uuid
               })

      refute Repo.one(JobQueue)

      updated_seller_lead = Repo.get(SellerLead, seller_lead.uuid)
      assert updated_seller_lead.salesforce_id == "0x01"

      uri = @uri

      assert_called(HTTPoison, :post, [
        ^uri,
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end

  describe "update_lead_salesforce" do
    @uri %URI{path: "/api/v1/Lead/0x01"}

    test "update lead" do
      mock(
        HTTPoison,
        :patch,
        {:ok, %{status_code: 200, body: ~s({"id": "0x01","success": true,"errors": []})}}
      )

      seller_lead =
        insert(:seller_lead,
          user: build(:user, phone: "+11999999999"),
          address: build(:address),
          tour_option: ~N[2018-09-24 09:00:00],
          inserted_at: ~N[2018-09-24 09:00:00]
        )

      body =
        ~s({) <>
          ~s("Bairro__c":"#{seller_lead.address.neighborhood}",) <>
          ~s("City":"#{seller_lead.address.city}",) <>
          ~s("Probabilidade_de_Duplicidade__c":null,) <>
          ~s("Street":"#{seller_lead.address.street}",) <>
          ~s("uuid__c":"#{seller_lead.uuid}",) <>
          ~s("RecordTypeId":"0x01",) <>
          ~s("Data_de_Criacao_do_Lead__c":"2018-09-24T09:00:00Z",) <>
          ~s("LastName":"#{seller_lead.user.name}",) <>
          ~s("Numero_de_Banheiros__c":#{seller_lead.bathrooms},) <>
          ~s("Estado_do_Imovel__c":"#{seller_lead.address.state}",) <>
          ~s("Cidade_do_Imovel__c":"#{seller_lead.address.city}",) <>
          ~s("Imovel_de_Interesse__c":null,) <>
          ~s("Complemento__c":"#{seller_lead.complement}",) <>
          ~s("Rua_do_Imovel__c":"#{seller_lead.address.street}",) <>
          ~s("Email":"#{seller_lead.user.email}",) <>
          ~s("CEP__c":"#{seller_lead.address.postal_code}",) <>
          ~s("Nome_Completo2__c":"#{seller_lead.user.name}",) <>
          ~s("Numero_de_Quartos__c":#{seller_lead.rooms},) <>
          ~s("Range_de_Compra__c":null,) <>
          ~s("Tipo_do_Imovel__c":"#{seller_lead.type}",) <>
          ~s("Tipo_de_Lead__c":"Venda",) <>
          ~s("Valor_do_Imovel__c":#{seller_lead.price || seller_lead.suggested_price},) <>
          ~s("Avaliacao_do_Imovel__c":false,) <>
          ~s("Numero_do_Imovel__c":"#{seller_lead.address.street_number}",) <>
          ~s("Suites__c":#{seller_lead.suites},) <>
          ~s("Area_do_Imovel__c":#{seller_lead.area},) <>
          ~s("Unidade_de_Negocio__c":"#{seller_lead.address.city_slug}|#{
            seller_lead.address.state_slug
          }",) <>
          ~s("Valor_do_Condominio__c":#{seller_lead.maintenance_fee},) <>
          ~s("IDs_de_Duplicados__c":"[]",) <>
          ~s("MobilePhone":"11999999999",) <>
          ~s("Data_Tour__c":"2018-09-24T09:00:00",) <>
          ~s("Numero_de_Vagas__c":#{seller_lead.garage_spots},) <>
          ~s("PostalCode":"#{seller_lead.address.postal_code}",) <>
          ~s("LeadSource":"#{seller_lead.source}",) <>
          ~s("State":"#{seller_lead.address.state}") <>
          ~s(})

      assert {:ok, _} =
               JobQueue.perform(Multi.new(), %{
                 "type" => "update_lead_salesforce",
                 "uuid" => seller_lead.uuid
               })

      refute Repo.one(JobQueue)

      uri = @uri

      assert_called(HTTPoison, :patch, [
        ^uri,
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end
  end

  describe "not handled jobs" do
    test "raise if not passing a multi" do
      assert_raise RuntimeError, fn ->
        JobQueue.perform(:not_multi, %{})
      end
    end

    test "raise if job type not handled" do
      assert_raise RuntimeError, fn ->
        JobQueue.perform(Multi.new(), %{"type" => "whatever", "uuid" => nil})
      end
    end
  end
end
