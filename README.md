# 🦅 CanaryControl Pro

O **CanaryControl Pro** é um ecossistema mobile profissional desenvolvido em Flutter para a gestão avançada, controle sanitário, monitoramento reprodutivo e mapeamento genético de canarís, totalmente alinhado às diretrizes técnicas e nomenclaturas da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades Implementadas

*   **🔬 Laboratório de Acasalamento (Anti-Fator Letal):** Algoritmo de cruzamento em tempo real que analisa o genótipo do casal selecionado. Bloqueia e emite alertas estruturais de risco caso o usuário tente cruzar duas aves *Com Topete* (Fator Letal Homozigótico de 25% de mortalidade embrionária nos ovos).
*   **📊 Ranking de Fertilidade Dinâmico:** Dashboard analítico que calcula de forma automática a taxa de fertilidade com base nos getters reais de `Ovos Galados` / `Ovos Totais`, gerando uma classificação instantânea dos melhores reprodutores e matrizes do plantel.
*   **🏥 Prontuário Clínico Digital:** Módulo avançado para monitoramento de sintomas e doenças comuns (como Peito Seco/Coccidiose e Ácaro de Traqueia), histórico de tratamentos ministrados com controle rigoroso de dosagens e status clínico (Em Tratamento, Curado ou Óbito).
*   **🥚 Calculadora Biológica de Choco:** Agenda automatizada de manejo ativada a partir da data de início do choco para dar previsibilidade ao criador e evitar o abandono do ninho. Gera gatilhos cronológicos exatos para:
    *   *7º Dia:* Ovoscopia (Identificação de ovos galados)
    *   *12º Dia:* Colocação da banheira (Aumento da umidade para quebrar a casca)
    *   *13º Dia:* Previsão exata do nascimento dos filhotes
    *   *18º Dia:* Período ideal para anilhamento oficial
*   **🍂 Registro de Baixas do Plantel:** Módulo especializado para controle rigoroso do inventário e ciclo de vida das aves. Registra as saídas do criatório categorizadas por motivo comercial ou clínico (Venda com valor/comprador, Doação ou Óbito detalhado), permitindo futuras auditorias de mortalidade e faturamento.
*   **📱 Navegação Circular Centralizada:** Painel estruturado através de um componente `BottomNavigationBar` acoplado a um `IndexedStack`. Isso permite que o criador navegue entre todas as abas do aplicativo instantaneamente sem perder as informações preenchidas ou o estado das telas.

## 🗄️ Arquitetura do Repositório (Padrão Clean e Modular)

A estrutura de arquivos do projeto está organizada de forma a isolar as responsabilidades e garantir que o aplicativo funcione de maneira rápida, sem travamentos na listagem de dados:

```text
canary_control_pro/
├── assets/                  # Armazenamento de mídias e fotos do plantel (.gitkeep)
├── lib/
│   ├── models/              # Camada de Dados, Getters e Regras de Negócio Nativas
│   │   ├── ave_model.dart        # Cadastro de aves, mutações FOB, portadores e controle de baixas
│   │   ├── ciclo_model.dart      # Gatilhos biológicos e cronograma automatizado do choco
│   │   └── saude_model.dart      # Prontuário médico e histórico clínico de tratamentos
│   ├── screens/             # Camada Visual (Interface Gráfica com o Criador)
│   │   ├── baixa_screen.dart     # Gerenciamento de saídas, vendas e óbitos do plantel
│   │   ├── ciclo_screen.dart     # Calendário de reprodução e alertas de manejo do choco
│   │   ├── dashboard_screen.dart # Simulador genético e ranking de reprodutores
│   │   ├── navigation_screen.dart# Controlador central do menu inferior (Abas)
│   │   └── saude_screen.dart     # Lançamento e consulta de prontuários médicos
│   └── main.dart            # Ponto de inicialização do app e gerenciamento do tema escuro
└── pubspec.yaml             # Arquivo de configuração de pacotes, dependências e SDK do Flutter
```

## 🎨 Identidade Visual e Interface

O aplicativo foi projetado sob as diretrizes do Material Design em **Dark Mode**, garantindo conforto visual para o uso dentro do criatório, utilizando como base a cor **Amarelo Canário Canônico (`#FFD700`)** para destaques de status e alertas prioritários.

## 🛠️ Requisitos de Ambiente

*   **Flutter SDK:** `>= 3.0.0`
*   **Dart Language:** `>= 3.0.0 < 4.0.0`
*   **Dependências:** `cupertino_icons` para elementos visuais nativos e regras de análise lint ativas (`flutter_lints`).
*   
