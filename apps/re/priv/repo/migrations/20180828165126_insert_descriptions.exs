defmodule Re.Repo.Migrations.InsertDescriptions do
  use Ecto.Migration

  alias Re.{
    Addresses.District,
    Repo
  }

  @districts [
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Botafogo",
      description: """
      Emcasa é a melhor opção para encontrar casas e apartamentos localizados na Zona Sul da cidade do Rio de Janeiro, no bairro de Botafogo, que conta com,  aproximadamente, 100 mil habitantes. Este é o berço de um dos mais belos cartões postais do Brasil: a Enseada de Botafogo, que tem como vista ao seu fundo os morros Pão de Açúcar e Urca.
      O Iate Clube do Rio de Janeiro, dentre outras inúmeras atividades e atrações que o bairro tem, é uma das que mais se destaca, com sua marina e seu cais podendo ser vistos de quase todas as localidades de Botafogo.
      Muito embora leve o nome de um dos mais importantes times de futebol do país, não é apenas por isso que o bairro deve ser destacado. Botafogo abriga a Escola de Samba São Clemente; escola que vem crescendo e se destacando dentre o cenário carnavalesco do país.
      Entreter-se em Botafogo é fácil, pois o bairro conta com diversos bares, restaurantes, cinemas, casas de shows, shoppings e teatros. Porém um dos pontos fortes do bairro é contar com um grande acervo de escolas e faculdades como: Colégio Eduardo Guimarães, Colégio Imperial, Colégio Santo Amaro, Colégio Pedro II, Escola América Católica Our Lady od Mercy OLM, Faculdade Integradas Hélio Alonso (FACHA), entre outras.
      Na saúde, o bairro consegue trazer o suporte necessário. Existem, ali, duas unidades básicas de saúde (públicas): Centro Municipal de Saúde Dom Hélder Câmara e a Clínica da Família Santa Marta.  Além de oferecer o UPA- Unidade de Pronto Atendimento, bem ao lado da estação do metrô.
      A presença forte de grandes clínicas renomadas torna o bairro um dos verdadeiros pólos de saúde do Rio. Nomes como Hospital Pró-Cardíaco, Hospital Samaritano e Casa de Saúde São José se faz presente por aqui.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Catete",
      description: """
      Muito tradicional na cidade do Rio de Janeiro e seus conterrâneos os cariocas, o Bairro Catete está localizado na Zona Sul da cidade, e é considerado um bairro histórico por ter sediado a presidência da República Brasileira, que tinha sua sede no Palácio do Catete.
      Como se não bastasse, o mesmo está ple  namente localizado, fazendo divisas com bairros importantes do Rio, como Flamengo e Laranjeiras. O Bairro é agraciado com vários sobrados construídos no século XIX e no começo do século XX, o que lhe emprega um charme e, por muito e tempo, o contemplou como um dos bairros mais valorizados do Rio de Janeiro.
      Tal valorização se dá ainda por ter uma ótima localização dentro do município, interligando o polo sul da cidade ao centro da mesma. O bairro conta com uma ligação de Metrô-ônibus que conecta o Largo do machado até o tradicional bairro Cosme Velho. A principal via do bairro é a Rua do Catete, que tem sua extensão ampliada desde a glória até a Praça José de Alencar.
      Aos que usam muito o transporte aéreo, tem uma ótima opção fácil e rápida residindo no Catete: o Aeroporto de Santos Dumont fica a apenas 10 minutos do bairro. Se você gosta de cultura, aqui não faltarão opções. O catete abriga dois museus: O museu do Folclore e o Museu da República. Além disso, abriga também o Teatro Cacilda Becker e o Espaço Marum, que embora seja uma boate, ocasionalmente abre espaços na sua agenda, funcionando como casa de shows.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Copacabana",
      description: """
      Emcasa é referência para quem deseja buscar apartametos em casas em um dos mais tradicionais e famosos bairros da cidade do Rio de Janeiro. Como por exmeplo, o bairro de Copacabana, que está localizado na Zona Sul da cidade, e é, sem dúvidas, em um dos bairros mais personalísticos de todos os tempos, famoso, principalmente, devido a queima de fogos de artifício na orla da praia na virada de ano.
      Copacabana tem alguns apelidos entre os cariocas, como Coração da Zona Sul e Princesinha do Mar. O bairro atrai turistas do mundo todo e conta com mais de 80 hotéis para receber seu público, ávido para colher as belezas naturais que ali se encontram.
      Ainda faz divisa com outros bairros importantíssimos do município que são: Leme, Lagoa, Ipanema e Humaitá. Copacabana conta com três estações de metrô: Siqueira Campos, Cardeal Arcoverde e Cantagalo. Além disso, suas principais ruas são a Avenida Atlântica, que fica às margens da Praia de Copacabana e a Rainha Elizabeth da Bélgica, que liga Copacabana a Ipanema.
      O ponto alto em que o bairro recebe seus visitante são o carnaval e ano novo. Não se pode deixar de ressaltar, também, que o bairro é cenário de muitas produções cinematográficas nacionais e internacionais, o que contribui muito para que seja um destino tão procurado no mundo."
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Cosme Velho",
      description: """
      Emcasa oferece a você as melhores opções de apartamentos e casas no bairro Cosme Velho, um dos mais tradicionais do Rio de Janeiro. Antigamente, era conhecido pelo nome de “Águas Férreas’’. Hoje, o bairro Cosme Velho está situado na Zona Sul da cidade do Rio de Janeiro, mais precisamente no sopé dos conhecidos morros Corcovado e Dona Marta.
      Sua rua principal e característica é a Rua Cosme Velho, que é uma continuação da tradicional Rua das Laranjeiras, muito conhecida pelos cariocas e musicistas.
      O Bairro está repleto de monumentos históricos, como o Monumento a Carlo Del Prete. Residiam nele moradores ilustres como: Cecília Meirelles, Portinari, Oscar Niemeyer, Roberto Marinho, Villa Lobos e Machado de Assis. Mas com certeza, o ponto mais impressionante do bairro é a estação de trem do Corcovado, que proporciona aos turistas a visitação ao Cristo Redentor.
      O bairro também abriga o Museu Internacional de Arte Näif do Brasil, desde o ano de 1995. Esta importante coleção conta com mais de 06 mil tipos de pinturas diferentes que estão dentro deste nicho artístico.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Flamengo",
      description: """
      Emcasa via te ajudar a encontrar as melhores casas e apartamento no bairro do Flamengo, que está localizado na zona Sul do município e é um dos mais famosos na região. Sua maior referência é a praia que leva o nome do bairro: Praia do Flamengo. Este faz divisa com outros importantes bairros do município como Botafogo e Laranjeiras.
      O Flamengo abriga a classe média, e classe média alta da cidade. Por isso tem seu índice de criminalidade menor do que outros pontos da cidade. Abriga também uma avenida muito conhecida no Rio de Janeiro que é a Avenida Rui Barbosa, conhecida por ter sido point entre os nobres nas noites de verão na cidade.
      Para ter acesso ao bairro pelas linhas de metrô, é só utilizar as estações Flamengo, Largo do Machado e Catete. Duas das ruas mais conhecidas do bairro são a Praia do Flamengo e Senador Vergueiro. No bairro você pode encontrar também o Centro Cultural Oduvaldo Viana, que fica no Castelinho do Flamengo, o Centro Cultural Arte Sesc, a Casa de Arte e Cultura Julieta e, ainda, o Parque Brigadeiro Eduardo Gomes que está repleto de atividades de entretenimento.
      Situado no Flamengo ainda, estão consulados de grandes países como: México, Reino Unido, Bolívia, Islândia, Peru, Japão e Chile.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Gávea",
      description: """
      Emcasa te ajuda na missão de encontrar a casa ou apartamento perfeito em bairros do Rio, a exemplo, a Gávea. Ao falar com cariocas, eles lembrarão da Gávea como sendo um dos bairros mais tradicionais do Estado. A Avenida Padre Leonel Franca, que por sinal é a principal via de acesso do bairro, é quem é a grande responsável pela ligação da zona Sul com outro bairro renomado, o São Conrado, chegando, finalmente, na Zona Oeste.
      Mas a Gávea está longe de se resumir, apenas, como uma avenida com trânsito intenso. Ruas locais como as Acácias, Oitis, Marquês de São Vicente- responsável pela ligação ao Jardim Botânico e a João Borges tornam a vida agitada e bastante movimentada por aqui, tornando-se um lugar perfeito para se viver.
      Bastante residencial, a Gávea abriga prédios altos e baixos, mesclando-se. Além disso, para contraste local, há também a presença de grandes casarões. A área verde, que por sinal é vasta, encanta os moradores e visitantes. Lá, você consegue observar a presença de árvores frutíferas e algumas espécies raras, como por exemplo, o pau Brasil.
      Por aqui também se encontra o Museu Histórico da Cidade que conta com 20 mil peças, entre os exemplares, podemos ver o trono de dom João VI, gravuras do pintor Jean Baptiste Debret e esculturas do Mestre Valentim.
      A infraestrutura local é, realmente, de invejar. São inúmeras escolas públicas e particulares. Entre as mais renomadas, encontramos a Escola Americana do rio de Janeiro, o Colégio Teresiano e a Escola Parque. A PUC, uma das universidades mais respeitadas, também está instalada neste bairro. Já na sessão de hospitais, temos o Miguel Couto, o Posto de Saúde Albert Sabin e a Clínica São Vicente.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Humaitá",
      description: """
      Emcasa é o seu portal para encontrar casas e apartamentos localizado na Zona Sul do Rio de Janeiro, como o bairro Humaitá, que faz limite com outros bairros renomados da cidade carioca, como Lagoa, Botafogo, Copacabana, Santa Teresa, Alto da Boa Vista e Jardim Botânico.
      Seu nome se dá devido a Rua Humaitá, que por sinal, é a principal via de acesso ao bairro. A rua recebeu este nome como forma de homenagem aos seis monitores que, na operação Passagem de Humaitá, que aconteceu dentro do contexto da Guerra do Paraguai, conseguiram lograr êxito ao transpassar a Fortaleza de Humaitá.
      Hoje em dia, o bairro é, praticamente, unificado a outro bairro bastante famoso, o Botafogo. Isso se dá devido ao eixo representado pelas ruas Humaitá, Voluntários da Pátria e São Clemente. Um bairro tipicamente residencial, sendo que é um dos pouquíssimos bairros da Zona Sul que apresenta, em sua maioria, construções antigas tombadas como patrimônio histórico da população.
      Por aqui, passam diversas linhas de ônibus. Algumas delas ligam a Zona Sul à Zona Norte. Muito embora não haja estação de metrô, uma das linhas do serviço Metrô na Superfície, extensão do metrô por ônibus, que consegue te levar até a estação mais próxima dali, que fica em Botafogo.
      Possui uma vida noturna bastante movimentada e que vem crescendo nos últimos anos. Pode-se notar a presença de vários bares e lojas de produtos importados, além de restaurantes tradicionais, como o Cobal do Humaitá, que funciona na antiga garagem de bondes.
      Na rua Visconde de Caravelas você encontra a clássica vida boêmia. Bares tradicionais, como Aurora e Plebeu passam a dividir esquinas com bares da rede Botequim Informal. Por ali, também existe a presença do Instituto Brasileiro de Administração Municipal, o IBAM, além da Casa da Espanha e o Espaço Cultural Sérgio Porto, que já abrangeu diversas apresentações desde sua inauguração, ainda em 1983.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Ipanema",
      description: """
      O Bairro de Ipanema fica situado na Zona Sul do Rio de Janeiro. Famoso por si só, dispensa apresentações depois de se tornar, merecidamente, título da canção “ Garota de Ipanema’’, música composta por Tom Jobim e Vinicius de Moraes no ano de 1962.
      O bairro que é um dos cartões postais da cidade, tem uma excelente localização. Fica ao lado dos bairros Leblon e Copacabana. Sendo assim, não estranhe de encontrar famosos por ali, ou moradores e visitantes que da alta classe social.
      Segundo o último censo realizado na área, sua população total é de 42.743 habitantes.
      O bairro conta com excelentes escolas municipais e ainda com alguns colégios particulares, como o Notre Dame, PH e Max Nordau. E quesito ensino superior, os moradores contam com a Universidade Cândido Mendes, a UCAM.
      Ipanema conta também com um grande aparato médico. Está recheado de clínicas médicas das mais diversificadas especialidades.
      Para se locomover para outros locais da cidade, os moradores do bairro não encontram dificuldades. Contam com uma estação de metrô que circula a linha 1, indo de Ipanema até o bairro da Tijuca. Além disso, possui diversas linhas de ônibus que atendem toda a região por completo.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Itanhangá",
      description: """
      Emcasa disponibiliza para você os melhores apartamentos e casas localizados no Itanhangá,na Zona Oeste do Rio de Janeiro, que conta com uma população total de 38.415 habitantes (segundo último censo realizado no local). O bairro Itanhangá está na região administrativa da Barra da Tijuca, ficando ao lado de outro conhecido bairro Carioca: o Jacarepaguá.
      Diferente da maioria dos bairros da cidade, encontramos mais casas do que apartamentos. Isso se dá devido ao baixo índice de criminalidade, sendo considerado muito tranquilo pela população carioca.
      O Itanhangá conta, ainda, com ótimos colégios, como por exemplo, o Colégio Internacional Everest e o Colégio Mopi. Para complementar, tem ainda as excelentes escolas municipais  Maria Clara Machado e Lopes Trovão. O Bairro é também sede de vários estabelecimentos religiosos como: A paróquia de São Bartolomeu, Capela Nossa Senhora Mãe da Divina Providência, Igreja Presbiteriana da Barra e Assembléia de Deus.
      No quesito esporte e lazer, o bairro tem o popular Itanhangá Golf Club, ótimo pra quem quer iniciar no esporte, usar suas dependências para uma caminhada ou um simples contato com a natureza. O Golf Club conta com paisagens lindas e arborizadas.
      O bairro conta ainda com lindas Cachoeiras, onde o curso d'água se origina no Parque Nacional da Tijuca
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Jardim Botânico",
      description: """
      Emcasa disponibiliza as melhores ofertas de casas e apartamentos no Bairro Jardim Botânico, situado na Zona Sul da cidade do Rio de Janeiro. É considerado um bairro novo em relação a outros tradicionais bairros Carioca. Ele faz divisa com bairros muito conhecidos como: Lagoa, Alto da Boa vista, Gávea e Humaitá, e através do conhecido túnel Rebouças, se liga a Zona norte da cidade.
      A classe social que reside no bairro pode ser classificada de classe média alta e alta. Aos amantes da natureza, esta, por sinal, muito rica na cidade do Rio de Janeiro pelas belas praias, o bairro hospeda um Horto Florestal magnífico.
      A arquitetura do Jardim Botânico é mista, junta belas construções antigas com prédios modernos. Próximo as montanhas, encontram-se algumas construções luxuosas de famílias de classe alta. Durante muito tempo o bairro se destacou por abrigar o Teatro Fênix, local onde era gravado alguns dos programas de auditório mais famosos da Rede Globo como: Os Trapalhões, Xuxa e Faustão. Antigamente, o Jardim Botânico abrigava algumas fábricas, porém nos dias de hoje é um bairro fortemente residencial, o que caracteriza e intensifica o comércio local
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Joá",
      description: """
      Emcasa oferta a você as melhores possibilidades de apartamentos e casas no RJ, como no Bairro Joá, que está localizado no Rio de Janeiro, na Zona Oeste do Estado. De toda a zona administrativa da Grande Barra da tijuca, o Joá é o menor bairro em questão de área demográfica e o segundo menor com população, ficando atrás, apenas, do bairro Grumari.
      O principal acesso se dá através da estrada do Joá, existente desde 1929, que faz a ligação entre o Largo da Barra e São conrado. Outra via importante que passa pelo citado bairro, porém, não dá acesso a ele pe a Autoestrada Lagoa-Barra.
      Considerado uma das vistas mais bonitas do Rio de Janeiro, você vai encontrar o Elevado das Bandeiras. Joá é um bairro espremido pelo Oceano Atlântico e o paredão rochoso do Pico dos Quatro. Por isso, suas residências são, predominantemente, construídas em cima do morro da Joatinga.
      Um dos principais pontos é a Pedra da Gávea. Aos amantes de praia, indicamos uma visita a Praia da Joatinga, que está localizada dentro de um condomínio privado, mas que tem acesso livre ao público. Atualmente, tramita na câmara um projeto de lei que visa a ampliação dos limites do bairro, passando a anexar a este o sub-bairro da Barrinha que hoje se encontra na Barra da Tijuca, criando desta forma, um sub-bairro do Baixo Joá, que fará limite com Itanhangá.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Lagoa",
      description: """
      Emcasa oferece apartamentos e casas no Rio de Janeiro, para que você possa fazer parte das 21.200 pessoas moram no bairro Lagoa. Seu nome se deu devido a presença da Lagoa Rodrigo de Freitas, atração turística local, ideal para a prática de atividades físicas e lazer. A maioria territorial do bairro está protegida por áreas de preservação ambiental. Se você gosta de pedalar, saiba que o bairro conta com uma ciclovia de 7,5 quilômetros de extensão, às margens da Rodrigo de Freitas.
      Majoritariamente residencial, o bairro da Lagoa não possui um comércio muito forte se comparado a Copacabana, Ipanema e Leblon. A maioria dos estabelecimentos são restaurantes e quiosques que você encontra na orla da praia.
      O bairro é o terceiro mais valorizado do Rio de Janeiro, ficando atrás apenas de Ipanema e do Leblon. Um dos motivos dessa desvalorização é, justamente, a escassez de terrenos dedicados à construção de novos empreendimentos imobiliários.
      O Canal do Jardim de Alah, pelo qual a lagoa se comunica com as águas do oceano atlântico, estabelece uma divisória com os bairros vizinhos- Leblon e Ipanema. A Lagoa também faz divisa com outros bairros, como Gávea, Jardim Botânico, Humaitá e Copacabana.
      O bairro pode ser dividido em outras sub-áreas. São elas: Curva do Calombo, Lado de Ipanema, Fonte da Saudade, Lado do Jardim Botânico, Corte do Catagalo, Lado do Leblon. Este bairro representa uma peça importante dentro do Estado do Rio de Janeiro, estando em uma das entradas do Túnel Rebouças, ligando a zona Sul à zona Norte.
      Avenida Borges de Medeiros e Epitácio Pessoa contornam o Canal do Jardim de alah e a Lagoa. Pelos lados norte e oeste, a Lagoa é contornada pela Avenida Epitácio Pessoa. Também podemos citar a Avenida Alexandre Ferreira e a Rua Fonte da Saudade, que é a responsável pela ligação da Lagoa para com o bairro Humaitá.
      O Bairro da Lagoa, hoje, é a ligação principal entre a Zona Sul e o Oeste do Estado. A Avenida Henrique Dodsworth liga o bairro a Copacabana, terminando na Praça Eugênio Jardim, localizado na Estação Cantagalo do metrô. Para finalizar, o bairro ainda conta com a presença de grandes parques, como o Parque Catacumba, o Parque dos Patins e o Parque Cantagalo.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Laranjeiras",
      description: """
      Laranjeiras é um dos bairros nobres do rio de Janeiro, localizado na Zona Sul, sendo, também, um dos mais antigos. Sua ocupação teve início no século XVII através da construção de chácaras em volta do Rio Carioca, que desde o Corcovado e chega até o Alto da Boa Vista. Devido a isto, anteriormente, o bairro recebeu o nome de Vale do Carioca. Em sua parte mais baixa, haviam muitas laranjeiras o que, no final, acabou dando nome ao bairro.
      O Palácio de Guanabara, que é a sede oficial do governo do Estado do Rio de Janeiro e o Palácio Laranjeiras que é a residência oficial do Governo do Estado estão localizados em Laranjeiras. O Parque Guinle, a sede do Batalhão de Operações Especiais da Polícia Militar do Estado do Rio de Janeiro (famosos, BOPE) e o Fluminense Futebol Clube também estão aqui.
      Ideal para quem está em busca de uma residência confortável e segura, o bairro é composto por pessoas de classe média-alta e classe-alta. A via principal é a Rua das Laranjeiras, que tem seu início no Largo do Machado e se finda no túnel Rebouças, já sob o nome de Rua Cosme Velho.
      O bairro serviu de endereço para grandes nomes nacionais, como Villa Lobos, Portinari, Cecília Meirelles, Oscar Niemeyer e Roberto Marinho. Laranjeiras utiliza-se de uma localização estratégica, limitando-se com Cosme Velho, Catumbi, Rio Comprido, Catete, Santa Teresa, Botafogo e Flamengo.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Leblon",
      description: """
      Emcasa oferece casase apartamentos em um dos dos bairros mais elegantes e charmosos do Rio de Janeiro. O Leblon está localizado na Zona Sul do Rio, precisamente, entre os bairros de Ipanema, Vidigal e Gávea. O bairro é conhecido por fazer parte de grandes composições musicais e cenários de novelas e minisséries nacionais.
      Ao todo, 46.044 pessoas moram lá, contando, inclusive, com a residência de muitos famosos. A população é, basicamente, de classe média e classe média alta, com renda mensal de R$ 6.845, segundo informações fornecidas pelo Instituto Brasileiro de Geografia e Estatística.
      O morro dois Irmãos e o mar azul são os verdadeiros cartões de visita do bairro. A beleza cedida naturalmente, acrescidas com demais atributos fazem deste bairro, um dos mais cobiçados do Rio de Janeiro. Para conferir, basta um pequeno passeio pelas ruas do bairro para notar a arborização local e a predominância de grandes prédios de moradia.
      O comércio é bastante forte a vida noturna atrai turistas de todos os cantos do mundo. Uma das principais ruas, que detém a maioria do comércio local e que corta todo o bairro é a Ataulfo de Paiva. Outra rua bastante famosa é a Bartolomeu Mitre, já que esta é utilizada como passagem para o caminho Lagoa-Barra. Outras ruas são bastante movimentadas, como a Conde Bernadotte e a Dias Ferreira, ambas possuem intensa movimentação de restaurantes e bares. Por fim, a rua Delfim Moreira, que é a rua da praia.
      Um dos pontos mais famosos da praia é o Posto 12. Para a família, indicamos o Baixo Bebê, um quiosque que ficou conhecido devido as famílias que levam suas crianças para poder brincar e se divertir em um deliciosos passeio a beira-mar.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Leme",
      description: """
      Emcasa têm apartamentos e casas no bairro do Leme, que fica localizado ao sul do Rio de Janeiro e podemos dizer que seus moradores vivem num canto bastante especial da cidade. Este local faz fronteiras com a Pedra do Leme, com os morros do Chapéu Mangueira e da Babilônia, além do Oceano Atlântico, avenida Princesa Isabel que serve para o separar do bairro de Copacabana.
      O resultado? Ruas quase sem trânsito e bastante tranquilas para se trafegar. Assim como todos os bairros, o Leme possui algumas vias principais, como a Avenida Atlântica (que é a famosa avenida da orla da praia) e as ruas Roberto Dias Lopes e a Gustavo Sampaio.
      O bairro é bastante providencial, sendo que se você precisar de uma agência bancária, não é necessário sair dele para resolver o seu problema. Além disso, conta com farmácias, supermercados e padarias em geral. Também é uma região turística e por tal motivo, tem a presença constante de hotéis.
      Segundo informações cedidas pelo Instituto Brasileiro de Geografia e Estatística (IBGE), vivem aqui 14.799 pessoas de classe média que recebem, em média, R$ 4.388. Além da Praia do Leme, existem outras opções de entretenimento que atraem curiosos e boêmios, como os restaurantes e bares com vida noturna intensa, sendo que a grande maioria está localizado na Praça Almirante Júlio de Noronha.
      Outra opção de atração para você conferir pe o Leme Tênis Clube, que fora fundado em 1914 e tem local para show, piscinas e quadras desportivas, funcionando como locação particular.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "São Conrado",
      description: """
      Emcasa garante as mehores opções de casas e apartamentos no bairro de São Conrado, que fica localizado no município do Rio de Janeiro, na Zona Sul, propriamente dita. É um dos bairros mais luxuosos do Rio, mesmo que em sua extremidade tenha a presença da Favela da Rocinha.
      Amplamente, ele é popularizado por grandes edifícios residenciais de classe alta, além de mansões que estão em meio a montanhas. Devido a isto, conta com estabelecimentos que atinjam, exatamente, este público de classe alta, como por exemplo, o Shopping São Conrado Fashion Mall e a Gavea Golf & Country Club.
      Contudo, também apresenta uma grande desigualdade social, mostrando a realidade do seu oposto, já que faz limite com a Vila Canoas e a Favela da Rocinha. A sociedade tem sua representação feita pela AMASCO (Associação dos Moradores e Amigos de São Conrado) que tem um papel importantíssimo mediante as solicitações dos moradores frente aos órgãos públicos.
      Um dos cartões postais do Bairro é a Pedra da Gávea: o maior bloco de pedra que está a beira-mar do mundo! Da rampa localizada juntamente à Pedra bonita, pode-se ver praticantes de voos livres que saltam de asa delta, pousando, diretamente, no trecho final da orla do bairro, denominado de Praia do Pepino.
      No bairro, você também tem contato com a Escola de Samba da rocinha. Ele é cortado com a Autoestrada Lagoa-Barra, o principal eixo de ligação entre Barra da Tijuca e Zona Sul. contudo, também pode transitar por outras vias, como por exemplo, a Estrada das Canoas, Avenida Niemeyer, Avenida Prefeito Mendes de Moraes, e a Estrada de Joá.
      """
    },
    %District{
      state: "RJ",
      city: "Rio de Janeiro",
      name: "Urca",
      description: """
      Emcasa é o ponto certa para quem busca casas e apartamentos no bairro da Urca, que é um dos tradicionais bairros do Rio de Janeiro, tendo como principal atração turística, pontos como Morro da Urca e Pão de Açúcar. Além disso, o bairro é bastante conhecido devido às instituições importantes que estão locadas lá: UFRJ- Universidade, Federal do Rio de Janeiro, a ECEME- Escola de Comando e Estado-Maior do Exército, a EGN- Escola de Guerra Naval, a ESG- Escola Superior de Guerra, o IME- Instituto Militar de Engenharia, a Unirio- Universidade Federal do Rio de Janeiro, A companhia de Pesquisa de Recursos Minerais, o Forte São João e o Museu de ciência da Terra.
      O bairro é tão querido entre os cariocas que a novela da Rede Globo, A Gata Comeu, que fora exibida em 1985, foi ambientada no local, usando residências do próprio bairro para cenografias. Para quem está em busca de segurança, saiba que o bairro é considerado um dos mais calmos, sendo que a taxa de criminalidade é, basicamente, nula devido a presença do Quartel do Exército e demais instalações de cunho militar.  Também é bastante valorizado por se tratar de um dos poucos bairros da zona Sul que não têm presença de favelas.
      A Urca faz divisas com outros bairros conhecidos, como o Leme e Botafogo. É no bairro que o Oceano Atlântico se encontra com a famosa Baía de Guanabara, possuindo, em si, tanto praias com água das baías (que são praias inapropriadas para banhos) quanto praias banhadas pelo Oceano.
      """
    }
  ]
  def up do
    Enum.each(@districts, &Repo.insert!/1)
  end

  def down do
    Repo.delete_all(District)
  end
end
