defmodule Re.SellerLeads.Salesforce.ClientTest do
  use Re.ModelCase
  use Mockery

  import Re.Factory

  alias Re.SellerLeads.Salesforce

  describe "create_lead/1" do
    test "should send a request to create a lead" do
      mock(HTTPoison, :post, {:ok, %{status_code: 200, body: ~s({"success":true})}})

      seller_lead =
        insert(:seller_lead,
          user: build(:user, phone: "+11999999999"),
          address: build(:address),
          tour_option: ~N[2018-09-24 09:00:00],
          inserted_at: ~N[2018-09-24 09:00:00]
        )

      assert {:ok, %{"success" => true}} = Salesforce.create_lead(seller_lead)

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

      assert_called(HTTPoison, :post, [
        %URI{path: "/api/v1/Lead"},
        ^body,
        [{"Authorization", ""}, {"Content-Type", "application/json"}]
      ])
    end

    test "should not send a request on not handled lead type" do
      assert {:error, :lead_type_not_handled} = Salesforce.create_lead(%{})
    end
  end
end
