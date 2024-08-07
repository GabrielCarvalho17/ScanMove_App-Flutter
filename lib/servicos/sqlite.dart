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
    _bancoDados = await _inicializarBanco();
    return _bancoDados!;
  }

  Future<Database> _inicializarBanco() async {
    String caminhoDb = await getDatabasesPath();
    String caminho = join(caminhoDb, 'com.estoque_mp.db');
    return await openDatabase(
      caminho,
      version: 1,
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
              'data DATETIME NOT NULL,'
              'usuario VARCHAR(25) NOT NULL,'
              'origem VARCHAR(8) NOT NULL,'
              'destino VARCHAR(8),'
              'filial_origem VARCHAR(25) NOT NULL,'
              'filial_destino VARCHAR(25),'
              'total_pecas INTEGER NOT NULL,'
              'status VARCHAR(25) NOT NULL)',
        );

        await db.execute(
          'CREATE TABLE ESTOQUE_MAT_MOV_ITEM('
              'peca VARCHAR(6) PRIMARY KEY NOT NULL,'
              'material VARCHAR(11) NOT NULL,'
              'cor_material VARCHAR(10) NOT NULL,'
              'partida VARCHAR(6) NOT NULL,'
              'unidade VARCHAR(5) NOT NULL,'
              'quantidade REAL,'
              'mov_sqlite INTEGER NOT NULL,'  // Ajuste para NOT NULL
              'mov_servidor INTEGER,'
              'desc_material TEXT,'
              'desc_cor_material TEXT,'
              'localizacao TEXT,'
              'filial TEXT,'
              'FOREIGN KEY (mov_sqlite) REFERENCES ESTOQUE_MAT_MOV(mov_sqlite),'
              'FOREIGN KEY (mov_servidor) REFERENCES ESTOQUE_MAT_MOV(mov_servidor))',
        );
      },
    );
  }

  // Operações para a tabela USUARIO
  Future<void> inserirUsuario(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.insert(
      'USUARIO',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterUsuario() async {
    final db = await bancoDados;
    return await db.query('USUARIO');
  }

  Future<void> atualizarUsuario(int id, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'USUARIO',
      dados,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletarUsuario(int id) async {
    final db = await bancoDados;
    await db.delete(
      'USUARIO',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Operações para a tabela ESTOQUE_MAT_MOV
  Future<int> inserirEstoqueMatMov(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    return await db.insert(
      'ESTOQUE_MAT_MOV',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterEstoqueMatMov() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV');
  }

  Future<Map<String, dynamic>> obterEstoqueMatMovPorId(int movSqlite) async {
    final db = await bancoDados;
    final result = await db.query(
      'ESTOQUE_MAT_MOV',
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<void> atualizarEstoqueMatMov(int movSqlite, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV',
      dados,
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
  }

  Future<void> deletarEstoqueMatMov(int movSqlite) async {
    final db = await bancoDados;
    await db.delete(
      'ESTOQUE_MAT_MOV',
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
  }

  // Operações para a tabela ESTOQUE_MAT_MOV_ITEM
  Future<void> inserirEstoqueMatMovItem(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.insert(
      'ESTOQUE_MAT_MOV_ITEM',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterEstoqueMatMovItem() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV_ITEM');
  }

  Future<List<Map<String, dynamic>>> obterEstoqueMatMovItensPorMovimentacao(int movSqlite, int? movServidor) async {
    final db = await bancoDados;
    String whereClause = 'mov_sqlite = ?';
    List<dynamic> whereArgs = [movSqlite];

    if (movServidor != null) {
      whereClause = 'mov_servidor = ?';
      whereArgs = [movServidor];
    }

    return await db.query(
      'ESTOQUE_MAT_MOV_ITEM',
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<void> atualizarEstoqueMatMovItem(String peca, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV_ITEM',
      dados,
      where: 'peca = ?',
      whereArgs: [peca],
    );
  }

  Future<void> deletarEstoqueMatMovItem(String peca) async {
    final db = await bancoDados;
    await db.delete(
      'ESTOQUE_MAT_MOV_ITEM',
      where: 'peca = ?',
      whereArgs: [peca],
    );
  }

  Future<void> deletarEstoqueMatMovItensPorMovimentacao(int movSqlite, int? movServidor) async {
    final db = await bancoDados;
    String whereClause = 'mov_sqlite = ?';
    List<dynamic> whereArgs = [movSqlite];

    if (movServidor != null) {
      whereClause = 'mov_servidor = ?';
      whereArgs = [movServidor];
    }

    await db.delete(
      'ESTOQUE_MAT_MOV_ITEM',
      where: whereClause,
      whereArgs: whereArgs,
    );
  }
}
