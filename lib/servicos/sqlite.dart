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
                'password VARCHAR(100) NOT NULL,'
                'access_token TEXT,'
                'refresh_token TEXT)'
        );

        await db.execute(
            'CREATE TABLE ESTOQUE_MAT_MOV('
                'movimentacao INTEGER PRIMARY KEY AUTOINCREMENT,'
                'filial VARCHAR(25) NOT NULL,'
                'data DATETIME(23) NOT NULL,'
                'usuario VARCHAR(25) NOT NULL,'
                'origem VARCHAR(8) NOT NULL,'
                'destino VARCHAR(8),'
                'total_pecas INT,'
                'status VARCHAR(25))'
        );

        await db.execute(
            'CREATE TABLE ESTOQUE_MAT_MOV_ITEM('
                'material VARCHAR(11) NOT NULL,'
                'cor_material VARCHAR(10) NOT NULL,'
                'peca VARCHAR(6) PRIMARY KEY NOT NULL,'
                'partida VARCHAR(6) NOT NULL,'
                'filial VARCHAR(25) NOT NULL,'
                'unidade VARCHAR(5) NOT NULL,'
                'quantidade DECIMAL(10,3),'
                'movimentacao INTEGER NOT NULL,'
                'FOREIGN KEY (movimentacao) REFERENCES ESTOQUE_MAT_MOV(movimentacao))'
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

  Future<void> limparUsuarios() async {
    final db = await bancoDados;
    await db.delete('USUARIO');
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
  Future<void> inserirEstoqueMatMov(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.insert(
      'ESTOQUE_MAT_MOV',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterEstoqueMatMov() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV');
  }

  Future<void> atualizarEstoqueMatMov(int movimentacao, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV',
      dados,
      where: 'movimentacao = ?',
      whereArgs: [movimentacao],
    );
  }

  Future<void> deletarEstoqueMatMov(int movimentacao) async {
    final db = await bancoDados;
    await db.delete(
      'ESTOQUE_MAT_MOV',
      where: 'movimentacao = ?',
      whereArgs: [movimentacao],
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
}
