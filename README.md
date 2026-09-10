# 🦅 CanaryControl Pro (Ambiente Corporativo de Seleção)

O **CanaryControl Pro** é um ecossistema mobile de alta performance desenvolvido em Flutter para gestão zootécnica, controle sanitário com ciclos de tratamento, rastreabilidade de haras por gaiolas (Bigamia/Poligamia) e geração recursiva de árvores genealógicas ancestrais, em estrita conformidade com os regulamentos da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades de Produção Implementadas

*   **⚙️ Ambiente de Produção 100% Limpo e Editável:** Remoção completa de dados simulados ("mock data") de todas as interfaces. O ecossistema inicia completamente limpo; todas as consultas realizam transações dinâmicas de leitura e escrita em tabelas locais físicas do banco de dados SQLite.
*   **🧬 Módulo de Retrocruzamento Genético:** Interface especializada para planejar acasalamentos de retorno consanguíneo entre filhotes portadores e ancestrais puros (PAI/MÃE) para fixação de mutações e apuração de linhagens padrão F1, F2 e F3.
*   **📐 Gestão Avançada de Rotinas de Macho:** Gerenciamento de poligamia/bigamia por gaiola física indexada. O criador agenda o comportamento do reprodutor: se permanece junto, se sai no 3º ovo ou se opera em janela estrita de cópula (das 5h às 9h).
*   **⏱️ Automação de Desmame e Descanso:** Linha cronológica calculada a partir do choco que emite o gatilho automático de desmame aos 35 dias totais (22 dias pós-nascimento), indicando o descanso imediato da matriz.
*   **🔔 Alertas Offline em Segundo Plano (Manejos e Ciclos):** Sistema integrado via `flutter_local_notifications` e mapeado com fusos horários locais `timezone`. Dispara notificações de alta prioridade na tela do celular mesmo que o aplicativo esteja totalmente fechado, avisando sobre Ovoscopia, Banheira, Nascimento, Desmame e término de tratamentos clínicos.
*   **🛡️ Correção Estrutural de Escrita (SQLite V3):** Sanado o impedimento de salvamento através de políticas de injeção direta de conflito (`ConflictAlgorithm.replace`), garantindo persistência imediata offline.

## 🗄️ Arquitetura do Repositório (Padrão Clean e Modular)

```text
canary_control_pro/
├── .github/workflows/       # 🚀 Configurações de compilação em nuvem (CI/CD)
│   └── build_app.yml             # Script v4 de automação de testes, geração de arquivos Android e compilação do APK
├── assets/                  # Armazenamento de mídias e mídias do plantel (.gitkeep)
├── lib/
│   ├── database/            # Camada de Persistência Local Segura (SQLite V3)
│   │   └── db_helper.dart        # Operações CRUD nativas e árvore genealógica recursiva
│   ├── models/              # Camada de Dados, Getters e Regras de Negócio Nativas
│   │   ├── ave_model.dart        # Cadastro de aves, mutações FOB, procedência e gaiolas
│   │   ├── ciclo_model.dart      # Estrutura de acasalamento composto (Poligamia/Bigamia)
│   │   ├── criador_model.dart    # Configurações do perfil com suporte a siglas (Ex: SOGO)
│   │   └── saude_model.dart      # Prontuário médico e histórico de tratamentos
│   ├── screens/             # Camada Visual (Interface Gráfica com o Criador)
│   │   ├── ciclo_screen.dart     # Calendário de reprodução e rotinas do macho sem dados fictícios
│   │   ├── dashboard_screen.dart # Painel profissional com injeção cromática automática via logo
│   │   ├── login_screen.dart     # Tela de login e autenticação com validação de chaves
│   │   ├── navigation_screen.dart# Controlador do menu inferior unificado (Abas)
│   │   ├── plantel_cadastro_screen.dart # Cadastro editável de aves, gaiolas e notas FOB com trava de topete
│   │   └── saude_screen.dart     # Lançamento e consulta de prontuários médicos limpos por formulário
│   ├── services/            # Serviços de Hardware do Dispositivo Móvel
│   │   └── notification_service.dart # Despachador de notificações agendadas em segundo plano offline
│   └── main.dart            # Ponto de inicialização do app e gerenciamento do tema escuro
└── pubspec.yaml             # Arquivo de configuração de pacotes, dependências (sqflite, path) e SDK
```
