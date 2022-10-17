import 'package:dependencies_module/dependencies_module.dart';

class MapeamentoNomesArquivoHtmlUsecase extends UseCaseImplement<List<int>> {
  final Datasource<List<int>> datasource;

  MapeamentoNomesArquivoHtmlUsecase({
    required this.datasource,
  });

  @override
  Future<ReturnSuccessOrError<List<int>>> call({
    required ParametersReturnResult parameters,
  }) {
    final result = returnUseCase(
      parameters: parameters,
      datasource: datasource,
    );
    return result;
  }
}
