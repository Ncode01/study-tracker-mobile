# Quick Start Guide: Using the Rebuilt Data Layer

## For Developers

### Adding New Data Models

1. **Create the model with Hive annotations**:
```dart
@freezed
@HiveType(typeId: 2) // Use next available typeId
class YourModel with _$YourModel {
  const factory YourModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    // Add more fields with sequential HiveField numbers
  }) = _YourModel;

  factory YourModel.fromJson(Map<String, dynamic> json) =>
      _$YourModelFromJson(json);
}
```

2. **Generate adapters**:
```bash
flutter packages pub run build_runner build
```

3. **Register adapter in HiveDataService**:
```dart
if (!Hive.isAdapterRegistered(2)) {
  Hive.registerAdapter(YourModelAdapter());
}
```

4. **Create repository**:
```dart
class HiveYourModelRepositoryImpl implements YourModelRepository {
  Future<List<YourModel>> getItems() async {
    final box = HiveDataService.yourModelsBox;
    return box.values.toList();
  }
  
  Future<void> addItem(YourModel item) async {
    final box = HiveDataService.yourModelsBox;
    await box.put(item.id, item);
  }
}
```

### Using Repositories in UI

```dart
// In your provider
final yourModelsProvider = FutureProvider<List<YourModel>>((ref) async {
  final repo = ref.watch(yourModelRepositoryProvider);
  return repo.getItems();
});

// In your widget
Consumer(
  builder: (context, ref, child) {
    final models = ref.watch(yourModelsProvider);
    return models.when(
      data: (items) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  },
)
```

### Best Practices

1. **Always use repositories**: Never access Hive boxes directly from UI
2. **Handle errors gracefully**: Wrap repository calls in try-catch
3. **Use unique typeIds**: Check existing models to avoid conflicts
4. **Test persistence**: Add tests for your repository implementations
5. **Log operations**: Use the logger for debugging data operations

### Common Patterns

**Batch Operations**:
```dart
Future<void> addMultipleItems(List<YourModel> items) async {
  final box = HiveDataService.yourModelsBox;
  final Map<String, YourModel> entries = {
    for (var item in items) item.id: item
  };
  await box.putAll(entries);
}
```

**Filtered Queries**:
```dart
Future<List<YourModel>> getItemsByCategory(String category) async {
  final box = HiveDataService.yourModelsBox;
  return box.values
      .where((item) => item.category == category)
      .toList();
}
```

**Reactive Updates**:
```dart
// Listen to box changes
final yourModelsStreamProvider = StreamProvider<List<YourModel>>((ref) {
  final box = HiveDataService.yourModelsBox;
  return box.watch().map((_) => box.values.toList());
});
```

## For Maintainers

### Monitoring Data Health

```dart
// Check storage statistics
final info = await HiveDataService.getStorageInfo();
print('Subjects: ${info['subjectsCount']}');
print('Sessions: ${info['studySessionsCount']}');

// Backup data for debugging
final backup = await HiveDataService.backupData();
// Save to file or send to support team
```

### Debugging Tips

1. **Check initialization**: Ensure `HiveDataService.initialize()` is called
2. **Verify adapters**: Check that all adapters are registered
3. **Monitor logs**: Look for Hive-related errors in console
4. **Use Flutter Inspector**: Check provider states and rebuilds
5. **Test with fresh install**: Verify first-launch experience

### Performance Tips

1. **Batch operations**: Use `putAll()` for multiple items
2. **Lazy loading**: Don't load all data at once for large datasets
3. **Index frequently queried fields**: Consider adding indices for better performance
4. **Monitor box sizes**: Track growth and implement cleanup if needed

### Deployment Checklist

- [ ] All adapters registered with unique typeIds
- [ ] Build runner executed for code generation
- [ ] Tests passing for repository operations
- [ ] No direct Hive box access in UI code
- [ ] Error handling implemented for data operations
- [ ] Logging added for debugging
- [ ] Data migration strategy documented (if needed)

---

**Need Help?**
- Check the full documentation: `docs/data_layer_rebuild.md`
- Review existing implementations in `/lib/features/study/data/`
- Test your changes with the provided test suite
