// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/sort_members.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../abstract_single_unit.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SortMembersTest);
  });
}

@reflectiveTest
class SortMembersTest extends AbstractSingleUnitTest {
  LineInfo? lineInfo;

  Future<void> test_class_accessor() async {
    await _parseTestUnit(r'''
class A {
  set c(x) {}
  set a(x) {}
  get a => null;
  get b => null;
  set b(x) {}
  get c => null;
}
''');
    // validate change
    _assertSort(r'''
class A {
  get a => null;
  set a(x) {}
  get b => null;
  set b(x) {}
  get c => null;
  set c(x) {}
}
''');
  }

  Future<void> test_class_accessor_static() async {
    await _parseTestUnit(r'''
class A {
  get a => null;
  set a(x) {}
  static get b => null;
  static set b(x) {}
}
''');
    // validate change
    _assertSort(r'''
class A {
  static get b => null;
  static set b(x) {}
  get a => null;
  set a(x) {}
}
''');
  }

  Future<void> test_class_constructor() async {
    await _parseTestUnit(r'''
class A {
  A.c() {   }
  A.a() { }
  A() {}
  A.b();
}
''');
    // validate change
    _assertSort(r'''
class A {
  A() {}
  A.a() { }
  A.b();
  A.c() {   }
}
''');
  }

  Future<void> test_class_external_constructorMethod() async {
    await _parseTestUnit(r'''
class Chart {
  external Pie();
  external Chart();
}
''');
    // validate change
    _assertSort(r'''
class Chart {
  external Chart();
  external Pie();
}
''');
  }

  Future<void> test_class_field() async {
    await _parseTestUnit(r'''
class A {
  String c;
  int a;
  void toString() => null;
  double b;
}
''');
    // validate change
    _assertSort(r'''
class A {
  String c;
  int a;
  double b;
  void toString() => null;
}
''');
  }

  Future<void> test_class_field_static() async {
    await _parseTestUnit(r'''
class A {
  int b;
  int a;
  static int d;
  static int c;
}
''');
    // validate change
    _assertSort(r'''
class A {
  static int d;
  static int c;
  int b;
  int a;
}
''');
  }

  Future<void> test_class_method() async {
    await _parseTestUnit(r'''
class A {
  c() {}
  a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
class A {
  a() {}
  b() {}
  c() {}
}
''');
  }

  Future<void> test_class_method_emptyLine() async {
    await _parseTestUnit(r'''
class A {
  b() {}

  a() {}
}
''');
    // validate change
    _assertSort(r'''
class A {
  a() {}

  b() {}
}
''');
  }

  Future<void> test_class_method_ignoreCase() async {
    await _parseTestUnit(r'''
class A {
  m_C() {}
  m_a() {}
  m_B() {}
}
''');
    // validate change
    _assertSort(r'''
class A {
  m_a() {}
  m_B() {}
  m_C() {}
}
''');
  }

  Future<void> test_class_method_static() async {
    await _parseTestUnit(r'''
class A {
  static a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
class A {
  b() {}
  static a() {}
}
''');
  }

  Future<void> test_class_mix() async {
    await _parseTestUnit(r'''
class A {
  /// static field public
  static int nnn;
  /// static field private
  static int _nnn;
  /// instance getter public
  int get nnn => null;
  /// instance setter public
  set nnn(x) {}
  /// instance getter private
  int get _nnn => null;
  /// instance setter private
  set _nnn(x) {}
  /// instance method public
  nnn() {}
  /// instance method private
  _nnn() {}
  /// static method public
  static nnn() {}
  /// static method private
  static _nnn() {}
  /// static getter public
  static int get nnn => null;
  /// static setter public
  static set nnn(x) {}
  /// static getter private
  static int get _nnn => null;
  /// static setter private
  static set _nnn(x) {}
  /// instance field public
  int nnn;
  /// instance field private
  int _nnn;
  /// constructor generative unnamed
  A();
  /// constructor factory unnamed
  factory A() => A();
  /// constructor generative public
  A.nnn();
  /// constructor factory public
  factory A.ooo() => A();
  /// constructor generative private
  A._nnn();
  /// constructor factory private
  factory A._ooo() => A();
}
''');
    // validate change
    _assertSort(r'''
class A {
  /// static field public
  static int nnn;
  /// static field private
  static int _nnn;
  /// static getter public
  static int get nnn => null;
  /// static setter public
  static set nnn(x) {}
  /// static getter private
  static int get _nnn => null;
  /// static setter private
  static set _nnn(x) {}
  /// instance field public
  int nnn;
  /// instance field private
  int _nnn;
  /// constructor generative unnamed
  A();
  /// constructor factory unnamed
  factory A() => A();
  /// constructor generative public
  A.nnn();
  /// constructor factory public
  factory A.ooo() => A();
  /// constructor generative private
  A._nnn();
  /// constructor factory private
  factory A._ooo() => A();
  /// instance getter public
  int get nnn => null;
  /// instance setter public
  set nnn(x) {}
  /// instance getter private
  int get _nnn => null;
  /// instance setter private
  set _nnn(x) {}
  /// instance method public
  nnn() {}
  /// instance method private
  _nnn() {}
  /// static method public
  static nnn() {}
  /// static method private
  static _nnn() {}
}
''');
  }

