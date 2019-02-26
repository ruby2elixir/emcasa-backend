defmodule Re.Exporters.Imoveweb do
  """
  <?xml version="1.0" encoding="iso-8859-1"?>
  <Carga xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <Imoveis>
      <Imovel>
        <CodigoCentralVendas>XXXXXXX</CodigoCentralVendas><!-- Código identificador do cadastro da imobiliária no Imovelweb -->
        <CodigoImovel>CA0002</CodigoImovel> <!-- Cada oferta deve ter um identificador único utilizado na carteira de imóveis da imobiliária -->
        <TipoImovel>Casa</TipoImovel><!-- Verificar a tabela de Tipos e subtipos -->
        <SubTipoImovel>Casa de Condomínio</SubTipoImovel><!-- Verificar a tabela de Tipos e subtipos -->
        <TituloImovel><![CDATA[Casa Residencial à venda no São José dos Pinhais.]]></TituloImovel><!-- Nesta tag aceitamos até 50 caracteres -->
        <Observacao>
          <![CDATA[Casa em Condomínio fechado super ventilada, linda, e bem localizada; Casa contendo no 1° piso:  Sala ampla para 03 ambientes; Lareira; Cozinha toda mobiliada com tampo em granitto e fogão Cooktop; Despensa; Área de serviço toda com armários; Espaço Externo com churrasqueira; Escada toda em granitto; 2º Piso: 03 quartos, sendo 01 suíte com hidromassagem, closet e sacada; 02 quartos com sacada interligada; Banheiro social; 3° Piso: Amplo ático com banheiro e lareira; O Condomínio oferece: Salão de festas com churrasqueira, geladeira, microondas e banheiros; Quadra Poliesportiva; Salão de jogos com vestiários; Piscina Adulto e infantil; Trilha Ecológica de 1 km; 02 Nascentes; Fale com um de nossos consultores]]>
        </Observacao>
        <Modelo>Destaque</Modelo><!-- Nesta tag são aceitos 3 valores: SIMPLES, DESTAQUE e HOME(Modelo de anúncios disponíveis no Portal) -->
        <UF>PR</UF><!--Obrigátorio -->
        <Cidade><![CDATA[Curitiba]]></Cidade><!--Obrigátorio -->
        <Bairro><![CDATA[Pilarzinho]]></Bairro><!-- Sem essa informação, a oferta será disponibilizada no BAIRRO centro -->
        <Endereco><![CDATA[Rua Domingos Antônio Moro]]></Endereco>
        <Numero>782</Numero>
        <CEP>82115010</CEP>
        <DivulgarEndereco>SIM</DivulgarEndereco> <!-- Nesta tag são aceitos 3 valores: SIM, NÃO e APROX(Exibe o nome da rua porém não mostra o número do imóvel) -->
        <VisualizarMapa>1</VisualizarMapa><!-- Nesta tag são aceitos 2 valores: 1 e 0 -->
        <Latitude>-25.3821201324462900000000000</Latitude><!-- Na ausência dessa tag, são necessários todas as informações de localidade (UF, Cidade, Bairro, CEP e endereço) para a geração automática do mapa no Portal-->
        <Longitude>-49.2887039184570300000000000</Longitude><!-- Na ausência dessa tag, são necessários todas as informações de localidade (UF, Cidade, Bairro, CEP e endereço) para a geração automática do mapa no Portal-->
        <PrecoVenda>1400000</PrecoVenda>
        <PrecoCondominio>460</PrecoCondominio>
        <AreaUtil>300</AreaUtil>
        <AreaTotal>300</AreaTotal>
        <IdadeImovel>29</IdadeImovel>
        <!-- Em casos onde o sistema (integrador) envia a antiga tag (<AnoConstrucao>), nosso conversor aplicará o cálculo de forma automática.
        Exemplo: DE <AnoConstrucao>1988</AnoConstrucao>
        PARA <IdadeImovel>29</IdadeImovel>-->
        <UnidadeMetrica>M2</UnidadeMetrica><!--Essa tag deve receber apenas duas informações (M2 ou ha). -->
        <QtdDormitorios>3</QtdDormitorios>
        <QtdSuites>1</QtdSuites>
        <QtdBanheiros>2</QtdBanheiros>
        <QtdVagas>2</QtdVagas>
        <Fotos>
          <Foto>
            <NomeArquivo><![CDATA[590053053E3B]]></NomeArquivo>
            <URLArquivo><![CDATA[http://cdn1.valuegaia.com.br/_Fotos/3053/3270/590053053E3BB1C1FE2319C4754FDBC602135BA72D2BE97ED.jpg]]></URLArquivo>
            <Principal>1</Principal>
            <Ordem>0</Ordem>
          </Foto>
          <Foto>
            <NomeArquivo><![CDATA[5900530530D04AC75EC870DDE6BEE1]]></NomeArquivo>
            <URLArquivo><![CDATA[http://cdn1.valuegaia.com.br/_Fotos/3053/3270/5900530530D04AC75EC870DD090EED9BFA1605E8351E6BEE1.jpg]]></URLArquivo>
            <Principal>0</Principal>
            <Ordem>1</Ordem>
          </Foto>
          <Foto>
            <NomeArquivo><![CDATA[5900872722210B]]></NomeArquivo>
            <URLArquivo><![CDATA[http://cdn1.valuegaia.com.br/_Fotos/3053/3270/590053053BA513D4509FF8781807E3CF4C5446F872722210B.jpg]]></URLArquivo>
            <Principal>0</Principal>
            <Ordem>2</Ordem>
          </Foto>
        </Fotos>
        <Videos>
          <Video>
            <Descricao><![CDATA[Casa6969]]></Descricao>
            <URLArquivo><![CDATA[http://www.youtube.com/embed/ZTJR4ckp6C4]]></URLArquivo><!-- É possível cadastrar apenas 1 vídeo (link do Youtube) por imóvel) -->
            <Principal>1</Principal>
          </Video>
        </Videos>
        <!--  Exemplos de "características" do imóvel -->
        <!--  Consultar lista completa de características na planilha que acompanha este XML modelo -->
        <Armariodecozinha>1</Armariodecozinha>
        <Churrasqueira>1</Churrasqueira>
        <Closet>1</Closet>
        <Copa>1</Copa>
        <Dependenciadeempregados>1</Dependenciadeempregados>
        <Despensa>1</Despensa>
        <Edicula>1</Edicula>
        <Playground>1</Playground>
        <Quintal>1</Quintal>
        <Salaodefestas>1</Salaodefestas>
        <SalaodeJogos>1</SalaodeJogos>
        <Piscina>1</Piscina>
      </Imovel>
      <!-- ... outros imóveis ... -->
    </Imoveis>
  </Carga>
  """

  @exported_attributes ~w(internal_id id type subtype title description highlight state city neighborhood
    street street_number zipcode show_address lat lng show_map area_unity area price maintenance_fee rooms
    bathrooms garage_spots images tour)a
  @default_options %{attributes: @exported_attributes, highlight_id: []}

  @frontend_url Application.get_env(:re_integration, :frontend_url)
  @tour_url Application.get_env(:re_integration, :matterport_url)
  @image_url Application.get_env(:re_integration, :image_url)

  def export_listings_xml(listings, options \\ %{}) do
  end

  def build_node(listing, options) do
  end

  defp build_root(nodes) do
  end

  def convert_attributes(listing, %{attributes: attributes}) do
  end

  defp convert_attribute(:internal_id, listing, options), do: nil
  defp convert_attribute(:id, listing, options), do: nil
  defp convert_attribute(:type, listing, options), do: nil
  defp convert_attribute(:subtype, listing, options), do: nil
  defp convert_attribute(:title, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:description, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:highlight, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:state, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:city, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:neighborhood, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:street, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:street_number, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:zipcode, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:show_address, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:lat, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:lng, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:show_map, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:area_unity, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:area, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:price, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:maintenance_fee, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:rooms, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:bathrooms, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:garage_spots, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:images, listing, options), do: {"", %{}, nil}
  defp convert_attribute(:tour, listing, options), do: {"", %{}, nil}
end
