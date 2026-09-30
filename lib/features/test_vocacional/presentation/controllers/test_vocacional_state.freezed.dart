// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_vocacional_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TestVocacionalState {

 bool get isLoading; bool get isSaving; bool get started; TestVocacionalSession? get session; int get currentIndex; Map<String, List<String>> get answers; VocationalTestResult? get result; String? get errorMessage;
/// Create a copy of TestVocacionalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestVocacionalStateCopyWith<TestVocacionalState> get copyWith => _$TestVocacionalStateCopyWithImpl<TestVocacionalState>(this as TestVocacionalState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestVocacionalState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.started, started) || other.started == started)&&(identical(other.session, session) || other.session == session)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.result, result) || other.result == result)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isSaving,started,session,currentIndex,const DeepCollectionEquality().hash(answers),result,errorMessage);

@override
String toString() {
  return 'TestVocacionalState(isLoading: $isLoading, isSaving: $isSaving, started: $started, session: $session, currentIndex: $currentIndex, answers: $answers, result: $result, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $TestVocacionalStateCopyWith<$Res>  {
  factory $TestVocacionalStateCopyWith(TestVocacionalState value, $Res Function(TestVocacionalState) _then) = _$TestVocacionalStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isSaving, bool started, TestVocacionalSession? session, int currentIndex, Map<String, List<String>> answers, VocationalTestResult? result, String? errorMessage
});




}
/// @nodoc
class _$TestVocacionalStateCopyWithImpl<$Res>
    implements $TestVocacionalStateCopyWith<$Res> {
  _$TestVocacionalStateCopyWithImpl(this._self, this._then);

  final TestVocacionalState _self;
  final $Res Function(TestVocacionalState) _then;

/// Create a copy of TestVocacionalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isSaving = null,Object? started = null,Object? session = freezed,Object? currentIndex = null,Object? answers = null,Object? result = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,started: null == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as TestVocacionalSession?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as VocationalTestResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TestVocacionalState].
extension TestVocacionalStatePatterns on TestVocacionalState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestVocacionalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestVocacionalState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestVocacionalState value)  $default,){
final _that = this;
switch (_that) {
case _TestVocacionalState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestVocacionalState value)?  $default,){
final _that = this;
switch (_that) {
case _TestVocacionalState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isSaving,  bool started,  TestVocacionalSession? session,  int currentIndex,  Map<String, List<String>> answers,  VocationalTestResult? result,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestVocacionalState() when $default != null:
return $default(_that.isLoading,_that.isSaving,_that.started,_that.session,_that.currentIndex,_that.answers,_that.result,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isSaving,  bool started,  TestVocacionalSession? session,  int currentIndex,  Map<String, List<String>> answers,  VocationalTestResult? result,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _TestVocacionalState():
return $default(_that.isLoading,_that.isSaving,_that.started,_that.session,_that.currentIndex,_that.answers,_that.result,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isSaving,  bool started,  TestVocacionalSession? session,  int currentIndex,  Map<String, List<String>> answers,  VocationalTestResult? result,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _TestVocacionalState() when $default != null:
return $default(_that.isLoading,_that.isSaving,_that.started,_that.session,_that.currentIndex,_that.answers,_that.result,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _TestVocacionalState extends TestVocacionalState {
  const _TestVocacionalState({this.isLoading = false, this.isSaving = false, this.started = false, this.session, this.currentIndex = 0, final  Map<String, List<String>> answers = const {}, this.result, this.errorMessage}): _answers = answers,super._();


@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool started;
@override final  TestVocacionalSession? session;
@override@JsonKey() final  int currentIndex;
 final  Map<String, List<String>> _answers;
@override@JsonKey() Map<String, List<String>> get answers {
  if (_answers is EqualUnmodifiableMapView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_answers);
}

@override final  VocationalTestResult? result;
@override final  String? errorMessage;

/// Create a copy of TestVocacionalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestVocacionalStateCopyWith<_TestVocacionalState> get copyWith => __$TestVocacionalStateCopyWithImpl<_TestVocacionalState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestVocacionalState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.started, started) || other.started == started)&&(identical(other.session, session) || other.session == session)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.result, result) || other.result == result)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isSaving,started,session,currentIndex,const DeepCollectionEquality().hash(_answers),result,errorMessage);

@override
String toString() {
  return 'TestVocacionalState(isLoading: $isLoading, isSaving: $isSaving, started: $started, session: $session, currentIndex: $currentIndex, answers: $answers, result: $result, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$TestVocacionalStateCopyWith<$Res> implements $TestVocacionalStateCopyWith<$Res> {
  factory _$TestVocacionalStateCopyWith(_TestVocacionalState value, $Res Function(_TestVocacionalState) _then) = __$TestVocacionalStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isSaving, bool started, TestVocacionalSession? session, int currentIndex, Map<String, List<String>> answers, VocationalTestResult? result, String? errorMessage
});




}
/// @nodoc
class __$TestVocacionalStateCopyWithImpl<$Res>
    implements _$TestVocacionalStateCopyWith<$Res> {
  __$TestVocacionalStateCopyWithImpl(this._self, this._then);

  final _TestVocacionalState _self;
  final $Res Function(_TestVocacionalState) _then;

/// Create a copy of TestVocacionalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isSaving = null,Object? started = null,Object? session = freezed,Object? currentIndex = null,Object? answers = null,Object? result = freezed,Object? errorMessage = freezed,}) {
  return _then(_TestVocacionalState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,started: null == started ? _self.started : started // ignore: cast_nullable_to_non_nullable
as bool,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as TestVocacionalSession?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as VocationalTestResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