  Future<void> test_class_trailingComments() async {
    await _parseTestUnit(r'''
class A { // classA
  // instanceA
  int instanceA; // instanceA
  // A()
  A(); // A()
  // staticA
  static int staticA; // staticA
  // static_b
  static int static_b; // static_b
}
''');
    // validate change
    _assertSort(r'''
class A { // classA
  // staticA
  static int staticA; // staticA
  // static_b
  static int static_b; // static_b
  // instanceA
  int instanceA; // instanceA
  // A()
  A(); // A()
}
''');
  }

  Future<void> test_directives() async {
    await _parseTestUnit(r'''
library lib;

export 'dart:bbb';
import 'dart:bbb';
export 'package:bbb/bbb.dart';
export 'http://bbb.com';
import 'bbb/bbb.dart';
export 'http://aaa.com';
import 'http://bbb.com';
export 'dart:aaa';
export 'package:aaa/aaa.dart';
import 'package:bbb/bbb.dart';
export 'aaa/aaa.dart';
export 'bbb/bbb.dart';
import 'dart:aaa';
import 'package:aaa/aaa.dart';
import 'aaa/aaa.dart';
import 'http://aaa.com';
part 'bbb/bbb.dart';
part 'aaa/aaa.dart';

main() {
}
''');
    // validate change
    _assertSort(r'''
library lib;

import 'dart:aaa';
import 'dart:bbb';

import 'package:aaa/aaa.dart';
import 'package:bbb/bbb.dart';

import 'http://aaa.com';
import 'http://bbb.com';

import 'aaa/aaa.dart';
import 'bbb/bbb.dart';

export 'dart:aaa';
export 'dart:bbb';

export 'package:aaa/aaa.dart';
export 'package:bbb/bbb.dart';

export 'http://aaa.com';
export 'http://bbb.com';

export 'aaa/aaa.dart';
export 'bbb/bbb.dart';

part 'aaa/aaa.dart';
part 'bbb/bbb.dart';

main() {
}
''');
  }

  Future<void> test_directives_docComment_hasLibrary_lines() async {
    await _parseTestUnit(r'''
/// Library documentation comment A.
/// Library documentation comment B.
library foo.bar;

/// bbb1
/// bbb2
/// bbb3
import 'b.dart';
/// aaa1
/// aaa2
import 'a.dart';
''');
    // validate change
    _assertSort(r'''
/// Library documentation comment A.
/// Library documentation comment B.
library foo.bar;

/// aaa1
/// aaa2
import 'a.dart';
/// bbb1
/// bbb2
/// bbb3
import 'b.dart';
''');
  }

  Future<void> test_directives_docComment_hasLibrary_stars() async {
    await _parseTestUnit(r'''
/**
 * Library documentation comment A.
 * Library documentation comment B.
 */
library foo.bar;

/**
 * bbb
 */
import 'b.dart';
/**
 * aaa
 * aaa
 */
import 'a.dart';
''');
    // validate change
    _assertSort(r'''
/**
 * Library documentation comment A.
 * Library documentation comment B.
 */
library foo.bar;

/**
 * aaa
 * aaa
 */
import 'a.dart';
/**
 * bbb
 */
import 'b.dart';
''');
  }

  Future<void> test_directives_docComment_noLibrary_lines() async {
    await _parseTestUnit(r'''
/// Library documentation comment A
/// Library documentation comment B
import 'b.dart';
/// aaa1
/// aaa2
import 'a.dart';
''');
    // validate change
    _assertSort(r'''
/// Library documentation comment A
/// Library documentation comment B
/// aaa1
/// aaa2
import 'a.dart';
import 'b.dart';
''');
  }

