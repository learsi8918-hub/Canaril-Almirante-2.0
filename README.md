# 🦅 CanaryControl Pro (Ambiente Corporativo de Seleção)

O **CanaryControl Pro** é um ecossistema mobile de alta performance desenvolvido em Flutter para gestão zootécnica, controle sanitário com ciclos de tratamento, rastreabilidade de haras por gaiolas (Bigamia/Poligamia) e geração recursiva de árvores genealógicas ancestrais, em estrita conformidade com os regulamentos e tabelas da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades de Produção Implementadas

*   **⚙️ Ambiente de Produção 100% Limpo e Editável:** Remoção completa de dados simulados ("mock data") e exemplos estáticos de todas as interfaces. O ecossistema inicia completamente limpo de fábrica; todas as consultas, listagens e gráficos realizam transações dinâmicas de leitura e escrita em tabelas locais físicas do banco de dados SQLite.
*   **🎨 Reconhecimento Cromático Automático por Logo:** Mecanismo de inteligência visual integrado ao ciclo de estado global do aplicativo. Assim que o criador realiza o cadastro ou atualização da logo do canaril no painel corporativo, o sistema identifica e extrai a tonalidade dominante da marca (Amarelo, Azul, Verde ou Vermelho) para reconfigurar a paleta de cores e os destaques estéticos do aplicativo inteiro em tempo real.
*   **🦅 Central de Cadastro de Matrizes (Plantel Dinâmico):** Inclusão com formulários estruturados de validação para registrar aves informando o número da anilha, sigla oficial customizável do clube limitada de forma estrita a **exatamente 2 letras** (Ex: OZ, GZ, GO), número físico da gaiola, sexo (Macho/Fêmea) para segregação de dashboards, e seleção do fator genético de topete.
*   **🧬 Módulo de Retrocruzamento Genético:** Interface de engenharia biológica projetada para planejar acasalamentos consanguíneos de retorno entre filhotes portadores e ancestrais puros (PAI/MÃE) para fixação de mutações raras e apuração de linhagens padrão F1 (50% de sangue), F2 (75% de sangue) e F3 (87.5% de sangue).
*   **📐 Gestão Multifêmeas por Gaiola (Bigamia e Poligamia):** Reestruturação relacional completa para controle de haras e gaiolas compartilhadas. Permite indexar e rastrear de forma isolada qual fêmea realizou a postura e eclosão de ovos ligada ao mesmo macho reprodutor (Ex: Gaiola 15 - Fêmea OZ-012 em Bigamia com Macho GZ-035).
*   **⏱️ Automação de Rotinas do Macho e Desmame:** Monitoramento do comportamento do reprodutor: se permanece junto, se sai no 3º ovo ou se opera em janela estrita de cópula (das 5h às 9h). A linha cronológica calcula o gatilho automático de desmame aos 35 dias totais (22 dias pós-nascimento), alterando o status da matriz fêmea para "Descanso" automaticamente.
*   **🏥 Prontuário Clínico & Quarentena Dinâmica:** Módulo de controle sanitário expandido que opera com ciclos fechados e estritos de medicação na água por 5 dias. Permite isolar exemplares doentes registrando diagnóstico (Peito Seco/Coccidiose, Ácaro de Traqueia) e conduta terapêutica diretamente no banco de dados local.
*   **🌳 Rastreabilidade e Árvore Genealógica Recursiva:** Banco de dados expandido com suporte a filiação direta (`idPaiAnilha` e `idMaeAnilha`). Implementação de algoritmos de busca recursiva profunda capazes de compilar a árvore genealógica de filhotes até a terceira geração (Pais e Avós).
*   **🛒 Rastreamento Detalhado de Origem:** Mapeia rigorosamente o histórico de procedência, incluindo o tipo de aquisição (Nascido, Adquirido ou Pet Shop), o nome do criador/canaril vendedor e a sigla do respectivo clube de origem.
*   **📊 Rankings Reprodutivos Segregados (Machos e Fêmeas):** Módulo de auditoria biológica de alta performance que isola e classifica de forma 100% independente a eficiência de fertilidade dos Reprodutores (Machos) e das Matrizes (Fêmeas) com base no histórico acumulado de ovos galados, brancos e abandonos de ninho salvos no banco.
*   **📊 Central de Exportação de Dados:** Módulo analítico capaz de compilar dados complexos do banco de dados em arquivos formatados estruturados (padrão CSV), prontos para backup ou auditorias externas de linhagem.
*   **🔔 Alertas Offline em Segundo Plano (Manejos e Ciclos):** Sistema integrado via `flutter_local_notifications` e mapeado com fusos horários locais `timezone`. Dispara notificações de alta prioridade na tela do celular mesmo que o aplicativo esteja totalmente fechado, avisando sobre Ovoscopia (7º dia), Banheira (12º dia), Nascimento (13º dia), Desmame (35º dia) e término de tratamentos clínicos de 5 dias.
*   **📱 Navegação Circular Centralizada:** Painel estruturado através de um componente `BottomNavigationBar` de 5 posições acoplado a um `IndexedStack`. Isso permite que o criador navegue entre todas as abas do aplicativo instantaneamente sem perder as informações preenchidas ou o estado de carregamento das telas.
*   **🛡️ Compilação Nativa por Varredura Dinâmica (CI/CD v4):** Pipeline automatizado via GitHub Actions configurado com rotinas de busca exaustiva via comando `find` no ambiente Linux da nuvem, garantindo a localização e a injeção em tempo real de metadados do Gradle para suporte a Java 8 Desugaring exigido pelo motor de alarmes offline.

