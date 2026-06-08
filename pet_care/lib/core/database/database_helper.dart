import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Classe responsável pelo gerenciamento da conexão com o banco de dados SQLite.
/// Utiliza o padrão Singleton para garantir que exista apenas uma instância ativa.
///
/// ### 🔄 Fluxo de Processamento e Ciclo de Vida do Banco de Dados:
///
/// O processamento detalhado da conexão ocorre de forma reativa e assíncrona.
/// O fluxo de sequência está ilustrado e documentado no arquivo separado:
/// 📄 [database_helper_flow.mermaid](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/core/database/database_helper_flow.mermaid)
///
/// #### 1. Padrão Singleton (`DatabaseHelper.instance`)
/// * O construtor privado `_init()` impede instanciações diretas adicionais (`new DatabaseHelper()`).
/// * Garante um único ponto de acesso e gerência de concorrência de escrita/leitura sobre o arquivo SQLite.
///
/// #### 2. Inicialização Preguiçosa (Lazy Initialization)
/// * O getter `database` gerencia o cache em memória na variável privada estática `_database`.
/// * A conexão e criação física ocorrem sob demanda apenas no momento da primeira requisição do banco de dados na aplicação.
///
/// #### 3. Relação com os Modelos de Domínio
/// * O callback `_createDB` é responsável por criar a tabela `pets` estruturada com base nas propriedades do nosso modelo de negócio:
///   * **Modelo `Pet`** (`lib/features/pet/domain/models/pet.dart`) <---> **Tabela `pets`**:
///     * `petId` (int? no modelo) <---> `petId` (INTEGER PRIMARY KEY AUTOINCREMENT)
///     * `nome` (String no modelo) <---> `nome` (TEXT NOT NULL)
///     * `especie` (String no modelo) <---> `especie` (TEXT NOT NULL)
class DatabaseHelper {
  // Instância única na aplicação
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Instância interna do SQLite
  static Database? _database;

  // Construtor privado para o Singleton
  DatabaseHelper._init();

  /// Retorna a instância ativa do banco de dados.
  /// Caso não esteja inicializado, realiza a abertura e configuração.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pet_care.db');
    return _database!;
  }

  /// Inicializa a conexão com o banco de dados.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Configurações globais do SQLite antes de qualquer operação.
  Future _onConfigure(Database db) async {
    // Ativa suporte a chaves estrangeiras
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Cria as tabelas iniciais do banco de dados na versão atual.
  Future _createDB(Database db, int version) async {
    // 1. Tabela de Tutores
    await db.execute('''
      CREATE TABLE tutors (
        tutorId INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        telefone TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        deletedAt TEXT
      )
    ''');

    // 2. Tabela de Pets (com FK para tutors)
    await db.execute('''
      CREATE TABLE pets (
        petId INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        especie TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        deletedAt TEXT
      )
    ''');
  }

  /// Gerencia migrações de esquemas de banco de dados entre versões.
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 1. Cria a tabela de tutores
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tutors (
          tutorId INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          email TEXT NOT NULL,
          telefone TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          deletedAt TEXT
        )
      ''');

      // 2. Adiciona as novas colunas à tabela pets
      final now = DateTime.now().toIso8601String();

      // SQLite permite adicionar colunas via ALTER TABLE
      await db.execute(
        'ALTER TABLE pets ADD COLUMN tutorId INTEGER REFERENCES tutors(tutorId)',
      );
      await db.execute(
        "ALTER TABLE pets ADD COLUMN createdAt TEXT NOT NULL DEFAULT '$now'",
      );
      await db.execute(
        "ALTER TABLE pets ADD COLUMN updatedAt TEXT NOT NULL DEFAULT '$now'",
      );
      await db.execute('ALTER TABLE pets ADD COLUMN deletedAt TEXT');
    }
  }

  /// Fecha a conexão com o banco de dados, se estiver aberta.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
