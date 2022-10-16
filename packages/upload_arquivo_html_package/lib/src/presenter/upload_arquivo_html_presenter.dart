import 'package:dependencies_module/dependencies_module.dart';
import '../features/arquivos_html/carregar_arquivo_html/datasources/upload_arquivo_html_datasource.dart';
import '../features/arquivos_html/carregar_arquivo_html/domain/usecase/carregar_arquivo_html_usecase.dart';
import '../features/arquivos_html/leitura_arquivo_html/datasources/leitura_arquivo_html_datasource.dart';
import '../features/arquivos_html/leitura_arquivo_html/domain/usecase/leitura_arquivo_html_usecase.dart';
import '../utils/parametros/parametos.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class UploadArquivoHtmlPresenter
    implements Presenter<List<Map<String, Uint8List>>> {
  @override
  Future<ReturnSuccessOrError<List<Map<String, Uint8List>>>> call(
      {required ParametersReturnResult parameters}) async {
    final remessa = _leituraArquivo(
      listaArquivosHtml: await _carregarArquivo(
        parameters: parameters,
      ),
      parameters: parameters,
    );

    return remessa;
  }

  Future<List<html.File>> _carregarArquivo({
    required ParametersReturnResult parameters,
  }) async {
    final stringList = await CarregarArquivoHtmlUsecase(
      datasource: UploadArquivoHtmlDatasource(),
    )(
      parameters: parameters,
    );

    if (stringList.status == StatusResult.success) {
      return stringList.result;
    } else {
      throw Exception("Erro ao carregar arquivo");
    }
  }

  Future<ReturnSuccessOrError<List<Map<String, Uint8List>>>> _leituraArquivo({
    required List<html.File> listaArquivosHtml,
    required ParametersReturnResult parameters,
  }) async {
    final leitura = await LeituraArquivoHtmlUsecase(
      datasource: LeituraArquivoHtmlDatasource(),
    )(
        parameters: ParametrosLeituraArquivoHtml(
      listaArquivosHtml: listaArquivosHtml,
      nameFeature: parameters.nameFeature,
      showRuntimeMilliseconds: parameters.showRuntimeMilliseconds,
      error: parameters.error,
    ));
    return leitura;
  }
}
