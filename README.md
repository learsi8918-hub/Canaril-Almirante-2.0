# 🦅 CanaryControl Pro

O **CanaryControl Pro** é um ecossistema mobile profissional desenvolvido em Flutter para a gestão avançada, controle sanitário, monitoramento reprodutivo e mapeamento genético de canarís, totalmente alinhado às diretrizes técnicas e nomenclaturas da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades Implementadas

*   **📦 Compilação Automatizada de Binários (Nuvem APK):** Pipeline de Integração Contínua (CI/CD) operando sob o motor v4 de upload do GitHub Actions. O sistema executa testes ornitológicos em ambiente virtualizado isolado e gera o instalador móvel nativo (**APK**) disparado por Commits, Tags de versão ou acionamento manual.
*   **🎨 Customização Dinâmica por Identidade Visual:** Cadastro completo do Perfil do Criador contendo nome, clube associado (opcional), cidade, estado e até 4 raças focais do criatório. O sistema lê o arquivo de logo do canaril anexado para extrair e reconfigurar as paletas de cores internas do aplicativo dinamicamente.
*   **🌳 Rastreabilidade e Árvore Genealógica:** Banco de dados expandido com suporte a filiação direta (`idPaiAnilha` e `idMaeAnilha`). Implementação de algoritmos de busca recursiva capazes de compilar e exportar árvores genealógicas completas para emissão de certificados de linhagem.
*   **🛒 Rastreamento Avançado de Origem de Plantel:** Registro minucioso sobre a procedência de novas matrizes inseridas no plantel, com campos para identificar se o pássaro é nascido no criatório, adquirido de terceiros (com especificação do clube e nome do canaril) ou comprado em pet shops/lojas comerciais.
*   **📊 Central de Exportação de Dados:** Módulo analítico capaz de compilar dados complexos do banco de dados em arquivos formatados estruturados (padrão CSV). Permite extrair relatórios de auditoria ornitológica de matrizes ativas, taxas de fertilidade acumuladas e histórico financeiro de saídas.
*   **🗄️ Arquitetura SQLite Relacional Offline:** Integração nativa e blindada com o motor de banco de dados SQLite (`sqflite`). Todos os canários, prontuários clínicos e ciclos de choco ficam persistidos com segurança na memória interna do smartphone do criador, permitindo funcionamento 100% independente de internet dentro do criatório.
*   **🧪 Suite de Testes Automatizados:** Cobertura de testes unitários (`flutter_test`) na raiz do projeto para validar algoritmos de cálculo de fertilidade, prevenções de erros matemáticos (divisão por zero) e precisão na geração dos cronogramas biológicos de choco de 13 dias.
*   **🔬 Laboratório de Acasalamento (Anti-Fator Letal):** Algoritmo de cruzamento em tempo real que analisa o genótipo do casal selecionado. Bloqueia e emite alertas estruturais de risco caso o usuário tente cruzar duas aves *Com Topete* (Fator Letal Homozigótico de 25% de mortalidade embrionária nos ovos).
*   **📱 Navegação Circular Centralizada:** Painel estruturado através de um componente `BottomNavigationBar` de 5 posições acoplado a um `IndexedStack`. Isso permite que o criador navegue entre todas as abas do aplicativo instantaneamente sem perder as informações preenchidas ou o estado de carregamento das telas.

## 🗄️ Arquitetura do Repositório (Padrão Clean e Modular)

```text
canary_control_pro/
├── .github/workflows/       # 🚀 Configurações de compilação em nuvem (CI/CD)
│   └── build_app.yml             # Script v4 de automação de testes e geração de APK via Commits ou Tags
├── assets/                  # Armazenamento de mídias e fotos do plantel (.gitkeep)
├── lib/
│   ├── database/            # Camada de Persistência Local Segura (SQLite V2)
│   │   └── db_helper.dart        # Inicialização do banco de dados e operações CRUD nativas (Aves, Saúde, Choco, Perfil)
│   ├── models/              # Camada de Dados, Getters e Regras de Negócio Nativas
│   │   ├── ave_model.dart        # Cadastro de aves, mutações FOB, procedência e filiação para SQLite
│   │   ├── ciclo_model.dart      # Gatilhos biológicos e cronograma automatizado do choco com suporte toMap/fromMap
│   │   ├── criador_model.dart    # Configurações do perfil do criador e lógica multiraças (Até 4 raças)
│   │   └── saude_model.dart      # Prontuário médico e histórico clínico de tratamentos com mapeamento SQLite
│   ├── screens/             # Camada Visual (Interface Gráfica com o Criador)
│   │   ├── baixa_screen.dart     # Gerenciamento de saídas, vendas e óbitos do plantel
│   │   ├── ciclo_screen.dart     # Calendário de reprodução e alertas de manejo do choco
│   │   ├── dashboard_screen.dart # Simulador genético e ranking de reprodutores
│   │   ├── exportacao_screen.dart# Painel de compilação de relatórios e exportação CSV com árvores genealógicas
│   │   ├── login_screen.dart     # Tela de login e autenticação com validação de chaves
│   │   ├── navigation_screen.dart# Controlador central do menu inferior (Abas)
│   │   └── saude_screen.dart     # Lançamento e consulta de prontuários médicos
│   └── main.dart            # Ponto de inicialização do app e gerenciamento do tema escuro
├── test/                    # 🧪 Camada de Testes Automatizados e Validação de Algoritmos
│   └── reproducao_test.dart      # Validação de taxas de fertilidade e cronograma do choco
└── pubspec.yaml             # Arquivo de configuração de pacotes, dependências (sqflite, path) e SDK
```

## 🛠️ Requisitos de Ambiente

*   **Flutter SDK:** `>= 3.0.0`
*   **Dart Language:** `>= 3.0.0 < 4.0.0`
*   **Dependências Principais:** `sqflite` (Banco de dados), `path` (Diretórios do sistema), `cupertino_icons` (Icons).
*   
