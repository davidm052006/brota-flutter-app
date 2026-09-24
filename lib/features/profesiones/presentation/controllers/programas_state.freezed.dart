// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'programas_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProgramasState {

 ProgramasStatus get status; List<Programa> get programas; int get total; int get totalPages; int get page; String get search; String? get area; String? get modalidad; ProgramasStats? get stats; String? get errorMessage;
/// Create a copy of ProgramasState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgramasStateCopyWith<ProgramasState> get copyWith => _$ProgramasStateCopyWithImpl<ProgramasState>(this as ProgramasState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgramasState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.programas, programas)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.page, page) || other.page == page)&&(identical(other.search, search) || other.search == search)&&(identical(other.area, area) || other.area == area)&&(identical(other.modalidad, modalidad) || other.modalidad == modalidad)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(programas),total,totalPages,page,search,area,modalidad,stats,errorMessage);

@override
String toString() {
  return 'ProgramasState(status: $status, programas: $programas, total: $total, totalPages: $totalPages, page: $page, search: $search, area: $area, modalidad: $modalidad, stats: $stats, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProgramasStateCopyWith<$Res>  {
  factory $ProgramasStateCopyWith(ProgramasState value, $Res Function(ProgramasState) _then) = _$ProgramasStateCopyWithImpl;
@useResult
$Res call({
 ProgramasStatus status, List<Programa> programas, int total, int totalPages, int page, String search, String? area, String? modalidad, ProgramasStats? stats, String? errorMessage
});




}
/// @nodoc
class _$ProgramasStateCopyWithImpl<$Res>
    implements $ProgramasStateCopyWith<$Res> {
  _$ProgramasStateCopyWithImpl(this._self, this._then);

  final ProgramasState _self;
  final $Res Function(ProgramasState) _then;

/// Create a copy of ProgramasState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? programas = null,Object? total = null,Object? totalPages = null,Object? page = null,Object? search = null,Object? area = freezed,Object? modalidad = freezed,Object? stats = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProgramasStatus,programas: null == programas ? _self.programas : programas // ignore: cast_nullable_to_non_nullable
as List<Programa>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,modalidad: freezed == modalidad ? _self.modalidad : modalidad // ignore: cast_nullable_to_non_nullable
as String?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ProgramasStats?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgramasState].
extension ProgramasStatePatterns on ProgramasState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgramasState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgramasState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgramasState value)  $default,){
final _that = this;
switch (_that) {
case _ProgramasState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgramasState value)?  $default,){
final _that = this;
switch (_that) {
case _ProgramasState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProgramasStatus status,  List<Programa> programas,  int total,  int totalPages,  int page,  String search,  String? area,  String? modalidad,  ProgramasStats? stats,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgramasState() when $default != null:
return $default(_that.status,_that.programas,_that.total,_that.totalPages,_that.page,_that.search,_that.area,_that.modalidad,_that.stats,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProgramasStatus status,  List<Programa> programas,  int total,  int totalPages,  int page,  String search,  String? area,  String? modalidad,  ProgramasStats? stats,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ProgramasState():
return $default(_that.status,_that.programas,_that.total,_that.totalPages,_that.page,_that.search,_that.area,_that.modalidad,_that.stats,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProgramasStatus status,  List<Programa> programas,  int total,  int totalPages,  int page,  String search,  String? area,  String? modalidad,  ProgramasStats? stats,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ProgramasState() when $default != null:
return $default(_that.status,_that.programas,_that.total,_that.totalPages,_that.page,_that.search,_that.area,_that.modalidad,_that.stats,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ProgramasState implements ProgramasState {
  const _ProgramasState({this.status = ProgramasStatus.idle, final  List<Programa> programas = const [], this.total = 0, this.totalPages = 1, this.page = 1, this.search = '', this.area, this.modalidad, this.stats, this.errorMessage}): _programas = programas;
  

@override@JsonKey() final  ProgramasStatus status;
 final  List<Programa> _programas;
@override@JsonKey() List<Programa> get programas {
  if (_programas is EqualUnmodifiableListView) return _programas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_programas);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int totalPages;
@override@JsonKey() final  int page;
@override@JsonKey() final  String search;
@override final  String? area;
@override final  String? modalidad;
@override final  ProgramasStats? stats;
@override final  String? errorMessage;

/// Create a copy of ProgramasState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgramasStateCopyWith<_ProgramasState> get copyWith => __$ProgramasStateCopyWithImpl<_ProgramasState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgramasState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._programas, _programas)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.page, page) || other.page == page)&&(identical(other.search, search) || other.search == search)&&(identical(other.area, area) || other.area == area)&&(identical(other.modalidad, modalidad) || other.modalidad == modalidad)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_programas),total,totalPages,page,search,area,modalidad,stats,errorMessage);

@override
String toString() {
  return 'ProgramasState(status: $status, programas: $programas, total: $total, totalPages: $totalPages, page: $page, search: $search, area: $area, modalidad: $modalidad, stats: $stats, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ProgramasStateCopyWith<$Res> implements $ProgramasStateCopyWith<$Res> {
  factory _$ProgramasStateCopyWith(_ProgramasState value, $Res Function(_ProgramasState) _then) = __$ProgramasStateCopyWithImpl;
@override @useResult
$Res call({
 ProgramasStatus status, List<Programa> programas, int total, int totalPages, int page, String search, String? area, String? modalidad, ProgramasStats? stats, String? errorMessage
});




}
/// @nodoc
class __$ProgramasStateCopyWithImpl<$Res>
    implements _$ProgramasStateCopyWith<$Res> {
  __$ProgramasStateCopyWithImpl(this._self, this._then);

  final _ProgramasState _self;
  final $Res Function(_ProgramasState) _then;

/// Create a copy of ProgramasState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? programas = null,Object? total = null,Object? totalPages = null,Object? page = null,Object? search = null,Object? area = freezed,Object? modalidad = freezed,Object? stats = freezed,Object? errorMessage = freezed,}) {
  return _then(_ProgramasState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProgramasStatus,programas: null == programas ? _self._programas : programas // ignore: cast_nullable_to_non_nullable
as List<Programa>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,modalidad: freezed == modalidad ? _self.modalidad : modalidad // ignore: cast_nullable_to_non_nullable
as String?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ProgramasStats?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
