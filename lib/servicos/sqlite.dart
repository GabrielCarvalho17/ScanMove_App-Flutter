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

  // Operações para a tabela USUARIO
  Future<void> adicionarUsuario(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.insert(
      'USUARIO',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterUsuarios({int? id, bool? logado}) async {
    final db = await bancoDados;

    if (id != null) {
      // Se o ID for fornecido, obtenha o usuário com esse ID
      return await db.query(
        'USUARIO',
        where: 'id = ?',
        whereArgs: [id],
      );
    } else if (logado != null) {
      // Se o parâmetro logado for fornecido, filtra os usuários baseando-se nos tokens
      return await db.query(
        'USUARIO',
        where: logado
            ? 'access_token != "" AND refresh_token != ""' // Usuários logados
            : 'access_token = "" AND refresh_token = ""', // Usuários não logados
      );
    } else {
      // Se nenhum parâmetro for fornecido, obtenha todos os usuários
      return await db.query('USUARIO');
    }
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
  Future<int> adicionarMovimentacao(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    return await db.insert(
      'ESTOQUE_MAT_MOV',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterMovimentacoes() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV');
  }

  Future<Map<String, dynamic>> obterMovimentacaoPorId(int movServidor) async {
    final db = await bancoDados;
    final result = await db.query(
      'ESTOQUE_MAT_MOV',
      where: 'mov_servidor = ?',
      whereArgs: [movServidor],
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<void> atualizarMovimentacao(
      int movSqlite, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV',
      dados,
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
  }

  Future<void> finalizarMovimentacao(int movSqlite) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV',
      {'status': 'Finalizada'},
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );
  }

  Future<bool> deletarMovimentacao(int movServidor) async {
    final db = await bancoDados;
    int rows = await db.delete(
      'ESTOQUE_MAT_MOV',
      where: 'mov_servidor = ?', // Use o nome correto da coluna
      whereArgs: [movServidor],
    );
    return rows > 0;
  }

  // Operações para a tabela ESTOQUE_MAT_MOV_PECA
  Future<void> adicionarPeca(Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.insert(
      'ESTOQUE_MAT_MOV_PECA',
      dados,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> obterPecas() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV_PECA');
  }

  Future<List<Map<String, dynamic>>> obterIPecasPorMovimentacao(
      int movSqlite) async {
    final db = await bancoDados;
    String whereClause;
    List<dynamic> whereArgs;

    whereClause = 'mov_sqlite = ?';
    whereArgs = [movSqlite];

    return await db.query(
      'ESTOQUE_MAT_MOV_PECA',
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  Future<void> atualizarPecas(int id, Map<String, dynamic> dados) async {
    final db = await bancoDados;
    await db.update(
      'ESTOQUE_MAT_MOV_PECA',
      dados,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletarPeca(int id) async {
    final db = await bancoDados;
    await db.delete(
      'ESTOQUE_MAT_MOV_PECA',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getMovimentacoesExistentes() async {
    final db = await bancoDados;
    return await db.query('ESTOQUE_MAT_MOV');
  }

  Future<Map<String, dynamic>> obterMovimentacaoComPecas(
      int movServidor) async {
    final db = await bancoDados;

    // Primeiro, obtenha a movimentação
    final movimentacao = await db.query(
      'ESTOQUE_MAT_MOV',
      where: 'mov_servidor = ?',
      whereArgs: [movServidor],
    );

    if (movimentacao.isEmpty) {
      return {}; // Retorna um mapa vazio se a movimentação não for encontrada
    }

    // Extraia o id da movimentação
    final movSqlite = movimentacao.first['mov_sqlite'] as int;

    // Em seguida, obtenha os pecas associados a esta movimentação
    final pecas = await db.query(
      'ESTOQUE_MAT_MOV_PECA',
      where: 'mov_sqlite = ?',
      whereArgs: [movSqlite],
    );

    // Combine os resultados em uma estrutura
    return {
      'movimentacao': movimentacao.first,
      'pecas': pecas,
    };
  }
}
