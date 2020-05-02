import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moor_database/widget/new_task_input_widget.dart';
import 'package:provider/provider.dart';

import '../moor_database.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tasks'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: _buildTaskList(context),
            ),
            NewTaskInput(),
          ],
        ));
  }

  StreamBuilder<List<Task>> _buildTaskList(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return StreamBuilder(
      stream: database.wathcAllTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, database);
          },
        );
      },
    );
  }

  Widget _buildListItem(Task itemTask, AppDatabase database) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => database.deleteTask(itemTask),
        )
      ],
      child: CheckboxListTile(
        title: Text(itemTask.name),
        subtitle: Text(itemTask.dueDate?.toString() ?? 'No date'),
        value: itemTask.completed,
        onChanged: (newValue) {
          database.updateTask(itemTask.copyWith(completed: newValue));
        },
      ),
    );
  }
}
