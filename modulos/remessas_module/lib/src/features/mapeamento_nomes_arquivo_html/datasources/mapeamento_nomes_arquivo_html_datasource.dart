import 'package:dependencies_module/dependencies_module.dart';
import '../../../utils/parametros/parametros_remessas_module.dart';

class MapeamentoNomesArquivoHtmlDatasource
    implements Datasource<List<Map<int, Uint8List>>> {
  @override
  Future<List<Map<int, Uint8List>>> call(
      {required ParametersReturnResult parameters}) async {
    if (parameters is ParametrosMapeamentoArquivoHtml) {
      List<Map<String, Uint8List>> mapBytes = parameters.listaMapBytes;

      if (mapBytes.isNotEmpty) {
        List<Map<int, Uint8List>> listaArquivos = [];
        for (Map<String, Uint8List> map in mapBytes) {
          listaArquivos.add(_listaProcessada(map: map));
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

  Map<int, Uint8List> _listaProcessada({
    required Map<String, Uint8List> map,
  }) {
    if (map.keys.first.contains(".pdf")) {
      return _processamentoPdf(
        map: map,
      );
    } else {
      return <int, Uint8List>{};
    }
  }

//   List<int> _processamentoCsv({
//     required Map<String, Uint8List> map,
//   }) {
//     try {
//       final decoderByte = convert.latin1.decode(map.values.first);
//       List<List<dynamic>> listCsv = [];
//       List<int> idsArquivosList = [];

//       listCsv.addAll(
//           const CsvToListConverter(fieldDelimiter: ";").convert(decoderByte));

//       if (listCsv.isNotEmpty) {
//         for (List<dynamic> nome in listCsv) {
//           final idArquivo = int.tryParse(
//               nome[0].toString().split("_").length > 1
//                   ? nome[0].toString().split("_")[1]
//                   : "");
//           final nomeDuplicado =
//               idsArquivosList.where((element) => element == idArquivo).length ==
//                   1;
//           if (idArquivo != null && !nomeDuplicado) {
//             idsArquivosList.add(idArquivo);
//           }
//         }
//       }
//       return idsArquivosList;
//     } catch (e) {
//       final listCatch = <int>[];
//       return listCatch;
//     }
//   }
// }

  Map<int, Uint8List> _processamentoPdf({required Map<String, Uint8List> map}) {
    Map<int, Uint8List> arquivoProcessado = {};
    final nomeArquivo = map.keys.first;
    final arquivo = map.values.first;
    final idArquivo = int.tryParse(nomeArquivo.toString().split("_").length > 1
        ? nomeArquivo.toString().split("_")[1]
        : "");
    if (idArquivo != null) {
      arquivoProcessado.addAll({idArquivo: arquivo});
      return arquivoProcessado;
    } else {
      return <int, Uint8List>{};
    }
  }
}