  Future<void> test_directives_docComment_noLibrary_stars() async {
    await _parseTestUnit(r'''
/**
 * Library documentation comment A.
 * Library documentation comment B.
 */
import 'b.dart';
/**
 * aaa
 * aaa
 */
import 'a.dart';
''');
    // validate change
    _assertSort(r'''
/**
 * Library documentation comment A.
 * Library documentation comment B.
 */
/**
 * aaa
 * aaa
 */
import 'a.dart';
import 'b.dart';
''');
  }

  Future<void> test_directives_imports_packageAndPath() async {
    await _parseTestUnit(r'''
library lib;

import 'package:product.ui.api.bbb/manager1.dart';
import 'package:product.ui.api/entity2.dart';
import 'package:product.ui/entity.dart';
import 'package:product.ui.api.aaa/manager2.dart';
import 'package:product.ui.api/entity1.dart';
import 'package:product2.client/entity.dart';
''');
    // validate change
    _assertSort(r'''
library lib;

import 'package:product.ui/entity.dart';
import 'package:product.ui.api/entity1.dart';
import 'package:product.ui.api/entity2.dart';
import 'package:product.ui.api.aaa/manager2.dart';
import 'package:product.ui.api.bbb/manager1.dart';
import 'package:product2.client/entity.dart';
''');
  }

  Future<void> test_directives_invalidUri_interpolation() async {
    await _parseTestUnit(r'''
library lib;

import 'dart:$bbb';
import 'dart:ccc';
import 'dart:aaa';
''');
    _assertSort(r'''
library lib;

import 'dart:aaa';
import 'dart:ccc';

import 'dart:$bbb';
''');
  }

  Future<void> test_directives_splits_comments() async {
    // Here, the comments "b" and "ccc1" will be part of the same list
    // of comments so need to be split.
    await _parseTestUnit(r'''
// copyright
import 'b.dart'; // b
// ccc1
// ccc2
import 'c.dart'; // c
// aaa1
// aaa2
import 'a.dart'; // a
''');

    _assertSort(r'''
// copyright
// aaa1
// aaa2
import 'a.dart'; // a
import 'b.dart'; // b
// ccc1
// ccc2
import 'c.dart'; // c
''');
  }

  Future<void> test_enum_accessor() async {
    await _parseTestUnit(r'''
enum E {
  v;
  set c(x) {}
  set a(x) {}
  get a => null;
  get b => null;
  set b(x) {}
  get c => null;
}
''');
    // validate change
    _assertSort(r'''
enum E {
  v;
  get a => null;
  set a(x) {}
  get b => null;
  set b(x) {}
  get c => null;
  set c(x) {}
}
''');
  }

  Future<void> test_enum_accessor_static() async {
    await _parseTestUnit(r'''
enum E {
  v;
  get a => null;
  set a(x) {}
  static get b => null;
  static set b(x) {}
}
''');
    // validate change
    _assertSort(r'''
enum E {
  v;
  static get b => null;
  static set b(x) {}
  get a => null;
  set a(x) {}
}
''');
  }

  Future<void> test_enum_field_static() async {
    await _parseTestUnit(r'''
enum E {
  v;
  int b;
  int a;
  static int d;
  static int c;
}
''');
    // validate change
    _assertSort(r'''
enum E {
  v;
  static int d;
  static int c;
  int b;
  int a;
}
''');
  }

  Future<void> test_enum_method() async {
    await _parseTestUnit(r'''
enum E {
  v;
  c() {}
  a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
enum E {
  v;
  a() {}
  b() {}
  c() {}
}
''');
  }

  Future<void> test_enum_method_emptyLine() async {
    await _parseTestUnit(r'''
enum E {
  v;

  b() {}

  a() {}
}
''');
    // validate change
    _assertSort(r'''
enum E {
  v;

  a() {}

  b() {}
}
''');
  }

  Future<void> test_enum_method_ignoreCase() async {
    await _parseTestUnit(r'''
enum E {
  v;
  m_C() {}
  m_a() {}
  m_B() {}
}
''');
    // validate change
    _assertSort(r'''
enum E {
  v;
  m_a() {}
  m_B() {}
  m_C() {}
}
''');
  }

  Future<void> test_enum_method_static() async {
    await _parseTestUnit(r'''
enum E {
  v;
  static a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
enum E {
  v;
  b() {}
  static a() {}
}
''');
  }

