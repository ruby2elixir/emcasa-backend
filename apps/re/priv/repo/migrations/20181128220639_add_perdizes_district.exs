defmodule Re.Repo.Migrations.AddPerdizesDistrict do
  use Ecto.Migration

  def up do
    Re.Repo.insert(%Re.Addresses.District{
      state: "SP",
      city: "São Paulo",
      name: "Perdizes",
      description: """
      Emcasa é a melhor opção para encontrar casas e apartamentos localizados no bairro de Perdizes, em São Paulo, que conta com mais de 100 mil habitantes. Possui o terceiro maior IDH entre os distritos paulistas, ficando atrás apenas de Moema e Pinheiros.
      Perdizes abriga uma grande variedade de comércios localizados nas ruas Cardoso de Almeida e Turiassu. Apresenta localização privilegiada, próxima ao centro e à Avenida Paulista, diversas escolas e universidades, sendo um dos bairros mais valorizados da zona Oeste.
      O bairro possui uma quantidade enorme de supermercados, farmácias, hospitais, bares e restaurantes. Além disso, abriga também o Teatro Tuca, O Teatro bradesco e o Shopping Bourbon.
      Para quem gosta de natureza e praticar esportes ao ar livre também encontrará o seu lugar no Parque Água Branca e no Parque Zilda Natel.
      Conhecido por suas ladeiras, Perdizes é um bairro amado por seus moradores e um dos locais mais nobres da cidade de São Paulo.
      """
    })
  end

  def down do
    Re.Addresses.District
    |> Re.Repo.get_by(state: "SP", city: "São Paulo", name: "Perdizes")
    |> Re.Repo.delete()
  end
end
