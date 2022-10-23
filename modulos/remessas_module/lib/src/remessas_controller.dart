import 'dart:convert';
import 'dart:html' as html;

import 'package:archive/archive.dart';
import 'package:dependencies_module/dependencies_module.dart';
import 'package:flutter/material.dart';
import 'package:remessas_module/src/utils/errors/erros_remessas.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'utils/parametros/parametros_remessas_module.dart';

class RemessasController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final UploadArquivoHtmlPresenter uploadArquivoHtmlPresenter;
  final CarregarRemessasFirebaseUsecase carregarRemessasFirebaseUsecase;
  final CarregarBoletosFirebaseUsecase carregarBoletosFirebaseUsecase;
  final MapeamentoNomesArquivoHtmlUsecase mapeamentoNomesArquivoHtmlUsecase;
  final UploadAnaliseArquivosFirebaseUsecase
      uploadAnaliseArquivosFirebaseUsecase;
  RemessasController({
    required this.uploadArquivoHtmlPresenter,
    required this.carregarRemessasFirebaseUsecase,
    required this.carregarBoletosFirebaseUsecase,
    required this.mapeamentoNomesArquivoHtmlUsecase,
    required this.uploadAnaliseArquivosFirebaseUsecase,
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

  Future<void> setUploadNomesArquivos({required RemessaModel remessa}) async {
    designSystemController.statusLoad(true);
    await _uploadNomesArquivos(
      arquivosDaRemessa: await _mapeamentoDadosArquivo(
        listaMapBytes: await _carregarArquivos(),
      ),
      remessa: remessa,
    );
    designSystemController.statusLoad(false);
  }

  Future<void> _uploadNomesArquivos({
    required List<Map<int, Uint8List>> arquivosDaRemessa,
    required RemessaModel remessa,
  }) async {
    try {
      if (arquivosDaRemessa.isNotEmpty) {
        List<BoletoModel> boletosOrdenados =
            await carregarBoletos(remessa: remessa);
        List<dynamic> idsArquivosRemessa = [];
        List<Uint8List> arquivos = [];
        List<Map<String, dynamic>> arquivosOk = [];
        int indexArquivoOk = 0;
        List<int> idsOk = [];
        List<int> idsError = [];
        List<dynamic> idsCliente = remessa.idsClientes;
        List<int> arquivosInvalidos = [];

        final testeOK = remessa.protocolosOk;
        if (testeOK != null) {
          for (dynamic element in testeOK) {
            idsOk.add(element);
          }
        }

        for (Map<int, Uint8List> element in arquivosDaRemessa) {
          idsArquivosRemessa.add(element.keys.first);
        }

        for (BoletoModel boleto in boletosOrdenados) {
          final idCompare = int.tryParse(boleto.idCliente.toString());
          final compare = arquivosDaRemessa
              .where((element) => element.keys.first == idCompare)
              .map((arquivo) => arquivo.values.first)
              .toList();
          arquivos.addAll(compare);
          if (idCompare != null) {
            if (compare.isNotEmpty) {
              final compareOk =
                  idsOk.where((element) => element == idCompare).length == 1;
              if (!compareOk) {
                idsOk.add(idCompare);
                for (Uint8List pdf in compare) {
                  arquivosOk.add({
                    "ID Cliente": idCompare,
                    "Cliente": boleto.cliente,
                    "Arquivo": pdf,
                    "Index": indexArquivoOk,
                  });
                  indexArquivoOk++;
                }
              }
            } else {
              final compareError =
                  idsOk.where((element) => element == idCompare).length == 1;
              if (!compareError) {
                idsError.add(idCompare);
              }
            }
          }
        }

        for (int arquivo in idsArquivosRemessa) {
          final compare =
              idsCliente.where((element) => element == arquivo).length == 1;
          if (!compare) {
            arquivosInvalidos.add(arquivo);
          }
        }

        idsOk.sort(
          (a, b) => a.compareTo(b),
        );

        final Map<String, List<int>> result = {
          "Protocolos ok": idsOk,
          "Protocolos sem boletos": idsError,
          "Arquivos invalidos": arquivosInvalidos
        };
        _enviarNovaAnalise(
          analise: result,
          model: remessa,
        );

        _processamentoPdf(
            arquivosPdfOk: arquivosOk, nomeRemessa: remessa.nomeArquivo);
      }
    } catch (e) {
      designSystemController.message(
        MessageModel.error(
          title: 'Upload de Remessa',
          message: 'Erro ao fazer o Upload da Remessa!',
        ),
      );
      throw Exception("Erro ao fazer o Upload da Remessa!");
    }
  }

  Future<void> _processamentoPdf({
    required List<Map<String, dynamic>> arquivosPdfOk,
    required String nomeRemessa,
  }) async {
    final Iterable<Future<Map<String, Uint8List>>> salvarPdfFuturo =
        arquivosPdfOk.map(_salvarPdf);

    final Future<Iterable<Map<String, Uint8List>>> waitedRemessas =
        Future.wait(salvarPdfFuturo);

    final teste = await waitedRemessas.then((value) => value.toList());

    _downloadFilesAsZIP(files: teste, nomeRemessa: nomeRemessa);
  }

  Future<Map<String, Uint8List>> _salvarPdf(
    Map<String, dynamic> mapArquivoPdf,
  ) async {
    final PdfDocument document =
        PdfDocument(inputBytes: mapArquivoPdf["Arquivo"]);
    document.pageSettings.margins = PdfMargins()..all = 5;
    final List<int> bytes = document.saveSync();
    Map<String, Uint8List> map = {
      '${mapArquivoPdf["Index"] + 1} - ${mapArquivoPdf["ID Cliente"]} - ${mapArquivoPdf["Cliente"]}.pdf':
          Uint8List.fromList(bytes)
    };
    return map;
  }

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    html.AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', fileName)
      ..click();
  }

  _downloadFilesAsZIP(
      {required List<Map<String, Uint8List>> files,
      required String nomeRemessa}) {
    var encoder = ZipEncoder();
    var archive = Archive();

    for (Map<String, Uint8List> file in files) {
      ArchiveFile archiveFiles = ArchiveFile.noCompress(
          file.keys.first, file.values.first.lengthInBytes, file.values.first);
      archive.addFile(archiveFiles);
    }

    final outputStream = OutputStream(
      byteOrder: LITTLE_ENDIAN,
    );
    final bytes = encoder.encode(archive,
        level: Deflate.BEST_COMPRESSION, output: outputStream);

    saveAndLaunchFile(bytes!, "Remessa ordenada - $nomeRemessa.zip");
  }

  Future<bool> _enviarNovaAnalise({
    required RemessaModel model,
    required Map<String, List<int>> analise,
  }) async {
    final uploadFirebase = await uploadAnaliseArquivosFirebaseUsecase(
      parameters: ParametrosUploadAnaliseArquivos(
        error: ErroUploadArquivo(
            message:
                "Erro ao fazer o upload da Remessa para o banco de dados!"),
        showRuntimeMilliseconds: true,
        nameFeature: "upload firebase",
        mapAliseArquivos: analise,
        remessa: model,
      ),
    );

    if (uploadFirebase.status == StatusResult.success) {
      return true;
    } else {
      designSystemController.message(
        MessageModel.error(
          title: 'Upload de Analise Firebase',
          message: 'Erro enviar o Analise para o banco de dados!',
        ),
      );
      throw Exception("Erro enviar a Analise para o banco de dados!");
    }
  }

  Future<List<Map<int, Uint8List>>> _mapeamentoDadosArquivo(
      {required List<Map<String, Uint8List>> listaMapBytes}) async {
    final mapeamento = await mapeamentoNomesArquivoHtmlUsecase(
      parameters: ParametrosMapeamentoArquivoHtml(
        error: ErroUploadArquivo(
          message: "Erro ao mapear os arquivos.",
        ),
        nameFeature: 'Mapeamento Arquivo',
        showRuntimeMilliseconds: true,
        listaMapBytes: listaMapBytes,
      ),
    );
    if (mapeamento.status == StatusResult.success) {
      return mapeamento.result;
    } else {
      designSystemController.message(
        MessageModel.error(
          title: 'Mapeamento de arquivos',
          message: 'Erro ao mapear os arquivos.',
        ),
      );
      throw Exception("Erro ao mapear os arquivos.");
    }
  }

  Future<List<Map<String, Uint8List>>> _carregarArquivos() async {
    final arquivos = await uploadArquivoHtmlPresenter(
      parameters: NoParams(
        error: ErroUploadArquivo(
          message: "Erro ao Erro ao carregar os arquivos.",
        ),
        showRuntimeMilliseconds: true,
        nameFeature: "Carregamento de Arquivo",
      ),
    );
    if (arquivos.status == StatusResult.success) {
      return arquivos.result;
    } else {
      designSystemController.message(
        MessageModel.error(
          title: 'Carregamento de arquivos',
          message: 'Erro ao carregar os arquivos',
        ),
      );
      throw Exception("Erro ao carregar os arquivos");
    }
  }

  Future<void> carregarRemessas() async {
    _clearLists();
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
}
