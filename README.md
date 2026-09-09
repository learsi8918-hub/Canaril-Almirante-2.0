# 🦅 CanaryControl Pro

O **CanaryControl Pro** é um ecossistema mobile profissional desenvolvido em Flutter para a gestão avançada, controle sanitário, monitoramento reprodutivo e mapeamento genético de canarís, totalmente alinhado às diretrizes técnicas e nomenclaturas da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades Implementadas

*   **🎨 Customização Cromática Adaptável por Logo:** Mecanismo inteligente integrado ao ciclo de estado dinâmico do aplicativo. Assim que o criador realiza o cadastro ou atualização da logo do canaril, o sistema extrai automaticamente a tonalidade dominante da marca para reconfigurar a paleta de cores e destaques em tempo real.
*   **📊 Rankings Reprodutivos Segregados (Machos e Fêmeas):** Módulo de auditoria biológica de alta performance que isola e classifica de forma 100% independente a eficiência de fertilidade dos Reprodutores (Machos) e das Matrizes (Fêmeas) com base no histórico acumulado de ovos galados.
*   **📐 Gestão Multifêmeas por Gaiola (Bigamia e Poligamia):** Reestruturação relacional completa para controle de haras e gaiolas compartilhadas. Permite indexar e rastrear de forma isolada qual fêmea realizou a postura e eclosão de ovos ligada ao mesmo macho reprodutor (Ex: Gaiola 15 - Fêmea OZ-012 em Bigamia com Macho GZ-035).
*   **🛒 Rastreamento Detalhado de Origem e Siglas FOB:** Cadastro de aves expandido com suporte a siglas extensas customizadas de clubes (Ex: SOGO, OZ, GZ). Mapeia rigorosamente o histórico de procedência, incluindo o tipo de aquisição (Nascido, Adquirido ou Pet Shop), o nome do criador/canaril vendedor e a sigla do respectivo clube de origem.
*   **🗄️ Arquitetura SQLite Relacional Offline:** Integração nativa e blindada com o motor de banco de dados SQLite (`sqflite`). Todos os canários, prontuários clínicos e ciclos de choco ficam persistidos com segurança na memória interna do smartphone do criador, permitindo funcionamento 100% independente de internet dentro do criatório.
*   **🧪 Suite de Testes Automatizados:** Cobertura de testes unitários (`flutter_test`) na raiz do projeto para validar algoritmos de cálculo de fertilidade, prevenções de erros matemáticos (divisão por zero) e precisão na geração dos cronogramas biológicos de choco de 13 dias.
*   **📱 Navegação Circular Centralizada:** Painel estruturado através de um componente `BottomNavigationBar` de 5 posições acoplado a um `IndexedStack`. Isso permite que o criador navegue entre todas as abas do aplicativo instantaneamente sem perder as informações preenchidas ou o estado de carregamento das telas.

## 🗄️ Arquitetura do Repositório (Padrão Clean e Modular)

A estrutura de arquivos do projeto está organizada de forma a isolar as responsabilidades e garantir que o aplicativo funcione de maneira rápida, sem travamentos na listagem de dados:

```text
canary_control_pro/
├── .github/workflows/       # 🚀 Configurações de compilação em nuvem (CI/CD)
│   └── build_app.yml             # Script v4 de automação de testes, geração de arquivos Android e compilação do APK
├── assets/                  # Armazenamento de mídias e fotos do plantel (.gitkeep)
├── lib/
│   ├── database/            # Camada de Persistência Local Segura (SQLite V2)
│   │   └── db_helper.dart        # Inicialização do banco de dados e operações CRUD nativas (Aves, Saúde, Choco, Perfil)
│   ├── models/              # Camada de Dados, Getters e Regras de Negócio Nativas
│   │   ├── ave_model.dart        # Cadastro de aves, mutações FOB, procedência e filiação para SQLite
│   │   ├── ciclo_model.dart      # Gatilhos biológicos e cronograma de choco adaptado para Bigamia/Poligamia
│   │   ├── criador_model.dart    # Configurações do perfil do criador com suporte a siglas e marcas dinâmicas
│   │   └── saude_model.dart      # Prontuário médico e histórico clínico de tratamentos com mapeamento SQLite
│   ├── screens/             # Camada Visual (Interface Gráfica com o Criador)
│   │   ├── baixa_screen.dart     # Gerenciamento de saídas, vendas e óbitos do plantel
│   │   ├── ciclo_screen.dart     # Calendário de reprodução e alertas de manejo do choco
│   │   ├── dashboard_screen.dart # Painel do criador com injeção cromática e rankings segregados
│   │   ├── exportacao_screen.dart# Painel de compilação de relatórios e exportação CSV com árvores genealógicas
│   │   ├── login_screen.dart     # Tela de login e autenticação com validação de chaves
│   │   ├── navigation_screen.dart# Controlador central do menu inferior (Abas)
│   │   └── saude_screen.dart     # Lançamento e consulta de prontuários médicos
│   └── main.dart            # Ponto de inicialização do app e gerenciamento do tema escuro
├── test/                    # 🧪 Camada de Testes Automatizados e Validação de Algoritmos
│   └── reproducao_test.dart      # Validação de taxas de fertilidade e cronograma do choco
└── pubspec.yaml             # Arquivo de configuração de pacotes, dependências (sqflite, path) e SDK
```

## 🗺️ Modelagem Relacional do Banco de Dados

*   **`aves`**: Tabela principal indexada com chave primária composta por `(clubeSigla, anilha)`, expandida com rastreabilidade de linhagem, número de gaiola e procedência comercial detalhada.
*   **`perfil_criador`**: Tabela de configuração única para armazenar dados regionais e marcas cromáticas dinâmicas do criatório.
*   **`historico_saude`**: Tabela de prontuários com relacionamento lógico associado à ave em tratamento.
*   **`ciclos_reproducao`**: Tabela de controle de choco identificada pelo ID da gaiola, suportando regras de acasalamento composto.

## 🛠️ Requisitos de Ambiente

*   **Flutter SDK:** `>= 3.0.0`
*   **Dart Language:** `>= 3.0.0 < 4.0.0`
*   **Dependências Principais:** `sqflite` (Banco de dados), `path` (Diretórios do sistema), `cupertino_icons` (Icons).
