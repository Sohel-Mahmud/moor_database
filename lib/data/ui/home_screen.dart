import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moor_database/widget/new_tag_input_widget.dart';
import 'package:moor_database/widget/new_task_input_widget.dart';
import 'package:provider/provider.dart';

import '../moor_database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: <Widget>[
          _buildCompletedOnlySwitch(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child:showCompleted ? _buildTaskList(context) : _buildTaskListJoin(context),
          ),
          NewTaskInput(),
          NewTagInput()
        ],
      ),
    );
  }

    Row _buildCompletedOnlySwitch() {
    return Row(
      children: <Widget>[
        Text('Completed only'),
        Switch(
          value: showCompleted,
          activeColor: Colors.white,
          onChanged: (newValue) {
            setState(() {
              showCompleted = newValue;
            });
          },
        ),
      ],
    );
  }

  StreamBuilder<List<Task>> _buildTaskList(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder(
      stream: showCompleted ? dao.watchCompletedTasks() : dao.wathcAllTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, dao);
          },
        );
      },
    );
  }

  Widget _buildListItem(Task itemTask, TaskDao dao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(itemTask),
        )
      ],
      child: CheckboxListTile(
        title: Text(itemTask.name),
        subtitle: Text(itemTask.dueDate?.toString() ?? 'No date'),
        value: itemTask.completed,
        onChanged: (newValue) {
          dao.updateTask(itemTask.copyWith(completed: newValue));
        },
      ),
    );
  }

  StreamBuilder<List<TaskWithTag>> _buildTaskListJoin(BuildContext context) {
    final dao = Provider.of<TaskDao>(context);
    return StreamBuilder(
      stream: dao.watchAllTaskWithTag(),
      builder: (context, AsyncSnapshot<List<TaskWithTag>> snapshot) {
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final item = tasks[index];
            return _buildListItemJoin(item, dao);
          },
        );
      },
    );
  }

  Widget _buildListItemJoin(TaskWithTag item, TaskDao dao) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(item.task),
        )
      ],
      child: CheckboxListTile(
        title: Text(item.task.name),
        subtitle: Text(item.task.dueDate?.toString() ?? 'No date'),
        secondary: _buildTag(item.tag),
        value: item.task.completed,
        onChanged: (newValue) {
          dao.updateTask(item.task.copyWith(completed: newValue));
        },
      ),
    );
  }

  Column _buildTag(Tag tag) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (tag != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(tag.colors),
            ),
          ),
          Text(
            tag.name,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }
}