  Future<void> test_extension_accessor() async {
    await _parseTestUnit(r'''
extension E on int {
  set c(x) {}
  set a(x) {}
  get a => null;
  get b => null;
  set b(x) {}
  get c => null;
}
''');
    // validate change
    _assertSort(r'''
extension E on int {
  get a => null;
  set a(x) {}
  get b => null;
  set b(x) {}
  get c => null;
  set c(x) {}
}
''');
  }

  Future<void> test_extension_accessor_static() async {
    await _parseTestUnit(r'''
extension E on int {
  get a => null;
  set a(x) {}
  static get b => null;
  static set b(x) {}
}
''');
    // validate change
    _assertSort(r'''
extension E on int {
  static get b => null;
  static set b(x) {}
  get a => null;
  set a(x) {}
}
''');
  }

  Future<void> test_extension_field_static() async {
    await _parseTestUnit(r'''
extension E on int {
  int b;
  int a;
  static int d;
  static int c;
}
''');
    // validate change
    _assertSort(r'''
extension E on int {
  static int d;
  static int c;
  int b;
  int a;
}
''');
  }

  Future<void> test_extension_method() async {
    await _parseTestUnit(r'''
extension E on int {
  c() {}
  a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
extension E on int {
  a() {}
  b() {}
  c() {}
}
''');
  }

  Future<void> test_extension_method_emptyLine() async {
    await _parseTestUnit(r'''
extension E on int {
  b() {}

  a() {}
}
''');
    // validate change
    _assertSort(r'''
extension E on int {
  a() {}

  b() {}
}
''');
  }

  Future<void> test_extension_method_ignoreCase() async {
    await _parseTestUnit(r'''
extension E on int {
  m_C() {}
  m_a() {}
  m_B() {}
}
''');
    // validate change
    _assertSort(r'''
extension E on int {
  m_a() {}
  m_B() {}
  m_C() {}
}
''');
  }

  Future<void> test_extension_method_static() async {
    await _parseTestUnit(r'''
extension E on int {
  static a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
extension E on int {
  b() {}
  static a() {}
}
''');
  }

  Future<void> test_mixin_accessor() async {
    await _parseTestUnit(r'''
mixin M {
  set c(x) {}
  set a(x) {}
  get a => null;
  get b => null;
  set b(x) {}
  get c => null;
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  get a => null;
  set a(x) {}
  get b => null;
  set b(x) {}
  get c => null;
  set c(x) {}
}
''');
  }

  Future<void> test_mixin_accessor_static() async {
    await _parseTestUnit(r'''
mixin M {
  get a => null;
  set a(x) {}
  static get b => null;
  static set b(x) {}
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  static get b => null;
  static set b(x) {}
  get a => null;
  set a(x) {}
}
''');
  }

  Future<void> test_mixin_field() async {
    await _parseTestUnit(r'''
mixin M {
  String c;
  int a;
  void toString() => null;
  double b;
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  String c;
  int a;
  double b;
  void toString() => null;
}
''');
  }

  Future<void> test_mixin_field_static() async {
    await _parseTestUnit(r'''
mixin M {
  int b;
  int a;
  static int d;
  static int c;
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  static int d;
  static int c;
  int b;
  int a;
}
''');
  }

  Future<void> test_mixin_method() async {
    await _parseTestUnit(r'''
mixin M {
  c() {}
  a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  a() {}
  b() {}
  c() {}
}
''');
  }

  Future<void> test_mixin_method_emptyLine() async {
    await _parseTestUnit(r'''
mixin M {
  b() {}

  a() {}
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  a() {}

  b() {}
}
''');
  }

  Future<void> test_mixin_method_ignoreCase() async {
    await _parseTestUnit(r'''
mixin M {
  m_C() {}
  m_a() {}
  m_B() {}
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  m_a() {}
  m_B() {}
  m_C() {}
}
''');
  }

  Future<void> test_mixin_method_static() async {
    await _parseTestUnit(r'''
mixin M {
  static a() {}
  b() {}
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  b() {}
  static a() {}
}
''');
  }

