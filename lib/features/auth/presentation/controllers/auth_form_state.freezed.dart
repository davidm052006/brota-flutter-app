// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFormState {

 AuthFormStatus get status; String? get errorMessage;
/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFormStateCopyWith<AuthFormState> get copyWith => _$AuthFormStateCopyWithImpl<AuthFormState>(this as AuthFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage);

@override
String toString() {
  return 'AuthFormState(status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AuthFormStateCopyWith<$Res>  {
  factory $AuthFormStateCopyWith(AuthFormState value, $Res Function(AuthFormState) _then) = _$AuthFormStateCopyWithImpl;
@useResult
$Res call({
 AuthFormStatus status, String? errorMessage
});




}
/// @nodoc
class _$AuthFormStateCopyWithImpl<$Res>
    implements $AuthFormStateCopyWith<$Res> {
  _$AuthFormStateCopyWithImpl(this._self, this._then);

  final AuthFormState _self;
  final $Res Function(AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthFormStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthFormState].
extension AuthFormStatePatterns on AuthFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthFormState value)  $default,){
final _that = this;
switch (_that) {
case _AuthFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthFormStatus status,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthFormStatus status,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AuthFormState():
return $default(_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthFormStatus status,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.status,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AuthFormState implements AuthFormState {
  const _AuthFormState({this.status = AuthFormStatus.idle, this.errorMessage});
  

@override@JsonKey() final  AuthFormStatus status;
@override final  String? errorMessage;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthFormStateCopyWith<_AuthFormState> get copyWith => __$AuthFormStateCopyWithImpl<_AuthFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage);

@override
String toString() {
  return 'AuthFormState(status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AuthFormStateCopyWith<$Res> implements $AuthFormStateCopyWith<$Res> {
  factory _$AuthFormStateCopyWith(_AuthFormState value, $Res Function(_AuthFormState) _then) = __$AuthFormStateCopyWithImpl;
@override @useResult
$Res call({
 AuthFormStatus status, String? errorMessage
});




}
/// @nodoc
class __$AuthFormStateCopyWithImpl<$Res>
    implements _$AuthFormStateCopyWith<$Res> {
  __$AuthFormStateCopyWithImpl(this._self, this._then);

  final _AuthFormState _self;
  final $Res Function(_AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_AuthFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AuthFormStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
