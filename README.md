# 🦅 CanaryControl Pro

O **CanaryControl Pro** é um ecossistema mobile profissional desenvolvido em Flutter para a gestão avançada, controle sanitário, controle reprodutivo e mapeamento genético de canarís, totalmente alinhado aos padrões da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades Principais

*   **🧬 Laboratório de Acasalamento (Anti-Fator Letal):** Algoritmo inteligente que analisa o genótipo do casal selecionado. Bloqueia e emite alertas vermelhos caso o usuário tente cruzar duas aves *Com Topete* (Fator Letal Homozigótico de 25% de morte embrionária).
*   **📊 Ranking de Fertilidade Dinâmico:** Dashboard que calcula automaticamente a taxa de fertilidade com base nos getters reais de Ovos Galados / Ovos Totais, destacando os melhores reprodutores do plantel.
*   **🏥 Prontuário Clínico Digital:** Aba especializada para monitorar sintomas (ex: Peito Seco, Ácaro de Traqueia), histórico de tratamentos com dosagens e controle de quarentena.
*   **🥚 Calculadora Biológica de Choco:** Automação de datas críticas a partir do início do choco para evitar o abandono do ninho (Gera alertas exatos para Ovoscopia no 7º dia, Banheira no 12º dia e Nascimento no 13º dia).
*   **🍂 Gerenciamento de Baixas:** Controle rigoroso de saída de aves por venda, doação ou óbito, gerando estatísticas de mortalidade do canaril.

## 🗄️ Arquitetura do Repositório (Padrão Clean)

```text
lib/
├── models/          # Camada de Dados e Regras de Negócio Nativas
│   ├── ave_model.dart          # Cadastro de aves, mutações FOB e portadores
│   ├── ciclo_model.dart        # Gatilhos biológicos e datas do choco
│   └── saude_model.dart        # Ficha médica e histórico clínico
├── screens/         # Camada Visual (Interface com o Criador)
│   ├── dashboard_screen.dart   # Simulador genético e rankings
│   └── saude_screen.dart       # Lançamento de prontuários médicos
└── main.dart        # Inicialização do app e gerenciamento do tema escuro
```

## 🛠️ Tecnologias Utilizadas

*   [Flutter SDK](https://flutter.dev) >= 3.0.0
*   [Dart Language](https://dart.dev)
*   Estilização Customizada em Dark Mode (Amarelo Canário Canônico `#FFD700`)
