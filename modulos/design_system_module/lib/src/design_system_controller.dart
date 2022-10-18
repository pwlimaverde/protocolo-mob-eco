import 'package:dependencies_module/dependencies_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'mixins/ui/loader/loader_mixin.dart';
import 'mixins/ui/messages/messages_mixin.dart';
import 'widgets/botoes/botao_upload/botao_upload_widget.dart';
import 'widgets/header/header_widget.dart';
import 'widgets/menu/menu_widget.dart';
import 'widgets/right/right_widget.dart';

class DesignSystemController extends GetxController
    with LoaderMixin, MessagesMixin {
  @override
  void onInit() {
    super.onInit();
    loaderListener(
      statusLoad: statusLoad,
    );
    messageListener(
      message: message,
    );
    _carregarImagemModelo();
    _carregarSufixo();
  }

  //Controller de Loading
  final statusLoad = false.obs;

  //Controller de Messages
  final message = Rxn<MessageModel>();

  //Cache de Imadem da base do protocolo
  final _imagemModelo = Rxn<Uint8List>();

  //Configuração Sufixo
  final _sufixo = Rxn<String>();

  bool get isSufixo {
    return _sufixo.value != null && _sufixo.value != "" ? true : false;
  }

  Future<void> _carregarImagemModelo() async {
    final gsReference = FirebaseStorage.instance.refFromURL(
        "gs://protocolo-mob-eco-release.appspot.com/modelo/BASE-PROTOCOLO-MOB.jpeg");
    _imagemModelo(await gsReference.getData());
  }

  Future<void> _carregarSufixo() async {
    final reference = await FirebaseFirestore.instance
        .collection("configuracao")
        .doc("protocolo")
        .get();
    final sufixo = reference.data();
    if (sufixo != null) {
      _sufixo(sufixo["sufixo"].toString());
    }
  }

  //Widgets Pages
  Scaffold scaffold({
    required Widget body,
    required int page,
    required BuildContext context,
  }) {
    coreModuleController.getQuery(context: context);

    return Scaffold(
      drawer: coreModuleController.showMenu
          ? Drawer(
              child: MenuWidget(
                page: page,
              ),
            )
          : null,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(hederHeight),
        child: HeaderWidget(
          titulo: "Sistema Protocolos MOB - ECO",
          subtitulo: versaoAtual,
          actions: coreModuleController.pageAtual.value == 2
              ? <Widget>[
                  // _iconButtonSearch(),
                  // _iconButtonPrint(),
                ]
              : coreModuleController.pageAtual.value == 1
                  ? <Widget>[
                      _iconButtonUpload(),
                    ]
                  : [],
        ),
      ),
      backgroundColor: Get.theme.primaryColor,
      body: Column(
        children: <Widget>[
          Obx(() {
            return _body(
              body: body,
              page: page,
            );
          }),
        ],
      ),
    );
  }

  // Widget _iconButtonSearch() {
  //   return Obx(
  //     () {
  //       return opsController.buscando.value
  //           ? BotaoForm(
  //               form: FormGeral(
  //                 controllerText: opsController.crtlBusca,
  //                 hintText: "Digite a busca",
  //                 labelText: "Busca",
  //                 onChanged: (String value) {
  //                   opsController.busca(value);
  //                 },
  //               ),
  //               button: BotaoLimpar(
  //                 size: 20,
  //                 onPressed: _setLimpar,
  //               ),
  //             )
  //           : BotaoSearch(
  //               size: 20,
  //               onPressed: _setBuscando,
  //             );
  //     },
  //   );
  // }

  // void _setBuscando() {
  //   opsController.buscando(!opsController.buscando.value);
  // }

  // void _setLimpar() {
  //   opsController.crtlBusca.clear();
  //   opsController.busca.value = null;
  //   _setBuscando();
  // }
  Widget iconUploadNomesArquivos({required RemessaModel filtro}) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      icon: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              size: 20,
              filtro.isOk ? Icons.check : Icons.analytics,
              color: filtro.isOk ? Colors.green : Colors.grey,
            ),
            const Text(
              "Analise",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      onPressed: (() => _setUploadNomesArquivos(remessa: filtro)),
    );
  }

  Widget iconDownloadAnalitic({required RemessaModel filtro}) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      icon: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              size: 20,
              filtro.isOk
                  ? Icons.check
                  : filtro.protocolosSemBoletos == null
                      ? Icons.error_outline_outlined
                      : Icons.error,
              color: filtro.isOk
                  ? Colors.green
                  : filtro.protocolosSemBoletos == null
                      ? Colors.grey
                      : Colors.red,
            ),
            const Text(
              "Relatorio",
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
      onPressed: (() {
        _downloadAnalise(filtro: filtro);
      }),
    );
  }

  Widget iconDownloadXlsx({required RemessaModel filtro}) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      icon: const Icon(
        size: 40,
        Icons.download,
        color: Colors.lightBlue,
      ),
      onPressed: (() {
        _downloadXlsx(filtro: filtro);
      }),
    );
  }

  Widget iconButtonPrint({required RemessaModel filtro}) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      icon: const Icon(
        size: 40,
        Icons.print,
        color: Colors.lightGreen,
      ),
      onPressed: (() {
        _showPrintDialog(filtro: filtro);
      }),
    );
  }

  Widget _iconButtonUpload() {
    return BotaoUpload(
      size: 20,
      onPressed: _setUpload,
    );
  }

  void _setUploadNomesArquivos({required RemessaModel remessa}) {
    if (!remessa.isOk) {
      remessasController.setUploadNomesArquivos(remessa: remessa);
    } else {
      designSystemController.message(MessageModel.info(
        title: "Analise de Arquivos",
        message: "Arquivos OK!",
      ));
    }
  }

  void _setUpload() {
    uploadRemessaController.setUploadRemessas();
  }

  Widget _body({
    required Widget body,
    required int page,
  }) {
    return SizedBox(
      width: coreModuleController.size,
      height: coreModuleController.sizeH,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          coreModuleController.showMenu
              ? RightWidget(
                  widget: SizedBox(
                    width: coreModuleController.sizeW,
                    height: coreModuleController.sizeH,
                    child: body,
                  ),
                  menuWidth: menuWidth,
                  showMenu: coreModuleController.showMenu,
                  sizeW: coreModuleController.sizeW,
                )
              : Row(
                  children: <Widget>[
                    MenuWidget(
                      page: page,
                    ),
                    RightWidget(
                      widget: SizedBox(
                        width: coreModuleController.sizeW,
                        height: coreModuleController.sizeH,
                        child: body,
                      ),
                      menuWidth: menuWidth,
                      showMenu: coreModuleController.showMenu,
                      sizeW: coreModuleController.sizeW,
                    ),
                  ],
                )
        ],
      ),
    );
  }

  void _downloadAnalise({required RemessaModel filtro}) async {
    if (!filtro.isOk && filtro.protocolosSemBoletos != null) {
      List<BoletoModel> listaBoletosErro = [];
      final boletosAnalise =
          await remessasController.carregarBoletos(remessa: filtro);

      for (dynamic idErro in filtro.protocolosSemBoletos!) {
        for (BoletoModel boleto in boletosAnalise) {
          if (boleto.idCliente == idErro) {
            listaBoletosErro.add(boleto);
          }
        }
      }

      const camposKeys = <String>[
        "ID Cliente",
        "Cliente",
        "Documento",
        "Email",
        "Telefone Fixo",
        "Telefone Movel",
        "ID Contrato",
        "Data Habilitacao contrato",
        "Número de Boleto",
        "Forma de Cobrança",
        "Data Vencimento Fatura",
        "Valor Fatura",
        "Data Emissao Fatura",
        "Arquivo",
        "Data Impressão Fatura",
        "UF",
        "Cidade",
        "Bairro",
        "Tipo Logradouro",
        "Logradouro",
        "Numero",
        "CEP",
        "Solicitante da Geração",
        "ID Fatura",
        "Referencia",
      ];

      var excel = Excel.createExcel();

      Sheet sheetObject = excel[excel.getDefaultSheet()!];
      CellStyle cellStyleTitulos = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        bold: true,
      );

      sheetObject.merge(
          CellIndex.indexByString("A1"), CellIndex.indexByString("W1"),
          customValue:
              "SISTEMA DE REGISTRO DE PROTOCOLO - PROTOCOLOS SEM ARQUIVOS DE BOLETO - ${filtro.nomeArquivo}");

      var titulo = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titulo.cellStyle = cellStyleTitulos;

      var emissao = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 23, rowIndex: 0));
      emissao.value = "Data Emissão :";
      emissao.cellStyle = cellStyleTitulos;

      var dataEmissao = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 24, rowIndex: 0));
      dataEmissao.value = dataFormatoDDMMYYYY.format(filtro.data.toDate());
      dataEmissao.cellStyle = cellStyleTitulos;

      for (var coluna = 0; coluna < camposKeys.length; coluna++) {
        var cell = sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: coluna, rowIndex: 1));
        cell.value = camposKeys[coluna];
        cell.cellStyle = cellStyleTitulos;
      }

      for (BoletoModel boleto in listaBoletosErro) {
        int indexBoleto = listaBoletosErro.indexOf(boleto) + 2;
        final listValores = boleto.toListXlsx();
        int indexValor = 0;
        for (dynamic valor in listValores) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: indexValor, rowIndex: indexBoleto))
              .value = valor;
          indexValor++;
        }
      }

      sheetObject.setColWidth(0, 10);
      sheetObject.setColAutoFit(1);
      sheetObject.setColWidth(2, 0);
      sheetObject.setColWidth(3, 0);
      sheetObject.setColWidth(4, 0);
      sheetObject.setColWidth(5, 0);
      sheetObject.setColAutoFit(6);
      sheetObject.setColWidth(7, 0);
      sheetObject.setColWidth(8, 0);
      sheetObject.setColWidth(9, 0);
      sheetObject.setColAutoFit(10);
      sheetObject.setColWidth(11, 0);
      sheetObject.setColWidth(12, 0);
      sheetObject.setColWidth(13, 0);
      sheetObject.setColWidth(14, 0);
      for (var coluna = 15; coluna < camposKeys.length; coluna++) {
        sheetObject.setColAutoFit(coluna);
      }
      sheetObject.setColWidth(17, 30);
      sheetObject.setColWidth(18, 0);
      sheetObject.setColWidth(22, 0);
      sheetObject.setColWidth(24, 12);
      excel.save(fileName: "${filtro.nomeArquivo} - ERRO FILTRO.xlsx");
    } else if (!filtro.isOk) {
      designSystemController.message(MessageModel.error(
        title: "Analise de Arquivos",
        message:
            "Faça o upload dos nomes dos arquivos em csv para verificação!",
      ));
    } else {
      designSystemController.message(MessageModel.info(
        title: "Analise de Arquivos",
        message: "Arquivos OK!",
      ));
    }
  }

  void _downloadXlsx({required RemessaModel filtro}) async {
    final boletos = await remessasController.carregarBoletos(remessa: filtro);
    const camposKeys = <String>[
      "ID Cliente",
      "Cliente",
      "Documento",
      "Email",
      "Telefone Fixo",
      "Telefone Movel",
      "ID Contrato",
      "Data Habilitacao contrato",
      "Número de Boleto",
      "Forma de Cobrança",
      "Data Vencimento Fatura",
      "Valor Fatura",
      "Data Emissao Fatura",
      "Arquivo",
      "Data Impressão Fatura",
      "UF",
      "Cidade",
      "Bairro",
      "Tipo Logradouro",
      "Logradouro",
      "Numero",
      "CEP",
      "Solicitante da Geração",
      "ID Fatura",
      "Referencia",
    ];

    var excel = Excel.createExcel();

    Sheet sheetObject = excel[excel.getDefaultSheet()!];
    CellStyle cellStyleTitulos = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      bold: true,
    );

    if (isSufixo) {
      sheetObject.merge(
          CellIndex.indexByString("A1"), CellIndex.indexByString("X1"),
          customValue:
              "SISTEMA DE REGISTRO DE PROTOCOLO - ${filtro.nomeArquivo}");

      var titulo = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titulo.cellStyle = cellStyleTitulos;

      var emissao = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 24, rowIndex: 0));
      emissao.value = "Data Emissão :";
      emissao.cellStyle = cellStyleTitulos;

      var dataEmissao = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 25, rowIndex: 0));
      dataEmissao.value = dataFormatoDDMMYYYY.format(filtro.data.toDate());
      dataEmissao.cellStyle = cellStyleTitulos;

      var codDeBarras = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 25, rowIndex: 1));
      codDeBarras.value = "Cód. De Barras";
      codDeBarras.cellStyle = cellStyleTitulos;
      sheetObject.setColWidth(8, 0);
      sheetObject.setColWidth(24, 15);
      sheetObject.setColWidth(25, 25);
    } else {
      sheetObject.merge(
          CellIndex.indexByString("A1"), CellIndex.indexByString("W1"),
          customValue:
              "SISTEMA DE REGISTRO DE PROTOCOLO - ${filtro.nomeArquivo}");

      var titulo = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titulo.cellStyle = cellStyleTitulos;

      var emissao = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 23, rowIndex: 0));
      emissao.value = "Data Emissão :";
      emissao.cellStyle = cellStyleTitulos;

      var dataEmissao = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 24, rowIndex: 0));
      dataEmissao.value = dataFormatoDDMMYYYY.format(filtro.data.toDate());
      dataEmissao.cellStyle = cellStyleTitulos;
      sheetObject.setColAutoFit(8);
      sheetObject.setColWidth(24, 12);
    }

    for (var coluna = 0; coluna < camposKeys.length; coluna++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: coluna, rowIndex: 1));
      cell.value = camposKeys[coluna];
      cell.cellStyle = cellStyleTitulos;
    }

    for (BoletoModel boleto in boletos) {
      int indexBoleto = boletos.indexOf(boleto) + 2;
      int indexValor = 0;
      final listValores = boleto.toListXlsx();
      for (dynamic valor in listValores) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: indexValor, rowIndex: indexBoleto))
            .value = valor;
        indexValor++;
      }
      if (isSufixo) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(
                columnIndex: indexValor, rowIndex: indexBoleto))
            .value = _gerarCodigoDeBarras(boleto: boleto);
      }
    }

    sheetObject.setColWidth(0, 10);
    sheetObject.setColAutoFit(1);
    sheetObject.setColWidth(2, 0);
    sheetObject.setColWidth(3, 0);
    sheetObject.setColWidth(4, 0);
    sheetObject.setColWidth(5, 0);
    sheetObject.setColAutoFit(6);
    sheetObject.setColWidth(7, 0);
    sheetObject.setColWidth(9, 0);
    sheetObject.setColAutoFit(10);
    sheetObject.setColWidth(11, 0);
    sheetObject.setColWidth(12, 0);
    sheetObject.setColWidth(13, 0);
    sheetObject.setColWidth(14, 0);
    for (var coluna = 15; coluna < camposKeys.length; coluna++) {
      sheetObject.setColAutoFit(coluna);
    }
    sheetObject.setColWidth(17, 30);
    sheetObject.setColWidth(18, 0);
    sheetObject.setColWidth(22, 0);
    excel.save(fileName: "${filtro.nomeArquivo} - FILTRO.xlsx");
  }

  String _gerarCodigoDeBarras({required BoletoModel boleto}) {
    if (isSufixo) {
      final sufixo = _sufixo.toString().substring(0, 3);
      final codBoleto = boleto.numeroDeBoleto.toString();
      String complementoZero = "";
      for (var zero = 0; zero < 14 - (codBoleto.length); zero++) {
        complementoZero = "${complementoZero}0";
      }
      final tipo = boleto.formaDeCobranca!.contains("CARNE") ? "C" : "B";
      const prefixo = "MB";
      final padraoNovo = "$prefixo$tipo$complementoZero$codBoleto$sufixo";
      return padraoNovo;
    } else {
      return boleto.numeroDeBoleto.toString();
    }
  }

  _showPrintDialog({required RemessaModel filtro}) {
    return Get.dialog(
      AlertDialog(
        title: const Text("Impressão da listagem dos Protoclos"),
        content: SizedBox(
          width: coreModuleController.getSizeProporcao(
            size: coreModuleController.size,
            proporcao: 75,
          ),
          height: coreModuleController.getSizeProporcao(
            size: coreModuleController.sizeH,
            proporcao: 75,
          ),
          child: _pdf2(
            filtro: filtro,
            titulo: "Lista de boletos",
          ),
        ),
      ),
    );
  }

  Future<pw.Widget> _protocolosListPrintWidget({
    required RemessaModel remessa,
    required List<BoletoModel> boletos,
    required dynamic netImage,
  }) async {
    return pw.SizedBox(
      width: coreModuleController.getSizeProporcao(
        size: coreModuleController.size,
        proporcao: 55,
      ),
      child: pw.ListView.builder(
          itemCount: boletos.length,
          itemBuilder: (context, index) {
            final boletoModel = boletos[index];
            return pw.Container(
              // color: PdfColors.amber,
              width: coreModuleController.getSizeProporcao(
                size: coreModuleController.size,
                proporcao: 50,
              ),
              height: 195,
              child: pw.Stack(
                children: [
                  pw.Center(
                    child: pw.Image(netImage),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 0, 3, 8),
                    child: pw.Align(
                      alignment: pw.Alignment.bottomRight,
                      child: pw.Text(
                        remessa.nomeArquivo,
                        style: const pw.TextStyle(fontSize: 5.5),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(152, 35, 22, 10),
                    child: pw.Container(
                      width: 325,
                      // color: PdfColors.red,
                      child: pw.Text(
                        "${boletoModel.cliente.toString()} - B. ${boletoModel.bairro.toString()} - ${boletoModel.cidade.toString()} / ${boletoModel.uf.toString()} ${boletoModel.tipoLogradouro.toString()} ${boletoModel.logradouro.toString()}, N.:${boletoModel.numero.toString()} - CEP: ${boletoModel.cep.toString()}",
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ),
                  _codigoDeBarras(
                    data: _gerarCodigoDeBarras(boleto: boletoModel),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(0, 8, 3, 0),
                    child: pw.Align(
                      alignment: pw.Alignment.topRight,
                      child: pw.Text(
                        "${boletoModel.idContrato.toString()} - ${boletoModel.quantidadeBoletos < 10 ? "0${boletoModel.quantidadeBoletos.toString()}" : boletoModel.quantidadeBoletos.toString()} b",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(15, 60, 22, 10),
                    child: pw.Align(
                      alignment: pw.Alignment.topRight,
                      child: pw.Text(
                        dataFormatoDDMMYYYY.format(
                          boletoModel.dataVencimentoFatura!.toDate(),
                        ),
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(6, 35, 5, 10),
                    child: pw.Align(
                      alignment: pw.Alignment.bottomLeft,
                      child: pw.Container(
                        width: 127,
                        // color: PdfColors.amber,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              boletoModel.idCliente.toString(),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                            pw.Text(
                              "${boletoModel.cliente.toString()} - B. ${boletoModel.bairro.toString()} - ${boletoModel.cidade.toString()} / ${boletoModel.uf.toString()} ${boletoModel.tipoLogradouro.toString()} ${boletoModel.logradouro.toString()}, N.:${boletoModel.numero.toString()} - CEP: ${boletoModel.cep.toString()}${boletoModel.referencia.toString() != "null" ? " - REF.:${boletoModel.referencia}" : ""}",
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                            pw.Text(
                              "Remetente:\nMOBTELECOM\nAV. Abolição, 4140 - Mucuripe\nFortaleza - CE\n60165-082",
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ],
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  pw.Widget _codigoDeBarras({
    required String data,
  }) {
    final double larguraCodigoDeBarras =
        (data.toString().length * 10.5).toDouble();
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(10, 10, 10, 83),
      child: pw.Container(
        // color: PdfColors.red100,
        child: pw.Row(
          children: [
            pw.Align(
                alignment: pw.Alignment.bottomLeft,
                child: pw.SizedBox(
                  child: pw.BarcodeWidget(
                    data: data.toString(),
                    width: larguraCodigoDeBarras,
                    height: 45,
                    barcode: pw.Barcode.code128(),
                    drawText: true,
                  ),
                  width: larguraCodigoDeBarras,
                  height: 45,
                )),
            pw.SizedBox(width: 10),
            pw.SizedBox(
              child: pw.BarcodeWidget(
                data: data.toString(),
                width: 45,
                height: 45,
                barcode: pw.Barcode.qrCode(),
                drawText: false,
              ),
              width: 45,
              height: 45,
            ),
            pw.SizedBox(width: 126),
          ],
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.end,
        ),
      ),
    );
  }

  Future<pw.Widget> _listaConferenciaPrintWidget({
    required List<BoletoModel> boletos,
  }) async {
    return pw.SizedBox(
      width: coreModuleController.getSizeProporcao(
        size: coreModuleController.size,
        proporcao: 55,
      ),
      child: pw.ListView.builder(
          itemCount: boletos.length,
          itemBuilder: (context, index) {
            final boletoModel = boletos[index];
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: (index % 2) == 0 ? PdfColors.white : PdfColors.grey200,
                border: const pw.Border(
                  top: pw.BorderSide(width: 0.5, color: PdfColors.black),
                  bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
                ),
              ),
              width: coreModuleController.getSizeProporcao(
                size: coreModuleController.size,
                proporcao: 50,
              ),
              height: 12,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.SizedBox(
                        width: 25,
                        child: pw.Container(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              "${(index + 1)}",
                              style: const pw.TextStyle(fontSize: 10),
                            )),
                      ),
                      pw.SizedBox(
                        width: 10,
                      ),
                      pw.SizedBox(
                        width: 270,
                        child: pw.Container(
                            child: pw.Text(
                          boletoModel.cliente,
                          style: const pw.TextStyle(fontSize: 10),
                        )),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.SizedBox(
                        width: 100,
                        child: pw.Container(
                            child: pw.Text(
                          "ID Cliente: ${boletoModel.idCliente.toString()}",
                          style: const pw.TextStyle(fontSize: 9),
                        )),
                      ),
                      pw.SizedBox(
                        width: 100,
                        child: pw.Container(
                            child: pw.Text(
                          "ID Contrato: ${boletoModel.idContrato.toString()}",
                          style: const pw.TextStyle(fontSize: 9),
                        )),
                      ),
                      pw.SizedBox(
                        width: 35,
                        child: pw.Container(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              "Boletos: ",
                              style: const pw.TextStyle(fontSize: 9),
                            )),
                      ),
                      pw.SizedBox(
                        width: 15,
                        child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              boletoModel.quantidadeBoletos < 10
                                  ? "0${boletoModel.quantidadeBoletos.toString()}"
                                  : boletoModel.quantidadeBoletos.toString(),
                              style: const pw.TextStyle(fontSize: 9),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  _pdf2({
    required RemessaModel filtro,
    required String titulo,
  }) {
    return PdfPreview(
      build: (format) =>
          _generatePdf2(format: format, title: titulo, filtro: filtro),
    );
  }

  Future<Uint8List> _generatePdf2({
    required PdfPageFormat format,
    required String title,
    required RemessaModel filtro,
  }) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final boletos = await remessasController.carregarBoletos(remessa: filtro);

    final netImage = pw.MemoryImage(
      _imagemModelo.value!,
    );

    final protocolos = await _protocolosListPrintWidget(
      remessa: filtro,
      netImage: netImage,
      boletos: boletos,
    );

    final listConferencia =
        await _listaConferenciaPrintWidget(boletos: boletos);

    pdf.addPage(
      pw.MultiPage(
        maxPages: 500,
        pageFormat: format.copyWith(
          marginBottom: 10,
          marginLeft: 20,
          marginRight: 20,
          marginTop: 20,
        ),
        build: (context) => [
          pw.SizedBox(height: 10),
          protocolos,
          pw.SizedBox(height: 10),
        ],
      ),
    );
    pdf.addPage(
      pw.MultiPage(
        maxPages: 500,
        pageFormat: format.copyWith(
          marginBottom: 10,
          marginLeft: 20,
          marginRight: 20,
          marginTop: 20,
        ),
        build: (context) => [
          pw.SizedBox(height: 10),
          pw.Text(
            "Lista para conferencia - ${filtro.nomeArquivo}",
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 10),
          listConferencia,
        ],
      ),
    );

    return pdf.save();
  }
}
