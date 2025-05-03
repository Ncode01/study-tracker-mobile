import 'package:hive/hive.dart';
import 'package:bytelearn_study_tracker/models/project.dart';
import 'package:bytelearn_study_tracker/models/session.dart';
import 'package:bytelearn_study_tracker/models/goal.dart';
import 'package:bytelearn_study_tracker/models/settings.dart';

/// Initialize Hive and register type adapters
Future<void> initHive() async {
  // Register adapters
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(SessionAdapter());
  Hive.registerAdapter(GoalTypeAdapter());
  Hive.registerAdapter(GoalPeriodAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(TimerSettingsAdapter());

  // Open boxes
  await Hive.openBox<Project>('projects');
  await Hive.openBox<Session>('sessions');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Settings>('settings');
}

/// Project type adapter
class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    return Project(
      id: reader.read(),
      title: reader.read(),
      description: reader.read(),
      deadline: reader.read(),
      category: reader.read(),
      isCompleted: reader.read(),
      createdAt: reader.read(),
      updatedAt: reader.read(),
      sessionIds: List<String>.from(reader.read()),
      goalIds: List<String>.from(reader.read()),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.deadline);
    writer.write(obj.category);
    writer.write(obj.isCompleted);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
    writer.write(obj.sessionIds);
    writer.write(obj.goalIds);
  }
}

/// Session type adapter
class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 1;

  @override
  Session read(BinaryReader reader) {
    return Session(
      id: reader.read(),
      projectId: reader.read(),
      startTime: reader.read(),
      endTime: reader.read(),
      duration: reader.read(),
      notes: reader.read(),
      isCompleted: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer.write(obj.id);
    writer.write(obj.projectId);
    writer.write(obj.startTime);
    writer.write(obj.endTime);
    writer.write(obj.duration);
    writer.write(obj.notes);
    writer.write(obj.isCompleted);
  }
}

/// GoalType enum adapter
class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 2;

  @override
  GoalType read(BinaryReader reader) {
    return GoalType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    writer.writeByte(obj.index);
  }
}

/// GoalPeriod enum adapter
class GoalPeriodAdapter extends TypeAdapter<GoalPeriod> {
  @override
  final int typeId = 3;

  @override
  GoalPeriod read(BinaryReader reader) {
    return GoalPeriod.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, GoalPeriod obj) {
    writer.writeByte(obj.index);
  }
}

/// Goal type adapter
class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 4;

  @override
  Goal read(BinaryReader reader) {
    return Goal(
      id: reader.read(),
      title: reader.read(),
      projectId: reader.read(),
      type: reader.read(),
      period: reader.read(),
      targetValue: reader.read(),
      currentValue: reader.read(),
      createdAt: reader.read(),
      deadline: reader.read(),
      isCompleted: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.projectId);
    writer.write(obj.type);
    writer.write(obj.period);
    writer.write(obj.targetValue);
    writer.write(obj.currentValue);
    writer.write(obj.createdAt);
    writer.write(obj.deadline);
    writer.write(obj.isCompleted);
  }
}

/// Settings type adapter
class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 5;

  @override
  Settings read(BinaryReader reader) {
    return Settings(
      darkMode: reader.read(),
      notificationsEnabled: reader.read(),
      notificationTypes: List<String>.from(reader.read()),
      timerSettings: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer.write(obj.darkMode);
    writer.write(obj.notificationsEnabled);
    writer.write(obj.notificationTypes);
    writer.write(obj.timerSettings);
  }
}

/// TimerSettings type adapter
class TimerSettingsAdapter extends TypeAdapter<TimerSettings> {
  @override
  final int typeId = 6;

  @override
  TimerSettings read(BinaryReader reader) {
    return TimerSettings(
      usePomodoroTimer: reader.read(),
      workDuration: reader.read(),
      shortBreakDuration: reader.read(),
      longBreakDuration: reader.read(),
      sessionsBeforeLongBreak: reader.read(),
      runInBackground: reader.read(),
      playSoundOnComplete: reader.read(),
      keepScreenOn: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, TimerSettings obj) {
    writer.write(obj.usePomodoroTimer);
    writer.write(obj.workDuration);
    writer.write(obj.shortBreakDuration);
    writer.write(obj.longBreakDuration);
    writer.write(obj.sessionsBeforeLongBreak);
    writer.write(obj.runInBackground);
    writer.write(obj.playSoundOnComplete);
    writer.write(obj.keepScreenOn);
  }
}
