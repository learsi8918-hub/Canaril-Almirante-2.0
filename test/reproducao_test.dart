import 'package:flutter_test/flutter_test.dart';
import '../lib/models/ave_model.dart';
import '../lib/models/ciclo_model.dart';

void main() {
  group('🧪 Testes de Regras Ornitológicas - CanaryControl Pro', () {
    
    test('📋 Deve calcular a taxa de fertilidade corretamente baseado nos ovos galados', () {
      final ave = Ave(
        anilha: '123',
        clubeSigla: 'FO',
        sexo: 'F',
        segmentoFob: 'Canário de Cor',
        variacao: 'Amarelo Mosaico',
        mutacaoEscrita: '',
        comTopete: false,
        numeroGaiola: '15', 
        origemTipo: 'Nascido no Canaril',
        status: 'Descanso',
      );

      ave.totalOvos = 10;
      ave.ovosFerteis = 8;

      expect(ave.taxaFertilidade, equals(80.0));
    });

    test('⚠️ Deve disparar o gatilho biológico correto de 13 dias para o nascimento', () {
      final dataChoco = DateTime(2026, 10, 1);
      
      final ciclo = CicloReproducao(
        idGaiola: 'Gaiola 15',
        sistemaAcasalamento: 'Bigamia', 
        idMacho: 'GZ-035',
        idFemea: 'OZ-012',
        dataInicioChoco: dataChoco,
      );

      final dataNascimentoEsperada = DateTime(2026, 10, 14);
      
      expect(ciclo.dataNascimento, equals(dataNascimentoEsperada));
    });
  });
}
