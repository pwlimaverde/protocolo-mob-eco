import 'package:dependencies_module/dependencies_module.dart';
import 'package:flutter/material.dart';
import 'package:remessas_module/src/utils/errors/erros_remessas.dart';

import 'features/carregar_boletos_firebase/domain/usecase/carregar_boletos_firebase_usecase.dart';
import 'utils/parametros/parametros_remessas_module.dart';

class RemessasController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final CarregarRemessasFirebaseUsecase carregarRemessasFirebaseUsecase;
  final CarregarBoletosFirebaseUsecase carregarBoletosFirebaseUsecase;
  RemessasController({
    required this.carregarRemessasFirebaseUsecase,
    required this.carregarBoletosFirebaseUsecase,
  });

  final List<Tab> myTabs = <Tab>[
    const Tab(text: "Todas Remessas"),
  ];

  final List<Tab> myTabsSmall = <Tab>[
    const Tab(text: "Remessas"),
  ];

  late TabController _tabController;

  TabController get tabController => _tabController;

  @override
  void onInit() async {
    super.onInit();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void onReady() {
    super.onReady();
    carregarRemessas();
  }

  @override
  InternalFinalCallback<void> get onDelete {
    _clearLists();
    return super.onDelete;
  }

  final _listTadasRemessas = <RemessaModel>[].obs;

  List<RemessaModel> get listTadasRemessas => _listTadasRemessas
    ..sort(
      (a, b) => b.data.compareTo(a.data),
    );

  void _clearLists() {
    listTadasRemessas.clear();
  }

  Future<void> carregarRemessas() async {
    _clearLists();
    // final processamento = await _processamentoDados(
    //   listaMapBruta: await _mapeamentoDadosArquivo(
    //     listaMapBytes: await _carregarArquivos(),
    //   ),
    // );
    final uploadFirebase = await carregarRemessasFirebaseUsecase(
      parameters: NoParams(
        error: ErroUploadArquivo(message: "Error ao carregar as remessas"),
        showRuntimeMilliseconds: true,
        nameFeature: "Carregar Remessas",
      ),
    );

    if (uploadFirebase.status == StatusResult.success) {
      _listTadasRemessas.bindStream(uploadFirebase.result);
    }
  }

  Future<List<BoletoModel>> carregarBoletos(
      {required RemessaModel remessa}) async {
    final carregarBoletos = await carregarBoletosFirebaseUsecase(
      parameters: ParametrosCarregarBoletos(
        error: ErroUploadArquivo(message: "Error ao carregar os boletos"),
        showRuntimeMilliseconds: true,
        nameFeature: "Carregar Boletos",
        remessaCarregada: remessa,
      ),
    );

    if (carregarBoletos.status == StatusResult.success) {
      final List<BoletoModel> boletos = carregarBoletos.result;
      boletos.sort(
        (a, b) => a.cliente.compareTo(b.cliente),
      );

      return boletos;
    } else {
      throw Exception(
          "Erro ao carregar os dados dos boletos do banco de dados");
    }
  }

  // Future<List<Map<String, Uint8List>>> _carregarArquivos() async {
  //   final arquivos = await uploadArquivoHtmlPresenter(
  //     parameters: NoParams(
  //       error: ErroUploadArquivo(
  //         message: "Erro ao fazer o upload do arquivo.",
  //       ),
  //       showRuntimeMilliseconds: true,
  //       nameFeature: "Carregamento de Arquivo",
  //     ),
  //   );
  //   if (arquivos.status == StatusResult.success) {
  //     return arquivos.result;
  //   } else {
  //     designSystemController.message(
  //       MessageModel.error(
  //         title: 'Carregamento de arquivos',
  //         message: 'Erro ao carregar os arquivos - ${arquivos.result}',
  //       ),
  //     );
  //     throw Exception("Erro ao carregar os arquivos - ${arquivos.result}");
  //   }
  // }

  // Future<List<Map<String, Map<String, dynamic>>>> _mapeamentoDadosArquivo(
  //     {required List<Map<String, Uint8List>> listaMapBytes}) async {
  //   final mapeamento = await mapeamentoDadosArquivoHtmlUsecase(
  //     parameters: ParametrosMapeamentoArquivoHtml(
  //       error: ErroUploadArquivo(
  //         message: "Erro ao fazer o mapeamento do arquivo.",
  //       ),
  //       nameFeature: 'Mapeamento Arquivo',
  //       showRuntimeMilliseconds: true,
  //       listaMapBytes: listaMapBytes,
  //     ),
  //   );
  //   if (mapeamento.status == StatusResult.success) {
  //     return mapeamento.result;
  //   } else {
  //     designSystemController.message(
  //       MessageModel.error(
  //         title: 'Mapeamento de arquivos',
  //         message: 'Erro ao mapear os arquivos - ${mapeamento.result}',
  //       ),
  //     );
  //     throw Exception("Erro ao mapear os arquivos - ${mapeamento.result}");
  //   }
  // }

  // Future<List<RemessaModel>> _processamentoDados({
  //   required List<Map<String, Map<String, dynamic>>> listaMapBruta,
  // }) async {
  //   final remessasProcessadas = await processamentoDadosArquivoHtmlUsecase(
  //     parameters: ParametrosProcessamentoArquivoHtml(
  //       error: ErroUploadArquivo(
  //         message: "Erro ao processar Arquivo",
  //       ),
  //       nameFeature: 'Processamento Arquivo',
  //       listaMapBruta: listaMapBruta,
  //       showRuntimeMilliseconds: true,
  //     ),
  //   );

  //   if (remessasProcessadas.status == StatusResult.success) {
  //     final listRemessa = remessasProcessadas.result["remessasProcessadas"];
  //     final listRemessaError =
  //         remessasProcessadas.result["remessasProcessadasError"];
  //     designSystemController.message(
  //       MessageModel.info(
  //         title: "Processamento de OPS",
  //         message:
  //             "${listRemessa.length} Processadas com Sucesso! \n ${listRemessaError.length} Processadas com Erro!",
  //       ),
  //     );
  //     if (listRemessaError.isNotEmpty) {
  //       uploadRemessaListError(listRemessaError);
  //     }
  //     if (listRemessa.isNotEmpty) {
  //       return listRemessa;
  //     } else {
  //       designSystemController.message(
  //         MessageModel.error(
  //           title: 'Processamento de OPS',
  //           message: 'Erro! nenhuma OP a ser processada!',
  //         ),
  //       );
  //       return <RemessaModel>[];
  //     }
  //   } else {
  //     designSystemController.message(
  //       MessageModel.error(
  //         title: 'Processamento de OPS',
  //         message: 'Erro ao processar as OPS!',
  //       ),
  //     );
  //     return <RemessaModel>[];
  //   }
  // }

  // Future<Map<String, List<OpsModel>>?> _triagemOps({
  //   required List<OpsModel>? listaOps,
  // }) async {
  //   final uploadOps = listaOps != null
  //       ? await uploadOpsUsecase(
  //           parameters: ParametrosUploadOps(
  //             error: ErroUploadOps(message: "Erro ao fazer o upload das Ops!"),
  //             listaOpsCarregadas: listaOps,
  //             nameFeature: 'Uploadv Ops',
  //             showRuntimeMilliseconds: false,
  //           ),
  //         )
  //       : null;

  //   if (uploadOps is SuccessReturn<Map<String, List<OpsModel>>>) {
  //     return uploadOps.result;
  //   } else {
  //     designSystemController.message(
  //       MessageModel.error(
  //         title: 'Triagem OPS',
  //         message: 'Erro ao fazer a triagem das OPS!',
  //       ),
  //     );
  //     return null;
  //   }
  // }

  // Future<void> _uploadOps({
  //   required Map<String, List<OpsModel>>? triagemOps,
  // }) async {
  //   if (triagemOps != null) {
  //     final listOpsNovas = triagemOps["listOpsNovas"] ?? [];
  //     final listOpsUpdate = triagemOps["listOpsUpdate"] ?? [];
  //     final listOpsDuplicadas = triagemOps["listOpsDuplicadas"] ?? [];
  //     if (listOpsNovas.isNotEmpty) {
  //       final Iterable<Future<OpsModel>> enviarOpsFuturo =
  //           listOpsNovas.map(_enviarNovaOp);

  //       final Future<Iterable<OpsModel>> waited = Future.wait(enviarOpsFuturo);

  //       await waited;
  //       designSystemController.message(
  //         MessageModel.info(
  //           title: "Upload de OPS",
  //           message: "Upload de ${listOpsNovas.length} Ops com Sucesso!",
  //         ),
  //       );
  //       uploadCsvOpsList(listOpsNovas);
  //     }
  //     if (listOpsUpdate.isNotEmpty) {
  //       final Iterable<Future<OpsModel>> enviarOpsFuturo =
  //           listOpsUpdate.map(_enviarUpdateOp);

  //       final Future<Iterable<OpsModel>> waited = Future.wait(enviarOpsFuturo);

  //       await waited;
  //       designSystemController.message(
  //         MessageModel.info(
  //           title: "Upload de OPS",
  //           message: "Update de ${listOpsUpdate.length} Ops com Sucesso!",
  //         ),
  //       );
  //       updateCsvOpsList(listOpsUpdate);
  //     }
  //     if (listOpsDuplicadas.isNotEmpty) {
  //       designSystemController.message(
  //         MessageModel.info(
  //           title: "Upload de OPS",
  //           message: "${listOpsDuplicadas.length} Ops duplicadas!",
  //         ),
  //       );
  //       duplicadasCsvOpsList(listOpsDuplicadas);
  //     }
  //     _tabController.index = listOpsNovas.isNotEmpty
  //         ? 0
  //         : listOpsUpdate.isNotEmpty
  //             ? 1
  //             : 2;
  //   }
  // }
}
