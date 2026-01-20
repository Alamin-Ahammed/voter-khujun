// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VotersTable extends Voters with TableInfo<$VotersTable, Voter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VotersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fatherMeta = const VerificationMeta('father');
  @override
  late final GeneratedColumn<String> father = GeneratedColumn<String>(
      'father', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _motherMeta = const VerificationMeta('mother');
  @override
  late final GeneratedColumn<String> mother = GeneratedColumn<String>(
      'mother', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<String> dob = GeneratedColumn<String>(
      'dob', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wardMeta = const VerificationMeta('ward');
  @override
  late final GeneratedColumn<String> ward = GeneratedColumn<String>(
      'ward', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, father, mother, dob, ward, address];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voters';
  @override
  VerificationContext validateIntegrity(Insertable<Voter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('father')) {
      context.handle(_fatherMeta,
          father.isAcceptableOrUnknown(data['father']!, _fatherMeta));
    } else if (isInserting) {
      context.missing(_fatherMeta);
    }
    if (data.containsKey('mother')) {
      context.handle(_motherMeta,
          mother.isAcceptableOrUnknown(data['mother']!, _motherMeta));
    } else if (isInserting) {
      context.missing(_motherMeta);
    }
    if (data.containsKey('dob')) {
      context.handle(
          _dobMeta, dob.isAcceptableOrUnknown(data['dob']!, _dobMeta));
    } else if (isInserting) {
      context.missing(_dobMeta);
    }
    if (data.containsKey('ward')) {
      context.handle(
          _wardMeta, ward.isAcceptableOrUnknown(data['ward']!, _wardMeta));
    } else if (isInserting) {
      context.missing(_wardMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Voter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Voter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      father: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}father'])!,
      mother: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother'])!,
      dob: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dob'])!,
      ward: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ward'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
    );
  }

  @override
  $VotersTable createAlias(String alias) {
    return $VotersTable(attachedDatabase, alias);
  }
}

class Voter extends DataClass implements Insertable<Voter> {
  final int id;
  final String name;
  final String father;
  final String mother;
  final String dob;
  final String ward;
  final String address;
  const Voter(
      {required this.id,
      required this.name,
      required this.father,
      required this.mother,
      required this.dob,
      required this.ward,
      required this.address});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['father'] = Variable<String>(father);
    map['mother'] = Variable<String>(mother);
    map['dob'] = Variable<String>(dob);
    map['ward'] = Variable<String>(ward);
    map['address'] = Variable<String>(address);
    return map;
  }

  VotersCompanion toCompanion(bool nullToAbsent) {
    return VotersCompanion(
      id: Value(id),
      name: Value(name),
      father: Value(father),
      mother: Value(mother),
      dob: Value(dob),
      ward: Value(ward),
      address: Value(address),
    );
  }

  factory Voter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Voter(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      father: serializer.fromJson<String>(json['father']),
      mother: serializer.fromJson<String>(json['mother']),
      dob: serializer.fromJson<String>(json['dob']),
      ward: serializer.fromJson<String>(json['ward']),
      address: serializer.fromJson<String>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'father': serializer.toJson<String>(father),
      'mother': serializer.toJson<String>(mother),
      'dob': serializer.toJson<String>(dob),
      'ward': serializer.toJson<String>(ward),
      'address': serializer.toJson<String>(address),
    };
  }

  Voter copyWith(
          {int? id,
          String? name,
          String? father,
          String? mother,
          String? dob,
          String? ward,
          String? address}) =>
      Voter(
        id: id ?? this.id,
        name: name ?? this.name,
        father: father ?? this.father,
        mother: mother ?? this.mother,
        dob: dob ?? this.dob,
        ward: ward ?? this.ward,
        address: address ?? this.address,
      );
  Voter copyWithCompanion(VotersCompanion data) {
    return Voter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      father: data.father.present ? data.father.value : this.father,
      mother: data.mother.present ? data.mother.value : this.mother,
      dob: data.dob.present ? data.dob.value : this.dob,
      ward: data.ward.present ? data.ward.value : this.ward,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Voter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('father: $father, ')
          ..write('mother: $mother, ')
          ..write('dob: $dob, ')
          ..write('ward: $ward, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, father, mother, dob, ward, address);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Voter &&
          other.id == this.id &&
          other.name == this.name &&
          other.father == this.father &&
          other.mother == this.mother &&
          other.dob == this.dob &&
          other.ward == this.ward &&
          other.address == this.address);
}

