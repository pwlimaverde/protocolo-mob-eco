import 'package:dependencies_module/dependencies_module.dart';

class ParametrosUploadRemessa implements ParametersReturnResult {
  final List<RemessaModel> listaRemessaCarregados;
  @override
  final AppError error;
  @override
  final bool showRuntimeMilliseconds;
  @override
  final String nameFeature;

  ParametrosUploadRemessa({
    required this.listaRemessaCarregados,
    required this.error,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });
}

class ParametrosUploadAnaliseArquivos implements ParametersReturnResult {
  final RemessaModel remessa;
  final Map<String, List<int>> mapAliseArquivos;
  @override
  final AppError error;
  @override
  final bool showRuntimeMilliseconds;
  @override
  final String nameFeature;

  ParametrosUploadAnaliseArquivos({
    required this.remessa,
    required this.mapAliseArquivos,
    required this.error,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });
}

class ParametrosCarregarBoletos implements ParametersReturnResult {
  final RemessaModel remessaCarregada;
  @override
  final AppError error;
  @override
  final bool showRuntimeMilliseconds;
  @override
  final String nameFeature;

  ParametrosCarregarBoletos({
    required this.remessaCarregada,
    required this.error,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });
}

class ParametrosMapeamentoArquivoHtml implements ParametersReturnResult {
  final List<Map<String, Uint8List>> listaMapBytes;
  @override
  final AppError error;
  @override
  final bool showRuntimeMilliseconds;
  @override
  final String nameFeature;

  ParametrosMapeamentoArquivoHtml({
    required this.listaMapBytes,
    required this.error,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });
}

class ParametrosProcessamentoArquivoHtml implements ParametersReturnResult {
  final List<Map<String, List<int>>> listaMapBruta;
  @override
  final AppError error;
  @override
  final bool showRuntimeMilliseconds;
  @override
  final String nameFeature;

  ParametrosProcessamentoArquivoHtml({
    required this.listaMapBruta,
    required this.error,
    required this.showRuntimeMilliseconds,
    required this.nameFeature,
  });
}
