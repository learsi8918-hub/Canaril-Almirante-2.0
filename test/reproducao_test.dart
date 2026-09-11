import 'package:flutter_test/flutter_test.dart';
import '../lib/models/ave_model.dart';
import '../lib/models/ciclo_model.dart';

void main() {
  group('Testes dos modelos - CanaryControl Pro V13.1', () {
    test('Deve criar uma Ave corretamente', () {
      final ave = Ave(
        anilha: '123',
        clubeSigla: 'FO',
        sexo: 'F',
        segmentoFob: 'Canário de Cor',
        mutacaoEscrita: 'Amarelo Mosaico',
        comTopete: false,
        numeroGaiola: '15',
        origemTipo: 'Nascido no Canaril',
        status: 'Descanso',
      );

      expect(ave.anilha, equals('123'));
      expect(ave.sexo, equals('F'));
      expect(ave.numeroGaiola, equals('15'));
      expect(ave.comTopete, isFalse);
    });

    test('Deve criar um Ciclo corretamente', () {
      final dataInicio = DateTime(2026, 10, 1);

      final ciclo = Ciclo(
        sistema: 'Bigamia',
        manejoMacho: 'Sempre Junto',
        dataInicio: dataInicio,
      );

      expect(ciclo.sistema, equals('Bigamia'));
      expect(ciclo.manejoMacho, equals('Sempre Junto'));
      expect(ciclo.dataInicio, equals(dataInicio));
    });

    test('Deve converter Ave para Map corretamente', () {
      final ave = Ave(
        anilha: 'GZ-035',
        clubeSigla: 'FO',
        sexo: 'M',
        segmentoFob: 'Canário de Cor',
      );

      final mapa = ave.toMap();

      expect(mapa['anilha'], equals('GZ-035'));
      expect(mapa['clube_sigla'], equals('FO'));
      expect(mapa['sexo'], equals('M'));
    });

    test('Deve converter Ciclo para Map corretamente', () {
      final dataInicio = DateTime(2026, 10, 1);

      final ciclo = Ciclo(
        sistema: 'Monogamia',
        manejoMacho: 'Sempre Junto',
        dataInicio: dataInicio,
      );

      final mapa = ciclo.toMap();

      expect(mapa['sistema'], equals('Monogamia'));
      expect(mapa['manejo_macho'], equals('Sempre Junto'));
      expect(
        mapa['data_inicio'],
        equals(dataInicio.toIso8601String()),
      );
    });
  });
}
