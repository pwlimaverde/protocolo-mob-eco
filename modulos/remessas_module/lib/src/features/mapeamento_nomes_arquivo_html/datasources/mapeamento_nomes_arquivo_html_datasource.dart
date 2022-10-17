import 'package:dependencies_module/dependencies_module.dart';
import 'dart:convert' as convert;
import '../../../utils/parametros/parametros_remessas_module.dart';

class MapeamentoNomesArquivoHtmlDatasource implements Datasource<List<int>> {
  @override
  Future<List<int>> call({required ParametersReturnResult parameters}) async {
    if (parameters is ParametrosMapeamentoArquivoHtml) {
      List<Map<String, Uint8List>> mapBytes = parameters.listaMapBytes;

      if (mapBytes.isNotEmpty) {
        List<int> listaArquivos = [];
        for (Map<String, Uint8List> map in mapBytes) {
          listaArquivos.addAll(_listaProcessada(map: map));
        }
        return listaArquivos;
      } else {
        throw Exception(
            "Erro ao mapear as informaões do arquivo - ${parameters.error}");
      }
    } else {
      throw Exception(
          "Erro ao mapear as informaões do arquivo - - ${parameters.error}");
    }
  }

  List<int> _listaProcessada({
    required Map<String, Uint8List> map,
  }) {
    if (map.keys.first.contains(".csv")) {
      return _processamentoCsv(
        map: map,
      );
    } else {
      throw Exception("Arquivo carregado precisa ter extenção xlsx ou csv");
    }
  }

  List<int> _processamentoCsv({
    required Map<String, Uint8List> map,
  }) {
    try {
      final decoderByte = convert.latin1.decode(map.values.first);
      List<List<dynamic>> listCsv = [];
      List<int> idsArquivosList = [];

      listCsv.addAll(
          const CsvToListConverter(fieldDelimiter: ";").convert(decoderByte));

      if (listCsv.isNotEmpty) {
        for (List<dynamic> nome in listCsv) {
          final idArquivo = int.tryParse(
              nome[0].toString().split("_").length > 1
                  ? nome[0].toString().split("_")[1]
                  : "");
          final nomeDuplicado =
              idsArquivosList.where((element) => element == idArquivo).length ==
                  1;
          if (idArquivo != null && !nomeDuplicado) {
            idsArquivosList.add(idArquivo);
          }
        }
      }
      return idsArquivosList;
    } catch (e) {
      final listCatch = <int>[];
      return listCatch;
    }
  }
}
