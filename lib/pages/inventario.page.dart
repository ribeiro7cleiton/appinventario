import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:inventario/controllers/registro_pendente.dart';
import 'package:inventario/controllers/retorno_json_padrao.dart';
import 'package:inventario/services/data_base.dart';
import 'package:inventario/widgets/loading-button.dart';
import 'package:asuka/asuka.dart' as asuka;
import 'package:flutter/services.dart' show SystemChannels;
import 'package:http/http.dart' as http;
import 'package:inventario/widgets/pendence-card.dart';

class Inventario extends StatefulWidget {
  @override
  _InventarioState createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  String aCodOri = 'CHA';
  String aNomAss = 'assets/images/chapa.png';
  String aCodBar = '';
  var nQtdPen = 0;
  final codbar = TextEditingController();
  var busy = false;
  int nErrFor = 0;
  String aMsgFor = "";
  final FocusScopeNode _node = FocusScopeNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  DatabaseHandler handler;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      RetQtdReg(handler).then((value) => setState(() {
            nQtdPen = value;
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    String tokenSopasta = data["tokenSopasta"];

    setState(() {});
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: LayoutBuilder(builder: (_, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(constraints.maxWidth * 0.1),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.all(constraints.maxWidth * 0.06),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 30,
                                  width: 150,
                                  child:
                                      Image.asset("assets/images/sopasta.png"),
                                  decoration: BoxDecoration(),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'INVENTÁRIO',
                                    style: TextStyle(
                                      color: Colors.lightGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'calibri',
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Image.asset(aNomAss),
                                ),
                                DropdownButton<String>(
                                  value: aCodOri,
                                  icon:
                                      const Icon(Icons.arrow_drop_down_circle),
                                  iconSize: 40,
                                  items: <String>['CHA', 'BOB', 'EMB']
                                      .map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      aCodOri = newValue;
                                      switch (aCodOri) {
                                        case 'CHA':
                                          aNomAss = 'assets/images/chapa.png';
                                          break;
                                        case 'BOB':
                                          aNomAss = 'assets/images/papel.png';
                                          break;
                                        case 'EMB':
                                          aNomAss = 'assets/images/caixa.png';
                                          break;
                                        default:
                                          aNomAss = 'assets/images/chapa.png';
                                      }
                                    });
                                  },
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.green),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                FocusScope(
                                  node: _node,
                                  child: TextFormField(
                                    autofocus: true,
                                    maxLength: 30,
                                    onEditingComplete: () {
                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.hide');
                                      aMsgFor = validaTexto(codbar.text);
                                      if (aMsgFor != "") {
                                        asuka.AsukaSnackbar.alert(aMsgFor)
                                            .show();
                                      } else {
                                        setState(() {
                                          busy = true;
                                        });
                                        aCodBar = codbar.text;
                                        runApi(codbar.text, tokenSopasta,
                                                aCodOri)
                                            .then((response) => {
                                                  setState(() {
                                                    busy = false;
                                                  }),
                                                  if (response.error == 1)
                                                    {
                                                      asuka.AsukaSnackbar.alert(
                                                              "Erro: " +
                                                                  response
                                                                      .message)
                                                          .show(),
                                                      addregistro(
                                                              Registro(
                                                                  codbar:
                                                                      aCodBar,
                                                                  codori:
                                                                      aCodOri),
                                                              handler)
                                                          .then((value) => {
                                                                RetQtdReg(
                                                                        handler)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              setState(() {
                                                                                nQtdPen = value;
                                                                              }),
                                                                            }),
                                                                codbar.clear(),
                                                              }),
                                                    }
                                                  else
                                                    {
                                                      asuka.AsukaSnackbar
                                                              .success(response
                                                                  .message)
                                                          .show(),
                                                      codbar.clear(),
                                                    },
                                                  _node.requestFocus(),
                                                });
                                      }
                                    },
                                    style: new TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontFamily: 'calibri'),
                                    decoration: InputDecoration(
                                      labelText: "Código de Barras",
                                      labelStyle:
                                          TextStyle(color: Colors.green),
                                      suffixIcon: IconButton(
                                          icon: Icon(Icons.add_a_photo),
                                          iconSize: 35,
                                          onPressed: () {
                                            readBarCode().then((value) => {
                                                  if (value != '-1')
                                                    {
                                                      codbar.text = value,
                                                      SystemChannels.textInput
                                                          .invokeMethod(
                                                              'TextInput.hide'),
                                                      aMsgFor = validaTexto(
                                                          codbar.text),
                                                      if (aMsgFor != "")
                                                        {
                                                          asuka.AsukaSnackbar
                                                                  .alert(
                                                                      aMsgFor)
                                                              .show(),
                                                        }
                                                      else
                                                        {
                                                          setState(() {
                                                            busy = true;
                                                          }),
                                                          aCodBar = codbar.text,
                                                          runApi(
                                                                  aCodBar,
                                                                  tokenSopasta,
                                                                  aCodOri)
                                                              .then(
                                                                  (response) =>
                                                                      {
                                                                        setState(
                                                                            () {
                                                                          busy =
                                                                              false;
                                                                        }),
                                                                        if (response.error ==
                                                                            1)
                                                                          {
                                                                            asuka.AsukaSnackbar.alert("Erro: " + response.message).show(),
                                                                            addregistro(Registro(codbar: aCodBar, codori: aCodOri), handler).then((value) =>
                                                                                {
                                                                                  RetQtdReg(handler).then((value) => {
                                                                                        setState(() {
                                                                                          nQtdPen = value;
                                                                                        }),
                                                                                      }),
                                                                                  codbar.clear(),
                                                                                }),
                                                                          }
                                                                        else
                                                                          {
                                                                            asuka.AsukaSnackbar.success(response.message).show(),
                                                                          }
                                                                      }),
                                                        }
                                                    },
                                                  SystemChannels.textInput
                                                      .invokeMethod(
                                                          'TextInput.hide'),
                                                  _node.requestFocus(),
                                                });
                                          }),
                                    ),
                                    controller: codbar,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                LoadingButton(
                                  constraints: constraints,
                                  busy: busy,
                                  text: "Gravar",
                                  func: () {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                    aMsgFor = validaTexto(codbar.text);
                                    if (aMsgFor != "") {
                                      asuka.AsukaSnackbar.alert(aMsgFor).show();
                                    } else {
                                      setState(() {
                                        busy = true;
                                      });
                                      aCodBar = codbar.text;
                                      runApi(codbar.text, tokenSopasta, aCodOri)
                                          .then((response) => {
                                                setState(() {
                                                  busy = false;
                                                }),
                                                if (response.error == 1)
                                                  {
                                                    asuka.AsukaSnackbar.alert(
                                                            "Erro: " +
                                                                response
                                                                    .message)
                                                        .show(),
                                                    addregistro(
                                                            Registro(
                                                                codbar: aCodBar,
                                                                codori:
                                                                    aCodOri),
                                                            handler)
                                                        .then((value) => {
                                                              RetQtdReg(handler)
                                                                  .then(
                                                                      (value) =>
                                                                          {
                                                                            setState(() {
                                                                              nQtdPen = value;
                                                                              codbar.clear();
                                                                            }),
                                                                          }),
                                                            }),
                                                  }
                                                else
                                                  {
                                                    asuka.AsukaSnackbar.success(
                                                            response.message)
                                                        .show(),
                                                    codbar.clear(),
                                                  }
                                              });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CardPendence(
                              busy: busy,
                              func: () {
                                consultaregistros(handler).then((returnBD) => {
                                      nErrFor = 0,
                                      for (final e in returnBD)
                                        {
                                          setState(() {
                                            busy = true;
                                          }),
                                          print(nErrFor),
                                          if (nErrFor == 0)
                                            {
                                              runApi(e.codbar, tokenSopasta,
                                                      e.codori)
                                                  .then((response) => {
                                                        setState(() {
                                                          busy = false;
                                                        }),
                                                        if (response.error == 1)
                                                          {
                                                            nErrFor = 1,
                                                          }
                                                        else
                                                          {
                                                            removeregistro(
                                                                    handler,
                                                                    e.id)
                                                                .then(
                                                                    (value) => {
                                                                          RetQtdReg(handler).then((value) =>
                                                                              {
                                                                                setState(() {
                                                                                  nQtdPen = value;
                                                                                }),
                                                                              }),
                                                                        })
                                                          }
                                                      }),
                                            },
                                        },
                                    });
                              },
                              constraints: constraints,
                              text: 'Atualizar !',
                              qtdpen: nQtdPen),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

Future<RetornoJson> runApi(
    String codbar, String tokenSopasta, String codori) async {
  var data = {"codemp": 1, "codfil": 1, "codbar": codbar, "codori": codori};
  var url = "http://192.168.3.10:3334/enviaregistro";
  //url = "http://svapps:3334/enviarregistro";
  try {
    var response = await http
        .post(url,
            headers: {
              'Content-Type': 'application/json',
              'x-access-token': tokenSopasta
            },
            body: JsonEncoder().convert(data))
        .timeout(const Duration(seconds: 3));
    var json = jsonDecode(response.body);

    if ((response.statusCode == 500) || (response.statusCode == 401)) {
      return RetornoJson(
          message: 'Usuário não autenticado, verifique !', error: 1);
    } else {
      return RetornoJson(message: json['message'], error: json['error']);
    }
    // ignore: unused_catch_clause
  } on TimeoutException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !' +
            e.toString(),
        error: 1);
    // ignore: unused_catch_clause
  } on SocketException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !' +
            e.toString(),
        error: 1);
  }
}

Future<int> addregistro(Registro registro, DatabaseHandler handler) async {
  return await handler.insertRegistro(registro);
}

Future<List> consultaregistros(DatabaseHandler handler) async {
  List<Registro> lista = await handler.retrieveUsers();
  return lista;
}

// ignore: non_constant_identifier_names
Future<int> RetQtdReg(DatabaseHandler handler) async {
  // ignore: non_constant_identifier_names
  var QtdReg = 0;
  List<Registro> lista = await handler.retrieveUsers();

  // ignore: unused_local_variable
  for (final e in lista) {
    QtdReg++;
  }

  return QtdReg;
}

Future<int> removeregistro(DatabaseHandler handler, int id) async {
  var ret;
  ret = await handler.deleteRegistro(id);
  return ret;
}

Future<String> readBarCode() async {
  String code = await FlutterBarcodeScanner.scanBarcode(
      "#00FF00", "", false, ScanMode.BARCODE);
  return code;
}

String validaTexto(String texto) {
  String aMsgFor = "";
  if (texto.length < 10) {
    aMsgFor = "Código de Barras deve ter no mínimo 10 caracteres !";
  }
  if (texto.length > 30) {
    aMsgFor = "Código de Barras deve ter no máximo 30 caracteres !";
  }
  if (texto == "") {
    aMsgFor = "Código de Barras não informado !";
  }
  return aMsgFor;
}
