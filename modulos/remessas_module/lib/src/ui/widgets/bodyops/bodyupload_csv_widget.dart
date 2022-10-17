import 'package:dependencies_module/dependencies_module.dart';
import 'package:flutter/material.dart';

class BodyUploadRemessaWidget extends StatelessWidget {
  const BodyUploadRemessaWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: coreModuleController.sizeH,
      child: Container(
        color: Colors.black12,
        child: Center(
          child: Obx(() {
            return Column(
              children: <Widget>[
                _tabBar(),
                _tabBarView(),
              ],
            );
          }),
        ),
      ),
    );
  }
}

_tabBar() {
  return Container(
    height: tabHeight,
    color: Colors.red[200],
    child: TabBar(
      controller: remessasController.tabController,
      labelColor: Colors.white,
      indicatorColor: Colors.grey[800],
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      tabs: coreModuleController.showMenu
          ? remessasController.myTabsSmall
          : remessasController.myTabs,
    ),
  );
}

_tabBarView() {
  return SizedBox(
    width: coreModuleController.sizeW,
    height: coreModuleController.sizeH - tabHeight,
    child: TabBarView(
      controller: remessasController.tabController,
      children: [
        // Center(),
        _todasRemessasList()
      ],
    ),
  );
}

_todasRemessasList() {
  final filtro = remessasController.listTadasRemessas;

  return Obx(
    () => Center(
      child: ListView.builder(
        itemCount: filtro.length,
        itemBuilder: (context, index) {
          final remessaModel = filtro[index];
          String nomeRemessa = remessaModel.nomeArquivo.length >= 100
              ? remessaModel.nomeArquivo.substring(0, 100)
              : remessaModel.nomeArquivo;
          return Center(
            child: Card(
              elevation: 0.5,
              child: SizedBox(
                width: 750,
                child: ListTile(
                  title: Text(nomeRemessa),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Data da Remessa: ${dataFormatoDDMMYYYY.format(remessaModel.data.toDate())}",
                      ),
                      Text(
                        "Data de Upload: ${dataFormatoDDMMYYYY.format(remessaModel.upload.toDate())}",
                      ),
                      Text(
                        "Quantidade de Protocolos: ${remessaModel.quantidadeProtocolos.toString()}",
                      ),
                      remessaModel.arquivosInvalidos != null
                          ? Text(
                              "Arquivos inválidos: ${remessaModel.arquivosInvalidos.toString()}",
                              style: const TextStyle(color: Colors.red),
                            )
                          : Container(),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 210,
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        designSystemController.iconButtonPrint(
                          filtro: remessaModel,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        designSystemController.iconDownloadXlsx(
                          filtro: remessaModel,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        designSystemController.iconUploadNomesArquivos(
                          filtro: remessaModel,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        designSystemController.iconDownloadAnalitic(
                          filtro: remessaModel,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