## 🗄️ Arquitetura do Repositório (Padrão Clean e Modular)

A estrutura de arquivos do projeto está organizada de forma a isolar as responsabilidades e garantir que o aplicativo funcione de maneira rápida, sem travamentos na listagem de dados:

```text
canary_control_pro/
├── .github/workflows/       # 🚀 Configurações de compilação em nuvem (CI/CD)
│   └── build_app.yml             # Script v4 de automação de testes, varredura de Gradle e compilação do APK
├── assets/                  # Armazenamento seguro de mídias e logos do criatório (.gitkeep)
├── lib/
│   ├── database/            # Camada de Persistência Local Segura (SQLite V3)
│   │   └── db_helper.dart        # Inicialização do banco de dados, transações CRUD e buscas recursivas de linhagem
│   ├── models/              # Camada de Dados, Getters e Regras de Negócio Nativas
│   │   ├── ave_model.dart        # Cadastro de aves, catálogo FOB, procedência, gaiolas e travas de topete
│   │   ├── ciclo_model.dart      # Gatilhos biológicos e cronograma de choco adaptado para Bigamia/Poligamia por gaiola
│   │   ├── criador_model.dart    # Configurações do perfil do criador com suporte a siglas customizadas curtas (2 letras)
│   │   └── saude_model.dart      # Prontuário médico e histórico clínico de tratamentos com mapeamento SQLite
│   ├── screens/             # Camada Visual (Interface Gráfica Dinâmica Editável)
│   │   ├── ciclo_screen.dart     # Calendário de reprodução e rotinas do macho sem dados fictícios
│   │   ├── dashboard_screen.dart # Painel do criador limpo com injeção cromática e rankings segregados do SQLite
│   │   ├── exportacao_screen.dart# Painel de compilação de relatórios e exportação CSV limpa
│   │   ├── login_screen.dart     # Tela de login e autenticação com validação de chaves do criador
│   │   ├── navigation_screen.dart# Controlador central do menu inferior unificado (Abas)
│   │   ├── plantel_cadastro_screen.dart # Cadastro e gerenciamento editável de aves, gaiolas e notas FOB com trava de topete
│   │   └── saude_screen.dart     # Lançamento e consulta de prontuários médicos limpos por formulário
│   ├── services/            # Serviços de Hardware do Dispositivo Móvel
│   │   └── notification_service.dart # Despachador de notificações agendadas em segundo plano offline
│   └── main.dart            # Ponto de inicialização do app, carregamento nativo e gerenciamento do tema escuro
├── test/                    # 🧪 Camada de Testes Automatizados e Validação de Algoritmos
│   └── reproducao_test.dart      # Validação sincronizada das regras de negócio de fertilidade e choco consanguíneo
└── pubspec.yaml             # Arquivo de configuração de pacotes, dependências (sqflite, path, notifications) e SDK
```

## 🗺️ Modelagem Relacional do Banco de Dados

*   **`aves`**: Tabela principal indexada com chave primária composta por `(clubeSigla, anilha)`, expandida com rastreabilidade de linhagem, número de gaiola e procedência comercial detalhada.
*   **`perfil_criador`**: Tabela de configuração única para armazenar dados regionais, clube oficial editável (Strict: 2 letras) e marcas cromáticas dinâmicas do criatório.
*   **`historico_saude`**: Tabela de prontuários com relacionamento relacional associado à ave em tratamento e ciclos de 5 dias.
*   **`ciclos_reproducao`**: Tabela de controle de choco identificada pela chave composta `(idGaiola, idFemea)`, suportando regras de acasalamento composto para múltiplas fêmeas (Haras/Bigamia).

## 🛠️ Requisitos de Ambiente

*   **Flutter SDK:** `>= 3.0.0`
*   **Dart Language:** `>= 3.0.0 < 4.0.0`
*   **Dependências Principais:** `sqflite` (Banco de dados), `path` (Diretórios do sistema), `flutter_local_notifications` (Alertas em segundo plano), `timezone` (Fusos horários nativos), `cupertino_icons` (Icons).
*   
