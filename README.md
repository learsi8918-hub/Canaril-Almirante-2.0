# 🦅 CanaryControl Pro (Ambiente Corporativo de Seleção)

O **CanaryControl Pro** é um ecossistema mobile de alta performance desenvolvido em Flutter para gestão zootécnica, controle sanitário com ciclos de tratamento, rastreabilidade de haras por gaiolas (Bigamia/Poligamia) e geração recursiva de árvores genealógicas ancestrais, em estrita conformidade com os regulamentos da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Novas Funcionalidades de Produção Implementadas

*   **🧬 Módulo de Retrocruzamento Genético:** Interface especializada e limpa para planejar acasalamentos de retorno consanguíneo entre filhotes portadores e ancestrais puros (PAI/MÃE) para fixação de mutações e apuração de linhagens padrão F1, F2 e F3.
*   **📐 Gestão Avançada de Rotinas de Macho:** Gerenciamento cirúrgico de poligamia/bigamia por gaiola. O criador agenda o comportamento do reprodutor: se permanece junto, se sai no 3º ovo ou se opera em janela estrita de cópula (das 5h às 9h).
*   **⏱️ Automação de Desmame e Descanso:** Linha cronológica calculada a partir do choco que emite o gatilho automático de desmame aos 35 dias, alterando o status da matriz fêmea para "Descanso" e liberando os filhotes.
*   **🛡️ Correção Estrutural de Escrita (SQLite V3):** Sanado o impedimento de salvamento através de políticas de injeção direta de conflito (`ConflictAlgorithm.replace`), garantindo persistência imediata offline.

## 🗄️ Arquitetura do Repositório (Padrão Clean e Modular)

```text
canary_control_pro/
├── .github/workflows/       # 🚀 Configurações de compilação em nuvem (CI/CD)
│   └── build_app.yml             # Script v4 de automação de testes e compilação do APK
├── assets/                  # Armazenamento de mídias e fotos do plantel (.gitkeep)
├── lib/
│   ├── database/            # Camada de Persistência Local Segura (SQLite V2)
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
│   └── main.dart            # Ponto de inicialização do app e gerenciamento do tema escuro
└── pubspec.yaml             # Arquivo de configuração de pacotes, dependências (sqflite, path) e SDK
```
