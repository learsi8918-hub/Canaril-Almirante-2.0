# 🦅 CanaryControl Pro (Ambiente Corporativo de Seleção)

O **CanaryControl Pro** é um ecossistema mobile de alta performance desenvolvido em Flutter para gestão zootécnica, controle sanitário com ciclos de tratamento, rastreabilidade de haras por gaiolas (Bigamia/Poligamia) e geração recursiva de árvores genealógicas ancestrais, em estrita conformidade com os regulamentos da **FOB (Federação Ornitológica Brasileira)**.

## 🚀 Novas Funcionalidades de Produção Implementadas

*   **🛡️ Correção Estrutural de Escrita (SQLite V3):** Remodelagem das camadas de mapeamento relacional. Sanado o impedimento de salvamento através de políticas de injeção direta de conflito (`ConflictAlgorithm.replace`), garantindo persistência imediata offline.
*   **🌳 Algoritmo Ancestral de Linhagem:** Sistema de busca recursiva profunda no SQLite que monta e exportar a árvore genealógica de filhotes até a terceira geração (Pais e Avós).
*   **⏱️ Automação Biológica de Status:** O status das fêmeas transmuta automaticamente de acordo com as datas estabelecidas (Postura, Choco, com Filhotes e Descanso automatizado na data calculada de desmame).
*   **🔬 Trava de Acasalamento Crítico:** Verificação estrita de fenótipos que emite alertas impeditivos caso haja tentativa de cruzamento entre exemplares *Topete x Topete* (Fator Letal Homozigótico).
*   **🔔 Sistema Operacional de Alertas em Segundo Plano:** Estrutura mapeada para despachar notificações locais agendadas de manejos (Ovoscopia, Nascimento, Anilhamento e Desmame) mesmo com o aplicativo fechado.

## 🗄️ Arquitetura das Tabelas do Banco de Dados

*   **`perfil_criador`**: Armazena as chaves de identidade regional, clube (Strict: 2 letras) e o vetor que dita a reconfiguração cromática dinâmica do app.
*   **`aves`**: Matrizes indexadas por chave primária composta contendo histórico reprodutivo completo (ovos, férteis, não-férteis, taxas de eclosão e abandonos de ninho).
*   **`ciclos_reproducao`**: Gerenciador multifêmeas por gaiolas configuradas para Monogamia, Bigamia ou Poligamia, mapeando o tempo de retirada do macho (*Sempre Junto*, *3º Ovo*, *Janela de Cópula*).
*   
