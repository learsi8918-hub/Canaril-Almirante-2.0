# 🦅 CanaryControl Pro

O **CanaryControl Pro** é um ecossistema mobile profissional desenvolvido em Flutter para a gestão avançada, controle sanitário, monitoramento reprodutivo e mapeamento genético de canarís, totalmente alinhado às diretrizes técnicas e nomenclaturas da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades Implementadas

*   **📐 Gestão Harem / Bigamia / Poligamia:** Controle avançado de manejo reprodutivo por gaiolas físicas indexadas. Vincula de forma independente o histórico de postura e eclosão de cada fêmea acasalada com o mesmo reprodutor macho (Ex: Gaiola 15 - Fêmea OZ-012 acasalada em Bigamia com Macho GZ-035).
*   **📊 Rankings de Fertilidade Duplos (Machos e Fêmeas):** Módulo de auditoria de plantel que calcula de forma isolada as taxas de eficiência reprodutiva por sexo, identificando de forma clara quais machos e quais fêmeas são as melhores matrizes do plantel.
*   **✍️ Banco de Dados Clínico e de Mutação Customizável:** Interface com campos editáveis adicionais permitindo incluir observações fenotípicas, mutações raras personalizadas fora da tabela estática FOB e notas clínicas por exemplar.
*   **🎨 Customização Dinâmica por Identidade Visual:** Cadastro completo do Perfil do Criador contendo nome, clube associado (opcional), cidade, estado e até 4 raças focais do criatório. O sistema lê o arquivo de logo do canaril anexado para extrair e reconfigurar as paletas de cores internas do aplicativo dinamicamente.
*   **🗄️ Arquitetura SQLite Relacional Offline:** Integração nativa e blindada com o motor de banco de dados SQLite (`sqflite`). Todos os canários, prontuários clínicos e ciclos de choco ficam persistidos com segurança na memória interna do smartphone do criador, permitindo funcionamento 100% independente de internet dentro do criatório.

## 🗄️ Arquitetura do Repositório (Padrão Clean e Modular)

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
│   │   ├── ciclo_model.dart      # Gatilhos biológicos e cronograma automatizado do choco com suporte toMap/fromMap
│   │   ├── criador_model.dart    # Configurações do perfil do criador e lógica multiraças (Até 4 raças)
│   │   └── saude_model.dart      # Prontuário médico e histórico clínico de tratamentos com mapeamento SQLite
```
