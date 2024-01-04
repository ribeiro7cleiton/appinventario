import 'package:flutter/material.dart';

import 'loading-button.dart';

// ignore: must_be_immutable
class CardPendence extends StatelessWidget {
  var busy = false;
  var text = "";
  var qtdpen = 0;
  BoxConstraints constraints;
  Function func;

  CardPendence(
      {@required this.busy,
      @required this.func,
      @required this.constraints,
      @required this.text,
      @required this.qtdpen});

  @override
  Widget build(BuildContext context) {
    return qtdpen > 0
        ? Container(
            padding: EdgeInsets.all(constraints.maxWidth * 0.06),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: ' Pendencias',
                        style: TextStyle(color: Colors.redAccent, fontSize: 25),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: qtdpen.toString(),
                        style: TextStyle(color: Colors.redAccent, fontSize: 25),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                LoadingButton(
                    constraints: constraints,
                    busy: busy,
                    text: "Atualizar",
                    func: func),
              ],
            ),
          )
        : Container();
  }
}
