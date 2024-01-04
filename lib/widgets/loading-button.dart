import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LoadingButton extends StatelessWidget {
  var busy = false;
  var text = "";
  BoxConstraints constraints;
  Function func;

  LoadingButton(
      {@required this.busy,
      @required this.func,
      @required this.constraints,
      @required this.text});

  @override
  Widget build(BuildContext context) {
    return busy
        ? Container(
            alignment: Alignment.center,
            height: 50,
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          )
        : Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.25, vertical: 20),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'calibri',
                    fontSize: 16,
                  )),
              onPressed: func,
              child: Text(
                text,
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
  }
}
