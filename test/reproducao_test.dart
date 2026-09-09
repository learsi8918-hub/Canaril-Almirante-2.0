import 'package:flutter_test/flutter_test.dart';
import '../lib/models/ave_model.dart';
import '../lib/models/ciclo_model.dart';

void main() {
  group('🧪 Testes de Regras Ornitológicas - CanaryControl Pro', () {
    
    test('📋 Deve calcular a taxa de fertilidade corretamente baseado nos ovos galados', () {
      // Cria uma ave de teste usando o construtor nativo
      final ave = Ave(
        anilha: '123',
        clubeSigla: 'FOB',
        sexo: 'F',
        tipoFob: 'Canário de Cor',
        mutacaoRaca: 'Amarelo Mosaico',
        porteDetalhe: 'Sem Topete',
        comTopete: false,
        fotoPath: '',
      );

      // Simula os dados de postura acumulados
      ave.totalOvos = 10;
      ave.ovosFerteis = 8;

      // Executa a função getter do modelo que criamos
      expect(ave.taxaFertilidade, equals(80.0));
    });

    test('⚠️ Deve disparar o gatilho biológico correto de 13 dias para o nascimento', () {
      final dataChoco = DateTime(2026, 10, 1); // 1 de Outubro de 2026
      
      final ciclo = CicloReproducao(
        idGaiola: 'Gaiola 01',
        idMacho: 'SO-001',
        idFemea: 'SO-002',
        dataInicioChoco: dataChoco,
        tipoManejoMacho: 'Sempre Junto',
      );

      // A previsão de nascimento obrigatoriamente precisa ser 13 dias após o choco
      final dataNascimentoEsperada = DateTime(2026, 10, 14);
      
      expect(ciclo.dataNascimento, equals(dataNascimentoEsperada));
    });

    test('🔬 Deve retornar taxa zero se a ave nunca tiver botado ovos (Prevenção de divisão por zero)', () {
      final aveNova = Ave(
        anilha: '999',
        clubeSigla: 'SO',
        sexo: 'M',
        tipoFob: 'Canário de Porte',
        mutacaoRaca: 'Arlequim Português',
        porteDetalhe: 'Sem Topete',
        comTopete: false,
        fotoPath: '',
      );

      // Ovos totais = 0. Não pode travar o aplicativo!
      expect(aveNova.taxaFertilidade, equals(0.0));
    });
  });
}
