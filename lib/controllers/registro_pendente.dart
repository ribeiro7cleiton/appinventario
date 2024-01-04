class Registro {
  final String codori;
  final String codbar;
  final int id;

  Registro({this.codori, this.codbar,this.id});

  Registro.fromMap(Map<String, dynamic> res)
      : codori = res["codori"],
        codbar = res["codbar"],
        id = res["id"];

  Map<String, Object> toMap() {
    return {'codori': codori, 'codbar': codbar,'id': id};
  }
}
