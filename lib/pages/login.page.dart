import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventario/controllers/retorno_json_padrao.dart';
import 'package:inventario/pages/inventario.page.dart';
import 'package:inventario/widgets/loading-button.dart';
import 'package:asuka/asuka.dart' as asuka;
import 'package:flutter/services.dart' show SystemChannels;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nomusu = TextEditingController();
  final senusu = TextEditingController();
  var busy = false;
  var tokenSopasta;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            height: size.height,
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
                                    child: Image.asset(
                                        "assets/images/sopasta.png"),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    autofocus: true,
                                    style: new TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontFamily: 'calibri'),
                                    decoration: InputDecoration(
                                      labelText: "Usuário",
                                      labelStyle:
                                          TextStyle(color: Colors.green),
                                    ),
                                    controller: nomusu,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    autofocus: true,
                                    obscureText: true,
                                    keyboardType: TextInputType.text,
                                    style: new TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontFamily: 'calibri'),
                                    decoration: InputDecoration(
                                      labelText: "Senha",
                                      labelStyle:
                                          TextStyle(color: Colors.green),
                                    ),
                                    controller: senusu,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  LoadingButton(
                                      constraints: constraints,
                                      busy: busy,
                                      text: "Entrar",
                                      func: () {
                                        SystemChannels.textInput
                                            .invokeMethod('TextInput.hide');
                                        if (nomusu.text == "" ||
                                            senusu.text == "") {
                                          asuka.AsukaSnackbar.alert(
                                                  "Usuário ou senha não informados")
                                              .show();
                                        } else {
                                          setState(() {
                                            busy = true;
                                          });
                                          runApi(nomusu.text, senusu.text)
                                              .then((response) => {
                                                    setState(() {
                                                      busy = false;
                                                    }),
                                                    if (response.error == 1)
                                                      {
                                                        asuka.AsukaSnackbar
                                                                .alert("Erro: " +
                                                                    response
                                                                        .message)
                                                            .show(),
                                                      }
                                                    else
                                                      {
                                                        setState(() {
                                                          busy = true;
                                                        }),
                                                        tokenSopasta =
                                                            response.message,
                                                        runApivalper(
                                                                nomusu.text,
                                                                'INVENTARIO')
                                                            .then(
                                                                (response) => {
                                                                      SystemChannels
                                                                          .textInput
                                                                          .invokeMethod(
                                                                              'TextInput.hide'),
                                                                      setState(
                                                                          () {
                                                                        busy =
                                                                            false;
                                                                      }),
                                                                      if (response
                                                                              .error ==
                                                                          1)
                                                                        {
                                                                          asuka.AsukaSnackbar.alert("Erro: " + response.message)
                                                                              .show(),
                                                                        }
                                                                      else
                                                                        {
                                                                          asuka.AsukaSnackbar.success("Seja Bem Vindo !")
                                                                              .show(),
                                                                          nomusu
                                                                              .clear(),
                                                                          senusu
                                                                              .clear(),
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Inventario(),
                                                                              settings: RouteSettings(
                                                                                name: "EnviarRegistros",
                                                                                arguments: {
                                                                                  "tokenSopasta": tokenSopasta
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        }
                                                                    }),
                                                      }
                                                  });
                                        }
                                      }),
                                ],
                              ),
                            ),
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
      ),
    );
  }
}

Future<RetornoJson> runApi(String nomusu, String senusu) async {
  var data = {"nomusu": nomusu, "senusu": senusu};
  var url = "http://192.168.3.10:3333/login";
  //url = "http://svapps:3333/login";

  try {
    var response = await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: JsonEncoder().convert(data))
        .timeout(const Duration(seconds: 15));
    var json = jsonDecode(response.body);

    return RetornoJson(message: json['message'], error: json['error']);
    // ignore: unused_catch_clause
  } on TimeoutException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !',
        error: 1);
    // ignore: unused_catch_clause
  } on SocketException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde !',
        error: 1);
  }
}

Future<RetornoJson> runApivalper(String nomusu, String nomgru) async {
  var data = {"nomusu": nomusu, "nomgru": nomgru};
  var url = "http://192.168.3.10:3333/consultargrupo";
  //url = "http://svapps:3333/consultargrupo";

  try {
    var response = await http
        .post(url,
            headers: {'Content-Type': 'application/json'},
            body: JsonEncoder().convert(data))
        .timeout(const Duration(seconds: 15));
    var json = jsonDecode(response.body);

    return RetornoJson(message: json['message'], error: json['error']);
    // ignore: unused_catch_clause
  } on TimeoutException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde ! Erro:' +
            e.message,
        error: 1);
    // ignore: unused_catch_clause
  } on SocketException catch (e) {
    return RetornoJson(
        message: 'Servidor Indisponivel, tente novamente mais tarde ! Erro:' +
            e.message,
        error: 1);
  }
}
