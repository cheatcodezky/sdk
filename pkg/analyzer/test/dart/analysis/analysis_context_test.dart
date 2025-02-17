// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../src/dart/resolution/context_collection_resolution.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AnalysisContextTest);
  });
}

@reflectiveTest
class AnalysisContextTest extends PubPackageResolutionTest {
  test_changeFile_imported() async {
    var a = newFile2('$testPackageLibPath/a.dart', '');

    var b = newFile2('$testPackageLibPath/b.dart', r'''
import 'a.dart';
''');

    var c = newFile2('$testPackageLibPath/c.dart', '');

    var analysisContext = contextFor(a.path);

    // Ask for files, so that they are known.
    var analysisSession = analysisContext.currentSession;
    await analysisSession.getFile2(a.path);
    await analysisSession.getFile2(b.path);
    await analysisSession.getFile2(c.path);

    analysisContext.changeFile(a.path);

    var affected = await analysisContext.applyPendingFileChanges();
    expect(affected, unorderedEquals([a.path, b.path]));

    expect(analysisContext.currentSession, isNot(analysisSession));
  }

  test_changeFile_part() async {
    var a = newFile2('$testPackageLibPath/a.dart', r'''
part 'b.dart';
''');

    var b = newFile2('$testPackageLibPath/b.dart', r'''
part of 'a.dart';
''');

    var c = newFile2('$testPackageLibPath/c.dart', r'''
import 'a.dart';
''');

    var d = newFile2('$testPackageLibPath/d.dart', '');

    var analysisContext = contextFor(a.path);

    // Ask for files, so that they are known.
    var analysisSession = analysisContext.currentSession;
    await analysisSession.getFile2(a.path);
    await analysisSession.getFile2(b.path);
    await analysisSession.getFile2(c.path);
    await analysisSession.getFile2(d.path);

    analysisContext.changeFile(b.path);

    var affected = await analysisContext.applyPendingFileChanges();
    expect(affected, unorderedEquals([a.path, b.path, c.path]));

    expect(analysisContext.currentSession, isNot(analysisSession));
  }
}