  Future<void> test_mixin_mix() async {
    await _parseTestUnit(r'''
mixin M {
  /// static field public
  static int nnn;
  /// static field private
  static int _nnn;
  /// instance getter public
  int get nnn => null;
  /// instance setter public
  set nnn(x) {}
  /// instance getter private
  int get _nnn => null;
  /// instance setter private
  set _nnn(x) {}
  /// instance method public
  nnn() {}
  /// instance method private
  _nnn() {}
  /// static method public
  static nnn() {}
  /// static method private
  static _nnn() {}
  /// static getter public
  static int get nnn => null;
  /// static setter public
  static set nnn(x) {}
  /// static getter private
  static int get _nnn => null;
  /// static setter private
  static set _nnn(x) {}
  /// instance field public
  int nnn;
  /// instance field private
  int _nnn;
}
''');
    // validate change
    _assertSort(r'''
mixin M {
  /// static field public
  static int nnn;
  /// static field private
  static int _nnn;
  /// static getter public
  static int get nnn => null;
  /// static setter public
  static set nnn(x) {}
  /// static getter private
  static int get _nnn => null;
  /// static setter private
  static set _nnn(x) {}
  /// instance field public
  int nnn;
  /// instance field private
  int _nnn;
  /// instance getter public
  int get nnn => null;
  /// instance setter public
  set nnn(x) {}
  /// instance getter private
  int get _nnn => null;
  /// instance setter private
  set _nnn(x) {}
  /// instance method public
  nnn() {}
  /// instance method private
  _nnn() {}
  /// static method public
  static nnn() {}
  /// static method private
  static _nnn() {}
}
''');
  }

  Future<void> test_mixin_trailingComments() async {
    await _parseTestUnit(r'''
mixin M { // mixinM
  // instanceA
  int instanceA; // instanceA
  // foo()
  void foo() {} // foo()
  // staticA
  static int staticA; // staticA
  // static_b
  static int static_b; // static_b
}
''');
    // validate change
    _assertSort(r'''
mixin M { // mixinM
  // staticA
  static int staticA; // staticA
  // static_b
  static int static_b; // static_b
  // instanceA
  int instanceA; // instanceA
  // foo()
  void foo() {} // foo()
}
''');
  }

  Future<void> test_unit_class() async {
    await _parseTestUnit(r'''
class C {}
class A {}
class B {}
''');
    // validate change
    _assertSort(r'''
class A {}
class B {}
class C {}
''');
  }

  Future<void> test_unit_class_ignoreCase() async {
    await _parseTestUnit(r'''
class C {}
class a {}
class B {}
''');
    // validate change
    _assertSort(r'''
class a {}
class B {}
class C {}
''');
  }

  Future<void> test_unit_classTypeAlias() async {
    await _parseTestUnit(r'''
class M {}
class C = Object with M;
class A = Object with M;
class B = Object with M;
''');
    // validate change
    _assertSort(r'''
class A = Object with M;
class B = Object with M;
class C = Object with M;
class M {}
''');
  }

  Future<void> test_unit_directive_hasDirective() async {
    await _parseTestUnit(r'''
library lib;
class C {}
class A {}
class B {}
''');
    // validate change
    _assertSort(r'''
library lib;
class A {}
class B {}
class C {}
''');
  }

  Future<void> test_unit_directive_noDirective_hasComment_line() async {
    await _parseTestUnit(r'''
// Some comment

class B {}

class A {}
''');
    // validate change
    _assertSort(r'''
// Some comment

class A {}

class B {}
''');
  }

  Future<void> test_unit_directive_noDirective_noComment() async {
    await _parseTestUnit(r'''

class B {}

class A {}
''');
    // validate change
    _assertSort(r'''

class A {}

class B {}
''');
  }

  Future<void> test_unit_enum() async {
    await _parseTestUnit(r'''
enum C {x, y}
enum A {x, y}
enum B {x, y}
''');
    // validate change
    _assertSort(r'''
enum A {x, y}
enum B {x, y}
enum C {x, y}
''');
  }

  Future<void> test_unit_enumClass() async {
    await _parseTestUnit(r'''
enum C {x, y}
class A {}
class D {}
enum B {x, y}
''');
    // validate change
    _assertSort(r'''
class A {}
enum B {x, y}
enum C {x, y}
class D {}
''');
  }

  Future<void> test_unit_extensionClass() async {
    await _parseTestUnit(r'''
extension E on C {}
class C {}
''');
    // validate change
    _assertSort(r'''
class C {}
extension E on C {}
''');
  }

  Future<void> test_unit_extensions() async {
    await _parseTestUnit(r'''
extension E2 on String {}
extension on List {}
extension E1 on int {}
extension on bool {}
''');
    // validate change
    _assertSort(r'''
extension on List {}
extension on bool {}
extension E1 on int {}
extension E2 on String {}
''');
  }

