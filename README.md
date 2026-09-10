# 🦅 CanaryControl Pro

O **CanaryControl Pro** é um ecossistema mobile profissional desenvolvido em Flutter para a gestão avançada, controle sanitário, monitoramento reprodutivo e mapeamento genético de canarís, totalmente alinhado às diretrizes técnicas e nomenclaturas da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Funcionalidades Implementadas

*   **🔔 Alertas Offline em Segundo Plano (Manejos e Ciclos):** Sistema integrado via `flutter_local_notifications` e mapeado com fusos horários locais `timezone`. Dispara notificações de alta prioridade na tela do celular mesmo que o aplicativo esteja totalmente fechado, avisando sobre Ovoscopia, Banheira, Nascimento, Desmame e término de tratamentos clínicos de 5 dias.
*   **⚙️ Ambiente de Produção 100% Limpo e Editável:** Remoção completa de dados simulados ("mock data") e exemplos estáticos do código de todas as interfaces. O ecossistema inicia completamente limpo de fábrica; todas as consultas, listagens e renderizações realizam transações dinâmicas de leitura e escrita em tabelas locais físicas do banco de dados SQLite.
*   
