// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todaysRemindersHash() => r'4da58190240fad764245d552890e565290f045ae';

/// See also [todaysReminders].
@ProviderFor(todaysReminders)
final todaysRemindersProvider =
    AutoDisposeFutureProvider<List<Reminder>>.internal(
      todaysReminders,
      name: r'todaysRemindersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$todaysRemindersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaysRemindersRef = AutoDisposeFutureProviderRef<List<Reminder>>;
String _$remindersHash() => r'61be3a9d1ddb35a82f423fa76295deae42fb26d8';

/// See also [Reminders].
@ProviderFor(Reminders)
final remindersProvider =
    AutoDisposeAsyncNotifierProvider<Reminders, List<Reminder>>.internal(
      Reminders.new,
      name: r'remindersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$remindersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Reminders = AutoDisposeAsyncNotifier<List<Reminder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
