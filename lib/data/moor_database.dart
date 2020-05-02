import 'package:moor/moor.dart';
import 'package:moor_flutter/moor_flutter.dart';
//source generator
part 'moor_database.g.dart';

//to change the dataclass name use this annotation
// @DataClassName('Tasks')
class Tasks extends Table {
  //autoIncrement makes it primary key autometically
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(Constant(false))();

  //making custom primary key
  // @override
  // Set<Column> get primaryKey => {id, name};

}

// LazyDatabase _openConnection() {
//   // the LazyDatabase util lets us find the right location for the file async.
//   return LazyDatabase(() async {
//     // put the database file, called db.sqlite here, into the documents folder
//     // for your app.
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'db.sqlite'));
//     return VmDatabase(file);
//   });
// }

@UseMoor(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      // Specify the location of the database file
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqlite', logStatements: true));

  // Bump this when changing tables and columns.
  // Migrations will be covered in the next part.
  @override
  int get schemaVersion => 1;
  /// slect query

  //regular future no observer
  Future<List<Task>> getAllTasks() => select(tasks).get();
  //stream observes the data changes and updates
  Stream<List<Task>> wathcAllTasks() => select(tasks).watch();

  /// insert query

  Future<int> insertTask(Task task) => into(tasks).insert(task);

   
   ///update query
   
  Future updateTask(Task task) => update(tasks).replace(task);
   
   ///insert query
   
    Future deleteTask(Task task) => delete(tasks).delete(task);
  
}
