import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLite {
  static final SQLite _instance = SQLite._internal();
  static Database? _bancoDados;

  factory SQLite() {
    return _instance;
  }

  SQLite._internal();

  Future<Database> get bancoDados async {
    if (_bancoDados != null) return _bancoDados!;
    _bancoDados = await _iniciarDb();
    return _bancoDados!;
  }

  Future<Database> _iniciarDb() async {
    String caminhoDb = await getDatabasesPath();
    String caminho = join(caminhoDb, 'com.estoque_mp.db');
    return await openDatabase(
      caminho,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE USUARIO('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'username VARCHAR(25) NOT NULL,'
          'access_token TEXT,'
          'refresh_token TEXT)',
        );

        await db.execute(
          'CREATE TABLE ESTOQUE_MAT_MOV('
          'mov_sqlite INTEGER PRIMARY KEY AUTOINCREMENT,'
          'mov_servidor INTEGER,'
          'data_inicio DATETIME NOT NULL,'
          'data_modificacao DATETIME NOT NULL,'
          'usuario VARCHAR(25) NOT NULL,'
          'origem VARCHAR(8) NOT NULL,'
          'destino VARCHAR(8),'
          'filial_origem VARCHAR(25) NOT NULL,'
          'filial_destino VARCHAR(25),'
          'total_pecas INTEGER NOT NULL,'
          'status VARCHAR(25) NOT NULL)',
        );

        await db.execute(
          'CREATE TABLE ESTOQUE_MAT_MOV_PECA('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'mov_sqlite INTEGER NOT NULL,'
          'peca VARCHAR(6) NOT NULL,'
          'material VARCHAR(11) NOT NULL,'
          'cor_material VARCHAR(10) NOT NULL,'
          'partida VARCHAR(6) NOT NULL,'
          'unidade VARCHAR(5) NOT NULL,'
          'quantidade REAL,'
          'desc_material TEXT,'
          'desc_cor_material TEXT,'
          'localizacao TEXT,'
          'filial TEXT,'
          'FOREIGN KEY (mov_sqlite) REFERENCES ESTOQUE_MAT_MOV(mov_sqlite) ON DELETE CASCADE)',
        );
      },
    );
  }

  Future<int> inserir(String tabela, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    return await db.insert(
      tabela,
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> listar(String tabela,
      {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await bancoDados;
    return await db.query(
      tabela,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<Map<String, dynamic>?> obter(String tabela, int id) async {
    final db = await bancoDados;
    final resultado = await db.query(
      tabela,
      where: 'id = ?',
      whereArgs: [id],
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  Future<int> atualizar({
    required String tabela,                    // Nome da tabela
    required Map<String, dynamic> valores,     // Mapa de colunas e valores a serem atualizados
    required Map<String, dynamic> whereClausula, // Mapa de colunas e valores para a cláusula WHERE
  }) async {
    final db = await bancoDados;

    // Construir a string de SET usando os valores fornecidos
    String setClausula = valores.keys.map((key) => '$key = ?').join(', ');

    // Construir a string de WHERE usando a cláusula fornecida
    String whereClausulaString = whereClausula.keys.map((key) => '$key = ?').join(' AND ');

    // Combinar os valores de atualização com os valores do WHERE em uma única lista de argumentos
    List<dynamic> argumentos = [...valores.values, ...whereClausula.values];

    return await db.rawUpdate(
      'UPDATE $tabela SET $setClausula WHERE $whereClausulaString',
      argumentos,
    );
  }


  Future<int> deletar({
    required String tabela,
    required Map<String, dynamic> id,
    Map<String, dynamic>? fk,
  }) async {
    final db = await bancoDados;

    // Construção da cláusula WHERE
    String whereClause = '${id.keys.first} = ?';
    List<dynamic> whereArgs = [id.values.first];

    // Se FK for fornecida, adicionar à cláusula WHERE
    if (fk != null) {
      whereClause += ' AND ${fk.keys.first} = ?';
      whereArgs.add(fk.values.first);
    }

    return await db.delete(
      tabela,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }
}
