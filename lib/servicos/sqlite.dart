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
        // Ativa o suporte a chaves estrangeiras
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Criação da tabela USUARIO
        await db.execute(
          'CREATE TABLE USUARIO('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'username VARCHAR(25) NOT NULL,'
              'access_token TEXT,'
              'refresh_token TEXT)',
        );

        // Criação da tabela ESTOQUE_MAT_MOV
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

        // Criação da tabela ESTOQUE_MAT_MOV_ITEM com id autoincrementado
        await db.execute(
          'CREATE TABLE ESTOQUE_MAT_MOV_ITEM('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'mov_sqlite INTEGER NOT NULL,'
              'peca VARCHAR(6) NOT NULL,'
              'material VARCHAR(11) NOT NULL,'
              'cor_material VARCHAR(10) NOT NULL,'
              'partida VARCHAR(6) NOT NULL,'
              'unidade VARCHAR(5) NOT NULL,'
              'quantidade REAL,'
              'mov_servidor INTEGER,'
              'desc_material TEXT,'
              'desc_cor_material TEXT,'
              'localizacao TEXT,'
              'filial TEXT,'
              'FOREIGN KEY (mov_sqlite) REFERENCES ESTOQUE_MAT_MOV(mov_sqlite) ON DELETE CASCADE)',
        );
      },
    );
  }

  // Operações para a tabela USUARIO
  Future<void> adicionarUsuario(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.insert(
      'USUARIO',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterUsuarios() async {
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
  Future<int> adicionarMovimento(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    return await db.insert(
      'ESTOQUE_MAT_MOV',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterMovimentos() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV');
  }

  Future<Map<String, dynamic>> obterMovimentoPorId(int movSqlite) async {
    final db = await bancoDados;
    final result = await db.query(
      'ESTOQUE_MAT_MOV',
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<void> atualizarMovimento(int movSqlite, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV',
      dados,
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
  }

  Future<void> finalizarMovimento(int movSqlite) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV',
      {'status': 'Finalizada'},
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
  }

  Future<void> deletarMovimento(int movSqlite) async {
    final db = await bancoDados;
    await db.delete(
      'ESTOQUE_MAT_MOV',
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
  }

  // Operações para a tabela ESTOQUE_MAT_MOV_ITEM
  Future<void> adicionarItem(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.insert(
      'ESTOQUE_MAT_MOV_ITEM',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterItens() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV_ITEM');
  }

  Future<List<Map<String, dynamic>>> obterItensPorMovimento(int movSqlite, int? movServidor) async {
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

  Future<void> atualizarItem(int id, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV_ITEM',
      dados,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletarItem(int id) async {
    final db = await bancoDados;
    await db.delete(
      'ESTOQUE_MAT_MOV_ITEM',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
