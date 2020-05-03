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

@UseMoor(tables: [Tasks], daos: [TaskDao])
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

}

///usng dao with typesafe custom sql which builds using build runner
@UseDao(
  tables: [Tasks],
  queries: {
    'completedTasksGenerated':
        'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;'
  },
)
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  final AppDatabase db;

  TaskDao(this.db) : super(db);

  //regular future no observer
  Future<List<Task>> getAllTasks() => select(tasks).get();
  //stream observes the data changes and updates
  Stream<List<Task>> wathcAllTasks() {
    ///to use cascading (..) needs first bracket
    ///cz orderBy returns void and we dont want to return void, we want
    ///to watch the stream
    return (select(tasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  ///customquery changed in update, previous one depricated
  ///non type safe, new update is type safe, done on @UseDao section
  Stream<List<Task>> watchCompletedTasksCustom() {
    return customSelectStream(
        'SELECT * FROM tasks WHERE completed = 1 ORDER BY due_date DESC, name;',
        readsFrom: {tasks}).map((rows) {
      return rows.map((row) => Task.fromData(row.data, db)).toList();
    });
  }

  Future<int> insertTask(Insertable<Task> task) => into(tasks).insert(task);
  Future updateTask(Insertable<Task> task) => update(tasks).replace(task);
  Future deleteTask(Insertable<Task> task) => delete(tasks).delete(task);

  ///ordering by completed and watch them
  Stream<List<Task>> watchCompletedTasks() {
    ///to use cascading (..) needs first bracket
    ///cz orderBy returns void and we dont want to return void, we want
    ///to watch the stream
    return (select(tasks)
          ..orderBy([
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ])
          ..where((t) => t.completed.equals(true)))
        .watch();
  }
}