class VotersCompanion extends UpdateCompanion<Voter> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> father;
  final Value<String> mother;
  final Value<String> dob;
  final Value<String> ward;
  final Value<String> address;
  const VotersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.father = const Value.absent(),
    this.mother = const Value.absent(),
    this.dob = const Value.absent(),
    this.ward = const Value.absent(),
    this.address = const Value.absent(),
  });
  VotersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String father,
    required String mother,
    required String dob,
    required String ward,
    required String address,
  })  : name = Value(name),
        father = Value(father),
        mother = Value(mother),
        dob = Value(dob),
        ward = Value(ward),
        address = Value(address);
  static Insertable<Voter> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? father,
    Expression<String>? mother,
    Expression<String>? dob,
    Expression<String>? ward,
    Expression<String>? address,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (father != null) 'father': father,
      if (mother != null) 'mother': mother,
      if (dob != null) 'dob': dob,
      if (ward != null) 'ward': ward,
      if (address != null) 'address': address,
    });
  }

  VotersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? father,
      Value<String>? mother,
      Value<String>? dob,
      Value<String>? ward,
      Value<String>? address}) {
    return VotersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      father: father ?? this.father,
      mother: mother ?? this.mother,
      dob: dob ?? this.dob,
      ward: ward ?? this.ward,
      address: address ?? this.address,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (father.present) {
      map['father'] = Variable<String>(father.value);
    }
    if (mother.present) {
      map['mother'] = Variable<String>(mother.value);
    }
    if (dob.present) {
      map['dob'] = Variable<String>(dob.value);
    }
    if (ward.present) {
      map['ward'] = Variable<String>(ward.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VotersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('father: $father, ')
          ..write('mother: $mother, ')
          ..write('dob: $dob, ')
          ..write('ward: $ward, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VotersTable voters = $VotersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [voters];
}

typedef $$VotersTableCreateCompanionBuilder = VotersCompanion Function({
  Value<int> id,
  required String name,
  required String father,
  required String mother,
  required String dob,
  required String ward,
  required String address,
});
typedef $$VotersTableUpdateCompanionBuilder = VotersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> father,
  Value<String> mother,
  Value<String> dob,
  Value<String> ward,
  Value<String> address,
});

class $$VotersTableFilterComposer
    extends Composer<_$AppDatabase, $VotersTable> {
  $$VotersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get father => $composableBuilder(
      column: $table.father, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mother => $composableBuilder(
      column: $table.mother, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ward => $composableBuilder(
      column: $table.ward, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));
}

class $$VotersTableOrderingComposer
    extends Composer<_$AppDatabase, $VotersTable> {
  $$VotersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get father => $composableBuilder(
      column: $table.father, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mother => $composableBuilder(
      column: $table.mother, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ward => $composableBuilder(
      column: $table.ward, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));
}

class $$VotersTableAnnotationComposer
    extends Composer<_$AppDatabase, $VotersTable> {
  $$VotersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get father =>
      $composableBuilder(column: $table.father, builder: (column) => column);

  GeneratedColumn<String> get mother =>
      $composableBuilder(column: $table.mother, builder: (column) => column);

  GeneratedColumn<String> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get ward =>
      $composableBuilder(column: $table.ward, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$VotersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VotersTable,
    Voter,
    $$VotersTableFilterComposer,
    $$VotersTableOrderingComposer,
    $$VotersTableAnnotationComposer,
    $$VotersTableCreateCompanionBuilder,
    $$VotersTableUpdateCompanionBuilder,
    (Voter, BaseReferences<_$AppDatabase, $VotersTable, Voter>),
    Voter,
    PrefetchHooks Function()> {
  $$VotersTableTableManager(_$AppDatabase db, $VotersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VotersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VotersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VotersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> father = const Value.absent(),
            Value<String> mother = const Value.absent(),
            Value<String> dob = const Value.absent(),
            Value<String> ward = const Value.absent(),
            Value<String> address = const Value.absent(),
          }) =>
              VotersCompanion(
            id: id,
            name: name,
            father: father,
            mother: mother,
            dob: dob,
            ward: ward,
            address: address,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String father,
            required String mother,
            required String dob,
            required String ward,
            required String address,
          }) =>
              VotersCompanion.insert(
            id: id,
            name: name,
            father: father,
            mother: mother,
            dob: dob,
            ward: ward,
            address: address,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VotersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VotersTable,
    Voter,
    $$VotersTableFilterComposer,
    $$VotersTableOrderingComposer,
    $$VotersTableAnnotationComposer,
    $$VotersTableCreateCompanionBuilder,
    $$VotersTableUpdateCompanionBuilder,
    (Voter, BaseReferences<_$AppDatabase, $VotersTable, Voter>),
    Voter,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VotersTableTableManager get voters =>
      $$VotersTableTableManager(_db, _db.voters);
}
