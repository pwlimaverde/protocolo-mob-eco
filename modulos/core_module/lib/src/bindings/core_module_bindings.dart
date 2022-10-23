import 'package:dependencies_module/dependencies_module.dart';

class CoreModuleBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<CoreModuleController>(
      CoreModuleController(),
      permanent: true,
    );
    Get.put<DesignSystemController>(
      DesignSystemController(),
      permanent: true,
    );
    Get.put<RemessasController>(
      RemessasController(
        carregarRemessasFirebaseUsecase: CarregarRemessasFirebaseUsecase(
          datasource: CarregarRemessasFirebaseDatasource(),
        ),
        carregarBoletosFirebaseUsecase: CarregarBoletosFirebaseUsecase(
          datasource: CarregarBoletosFirebaseDatasource(),
        ),
        mapeamentoNomesArquivoHtmlUsecase: MapeamentoNomesArquivoHtmlUsecase(
          datasource: MapeamentoNomesArquivoHtmlDatasource(),
        ),
        uploadArquivoHtmlPresenter: UploadArquivoHtmlPresenter(),
        uploadAnaliseArquivosFirebaseUsecase:
            UploadAnaliseArquivosFirebaseUsecase(
          datasource: UploadAnaliseArquivosFirebaseDatasource(),
        ),
        limparAnaliseArquivosFirebaseUsecase:
            LimparAnaliseArquivosFirebaseUsecase(
          datasource: LimparAnaliseArquivosFirebaseDatasource(),
        ),
      ),
      permanent: true,
    );
  }
}
