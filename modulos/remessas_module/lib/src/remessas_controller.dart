import 'dart:convert';
import 'dart:html' as html;

import 'package:dependencies_module/dependencies_module.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart' as pwprint;
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
    loadingPosicaoRemessa(0);
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
                    "ID Remessa": remessa.id,
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
        // _enviarNovaAnalise(
        //   analise: result,
        //   model: remessa,
        // );
        _processamentoPdf(arquivosPdfOk: arquivosOk);
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

  final loadingPosicaoRemessa = 0.0.obs;

  Future<void> _processamentoPdf({
    required List<Map<String, dynamic>> arquivosPdfOk,
  }) async {
    final Iterable<Future<Map<String, dynamic>>> salvarPdfFuturo =
        arquivosPdfOk.map(_salvarPdf);

    final Future<Iterable<Map<String, dynamic>>> waitedRemessas =
        Future.wait(salvarPdfFuturo);

    await waitedRemessas;

    // int inicio = 0;
    // int fim = 3;

    // if (inicio < arquivosPdf.length) {
    //   for (int grupo = inicio; grupo < inicio + 1; grupo++) {
    //     List<Uint8List> filesIndx = _divisaoFiles(
    //       indiceFinal: inicio + fim,
    //       indiceInicial: inicio,
    //       pdfs: arquivosPdf,
    //     );
    //     final PdfDocument document = PdfDocument();
    //     document.pageSettings.margins = PdfMargins()..all = 5;

    //     for (Uint8List pdf in filesIndx) {
    //       print(filesIndx.length);
    //       final indexPdf = arquivosPdf.indexOf(pdf);
    //       loadingPosicaoRemessa(((indexPdf * 100) / arquivosPdf.length) / 100);
    //       print(loadingPosicaoRemessa);

    //       final PdfDocument documentAdd = PdfDocument(inputBytes: pdf);

    //       for (var pageAdd = 0; pageAdd < documentAdd.pages.count; pageAdd++) {
    //         final PdfPage page = document.pages.add();
    //         final template = documentAdd.pages[pageAdd].createTemplate();
    //         documentAdd.pageSettings.margins = PdfMargins()..all = 5;
    //         page.graphics.drawPdfTemplate(template, const Offset(0, 5));
    //       }
    //       documentAdd.dispose();
    //     }

    //   }
    // }

    // List<dynamic> images = [];

    // for (Uint8List arquivo in arquivosPdf) {
    //   await for (var page in pwprint.Printing.raster(arquivo)) {
    //     final image = page.asImage(); // ...or page.toPng()
    //     images.add(image);
    //   }
    // }

    // print(images.length);

    // final PdfDocument document = PdfDocument();
    // document.pageSettings.margins = PdfMargins()..all = 5;

    // for (Uint8List arquivo in arquivosPdf) {
    //   final PdfPage page = document.pages.add();
    //   PdfBitmap image = PdfBitmap(arquivo);
    //   page.graphics.drawImage(
    //       image,
    //       Rect.fromLTWH(
    //           0, 0, page.getClientSize().width, page.getClientSize().height));
    // }

    // for (Uint8List pdf in arquivosPdf) {
    //   // final indexPdf = arquivosPdf.indexOf(pdf);

    //   // loadingPosicaoRemessa(((indexPdf * 100) / arquivosPdf.length) / 100);
    //   // print(loadingPosicaoRemessa);

    //   final PdfDocument documentAdd = PdfDocument(inputBytes: pdf);

    //   for (var pageAdd = 0; pageAdd < documentAdd.pages.count; pageAdd++) {
    //     // final PdfBitmap image = PdfBitmap(images[0]);

    //     final PdfPage page = document.pages.add();

    //     final template = documentAdd.pages[pageAdd].createTemplate();
    //     documentAdd.pageSettings.margins = PdfMargins()..all = 5;
    //     page.graphics.drawPdfTemplate(template, const Offset(0, 5));

    //     // page.graphics.drawImage(image, const Rect.fromLTWH(0, 0, 500, 200));
    //   }
    //   documentAdd.dispose();
    // }
    // final List<int> bytes = document.saveSync();
    // await saveAndLaunchFile(bytes, '$nomeDaRemessa - IMP EM LOTE.pdf');
    // document.dispose();
  }

  Future<Map<String, dynamic>> _salvarPdf(
    Map<String, dynamic> mapArquivoPdf,
  ) async {
    final PdfDocument document =
        PdfDocument(inputBytes: mapArquivoPdf["Arquivo"]);
    document.pageSettings.margins = PdfMargins()..all = 5;
    final List<int> bytes = document.saveSync();
    await saveAndLaunchFile(bytes,
        '${mapArquivoPdf["Index"]} - ${mapArquivoPdf["ID Cliente"]} - ${mapArquivoPdf["ID Remessa"]}.pdf');
    document.dispose();
    return mapArquivoPdf;
  }

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    html.AnchorElement(
        href:
            'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
      ..setAttribute('download', fileName)
      ..click();
  }

  List<Uint8List> _divisaoFiles({
    required List<Uint8List> pdfs,
    required int indiceInicial,
    required int indiceFinal,
  }) {
    List<Uint8List> filesIndx = [];
    for (int pdf = indiceInicial; pdf <= indiceFinal; pdf++) {
      filesIndx.add(pdfs[pdf]);
    }
    return filesIndx;
  }

  Future<bool> _enviarNovaAnalise(
      {required RemessaModel model,
      required Map<String, List<int>> analise}) async {
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