  Future<void> test_unit_function() async {
    await _parseTestUnit(r'''
fc() {}
fa() {}
fb() {}
''');
    // validate change
    _assertSort(r'''
fa() {}
fb() {}
fc() {}
''');
  }

  Future<void> test_unit_functionTypeAlias() async {
    await _parseTestUnit(r'''
typedef FC();
typedef FA();
typedef FB();
''');
    // validate change
    _assertSort(r'''
typedef FA();
typedef FB();
typedef FC();
''');
  }

  Future<void> test_unit_genericTypeAlias() async {
    await _parseTestUnit(r'''
typedef FC = void Function();
typedef FA = void Function();
typedef FB = void Function();
''');
    // validate change
    _assertSort(r'''
typedef FA = void Function();
typedef FB = void Function();
typedef FC = void Function();
''');
  }

  Future<void> test_unit_importsAndDeclarations() async {
    await _parseTestUnit(r'''
import 'dart:a';
import 'package:b';

foo() {
}

f() => null;
''');
    // validate change
    _assertSort(r'''
import 'dart:a';

import 'package:b';

f() => null;

foo() {
}
''');
  }

  Future<void> test_unit_mainFirst() async {
    await _parseTestUnit(r'''
class C {}
aaa() {}
get bbb() {}
class A {}
main() {}
class B {}
''');
    // validate change
    _assertSort(r'''
main() {}
get bbb() {}
aaa() {}
class A {}
class B {}
class C {}
''');
  }

  Future<void> test_unit_mix() async {
    await _parseTestUnit(r'''
_mmm() {}
typedef nnn();
typedef GTAF3 = void Function();
typedef _GTAF2 = void Function();
_nnn() {}
typedef mmm();
typedef _nnn();
typedef _mmm();
class mmm {}
get _nnn => null;
class nnn {}
class _mmm {}
class _nnn {}
var mmm;
var nnn;
var _mmm;
var _nnn;
typedef GTAF1 = void Function();
set nnn(x) {}
get mmm => null;
set mmm(x) {}
get nnn => null;
get _mmm => null;
set _mmm(x) {}
set _nnn(x) {}
mmm() {}
nnn() {}
''');
    // validate change
    _assertSort(r'''
var mmm;
var nnn;
var _mmm;
var _nnn;
get mmm => null;
set mmm(x) {}
get nnn => null;
set nnn(x) {}
get _mmm => null;
set _mmm(x) {}
get _nnn => null;
set _nnn(x) {}
mmm() {}
nnn() {}
_mmm() {}
_nnn() {}
typedef GTAF1 = void Function();
typedef GTAF3 = void Function();
typedef _GTAF2 = void Function();
typedef mmm();
typedef nnn();
typedef _mmm();
typedef _nnn();
class mmm {}
class nnn {}
class _mmm {}
class _nnn {}
''');
  }

  Future<void> test_unit_mixin() async {
    await _parseTestUnit(r'''
mixin C {}
mixin A {}
mixin B {}
''');
    _assertSort(r'''
mixin A {}
mixin B {}
mixin C {}
''');
  }

  Future<void> test_unit_topLevelVariable() async {
    await _parseTestUnit(r'''
int c;
int a;
int b;
''');
    // validate change
    _assertSort(r'''
int a;
int b;
int c;
''');
  }

  Future<void> test_unit_topLevelVariable_withConst() async {
    await _parseTestUnit(r'''
int c;
int a;
const B = 2;
int b;
const A = 1;
''');
    // validate change
    _assertSort(r'''
const A = 1;
const B = 2;
int a;
int b;
int c;
''');
  }

  Future<void> test_unit_trailingComments() async {
    await _parseTestUnit(r'''
// Header
class B {} // B
// A
class A {} // A
// C
class C {} // C
// b
var b; // b
// a
var a; // a
// c
var c; // c
''');
    // validate change
    _assertSort(r'''
// Header
// a
var a; // a
// b
var b; // b
// c
var c; // c
// A
class A {} // A
class B {} // B
// C
class C {} // C
''');
  }

  void _assertSort(String expectedCode) {
    var sorter = MemberSorter(testCode, testUnit, lineInfo!);
    var edits = sorter.sort();
    var result = SourceEdit.applySequence(testCode, edits);
    expect(result, expectedCode);
  }

  Future<void> _parseTestUnit(String code) async {
    addTestSource(code);
    var result =
        await (await session).getParsedUnit2(testFile) as ParsedUnitResult;
    lineInfo = result.lineInfo;
    testUnit = result.unit;
  }
}
