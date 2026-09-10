import 'package:flutter_test/flutter_test.dart';
import '../lib/models/ave_model.dart';
import '../lib/models/ciclo_model.dart';

void main() {
  group('🧪 Testes de Regras Ornitológicas - CanaryControl Pro', () {
    
    test('📋 Deve calcular a taxa de fertilidade corretamente baseado nos ovos galados', () {
      final ave = Ave(
        anilha: '123',
        clubeSigla: 'FOB',
        sexo: 'F',
        tipoFob: 'Canário de Cor',
        mutacaoRaca: 'Amarelo Mosaico',
        porteDetalhe: 'Sem Topete',
        comTopete: false,
        fotoPath: '',
        numeroGaiola: '15', 
        origemTipo: 'Nascido no Canaril',
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

    test('🔬 Deve retornar taxa zero se a ave nunca tiver botado ovos (Prevenção de divisão por zero)', () {
      final aveNova = Ave(
        anilha: '999',
        clubeSigla: 'SOGO',
        sexo: 'M',
        tipoFob: 'Canário de Porte',
        mutacaoRaca: 'Arlequim Português',
        porteDetalhe: 'Sem Topete',
        comTopete: false,
        fotoPath: '',
        numeroGaiola: '12', 
        origemTipo: 'Nascido no Canaril',
      );

      expect(aveNova.taxaFertilidade, equals(0.0));
    });
  });
}
