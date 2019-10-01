import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_keeper/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null)
      _databaseHelper = DatabaseHelper._createInstance();
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get directory path for both iOS and Android to store database;
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    //Open/create the database at the given path
    var notesDatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  Future _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,'
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //Fetch operation: Get all Notes from the database
  Future<List<Map<String, dynamic>>> getNodeMapList() async {
    Database db = await this.database;
    //var result = db.rawQuery('SELECT * FROM $noteTable ORDER BY $colPriority ASC');
    var result = db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  //Insert operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = db.insert(noteTable, note.toMap());
    return result;
  }

  //Update operation: Update Note object and save it to the database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = db.update(noteTable, note.toMap(),
        where: '$colId=?', whereArgs: [note.id]);
    return result;
  }

  //Delete operation: Delete a Note object from Database
  Future<int> deleteNote(int noteId) async {
    var db = await this.database;
    int result =
        await db.delete(noteTable, where: '$colId=?', whereArgs: [noteId]);
    return result;
  }

  //Get Number of Note Objects in the database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    var result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNodeMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();

    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
