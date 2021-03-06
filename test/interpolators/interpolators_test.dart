/*
 * Copyright 2014 Google Inc. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file or at
 * https://developers.google.com/open-source/licenses/bsd
 */

library charted.test.interpolators;

import 'package:charted/core/core.dart';
import 'package:charted/interpolators/interpolators.dart';
import 'package:unittest/unittest.dart';

part 'easing_test.dart';

class MockObject {
  num a;
  List b;
  MockObject(this.a, this.b);
}

main() {
  testEasing();

  test('interpolateNumber correctly interpolates two [num]s', () {
    InterpolateFn interpolator = interpolateNumber(1, 10);
    expect(interpolator(0), equals(1));
    expect(interpolator(0.5), equals(5.5));
    expect(interpolator(1), equals(10));
  });

  test('interpolateRound correctly interpolates two [num]s', () {
    InterpolateFn interpolator = interpolateRound(0.8, 10.3);
    expect(interpolator(0), equals(1));
    expect(interpolator(0.5), equals(6));
    expect(interpolator(1), equals(10));
  });

  test('interpolateString correctly interpolates two [String]s', () {
    InterpolateFn interpolator =
        interpolateString('M1,2L2,2M5,3', 'M2,4L5,5M5,4');
    expect(interpolator(0), equals('M1,2L2,2M5,3'));
    expect(interpolator(0.5), equals('M1.5,3.0L3.5,3.5M5.0,3.5'));
    expect(interpolator(1), equals('M2,4L5,5M5,4'));
  });

  test('interpolateColor interpolates two [Color]s in RGB color system', () {
    InterpolateFn interpolator = interpolateColor(
        new Color.fromRgb(100, 0, 150), new Color.fromRgb(200, 150, 0));
    expect(interpolator(0).hexString, equals('#640096'));
    expect(interpolator(0.5).hexString, equals('#964b4b'));
    expect(interpolator(1).hexString, equals('#c89600'));
  });

  test('interpolateHsl interpolates two [Color]s in HSL color system', () {
    InterpolateFn interpolator = interpolateHsl(
        new Color.fromRgb(100, 0, 150), new Color.fromRgb(200, 150, 0));
    expect(interpolator(0), equals('#640096'));
    expect(interpolator(0.5), equals('#00af7c'));
    expect(interpolator(1), equals('#c89600'));
  });

  test('interpolateList correctly interpolates two [List]s', () {
    // Same number of elements in two lists
    InterpolateFn interpolator = interpolateList([1, 2, 3], [3, 10, 5]);
    expect(interpolator(0), orderedEquals([1, 2, 3]));
    expect(interpolator(0.5), orderedEquals([2, 6, 4]));
    expect(interpolator(1), orderedEquals([3, 10, 5]));
    // First list has more elements
    interpolator = interpolateList([1, 2, 3, 8], [3, 10, 5]);
    expect(interpolator(0), orderedEquals([1, 2, 3, 8]));
    expect(interpolator(0.5), orderedEquals([2, 6, 4, 8]));
    expect(interpolator(1), orderedEquals([3, 10, 5, 8]));
    // Second list has more elements
    interpolator = interpolateList([1, 2, 3], [3, 10, 5, 7]);
    expect(interpolator(0), orderedEquals([1, 2, 3, 7]));
    expect(interpolator(0.5), orderedEquals([2, 6, 4, 7]));
    expect(interpolator(1), orderedEquals([3, 10, 5, 7]));
  });

  test('interpolateMap correctly interpolates two [Map]s', () {
    // Same number of elements in two maps
    Map a = {'a': 1, 'b': 10, 'c': 3},
        b = {'a': 6, 'b': 2, 'c': 8};
    InterpolateFn interpolator = interpolateMap(a, b);
    (interpolator(0) as Map).forEach((k, v) => expect(v, equals(a[k])));
    (interpolator(0.5) as Map).forEach((k, v) =>
        expect(v, equals((a[k] + b[k]) / 2)));
    (interpolator(1) as Map).forEach((k, v) => expect(v, equals(b[k])));
    // First map has more elements
    a = {'a': 1, 'b': 10, 'c': 3, 'd': 5};
    interpolator = interpolateMap(a, b);
    (interpolator(0) as Map).forEach((k, v) => expect(v, equals(a[k])));
    (interpolator(0.5) as Map).forEach((k, v) =>
        expect(v, equals(b[k] == null ? a[k] : (a[k] + b[k]) / 2)));
    (interpolator(1) as Map).forEach((k, v) =>
        expect(v, equals(b[k] == null ? a[k] : b[k])));
    // Second map has more elements
    a = {'a': 1, 'b': 10, 'c': 3};
    b = {'a': 6, 'b': 2, 'c': 8, 'd': 10};
    interpolator = interpolateMap(a, b);
    (interpolator(0) as Map).forEach((k, v) =>
        expect(v, equals(a[k] == null ? b[k] : a[k])));
    (interpolator(0.5) as Map).forEach((k, v) =>
        expect(v, equals(a[k] == null ? b[k] : (a[k] + b[k]) / 2)));
    (interpolator(1) as Map).forEach((k, v) => expect(v, equals(b[k])));
  });

  test('uninterpolateNumber returns the reverse of interpolateNumber', () {
    InterpolateFn interpolator = uninterpolateNumber(1, 10);
    expect(interpolator(-3.5), equals(-0.5));
    expect(interpolator(1), equals(0));
    expect(interpolator(5.5), equals(0.5));
    expect(interpolator(10), equals(1));
  });

  test('uninterpolateClamp clamps uninterpolated result to [0, 1]', () {
    InterpolateFn interpolator = uninterpolateClamp(1, 10);
    expect(interpolator(-3.5), equals(0));
    expect(interpolator(1), equals(0));
    expect(interpolator(5.5), equals(0.5));
    expect(interpolator(10), equals(1));
    expect(interpolator(15), equals(1));
  });

  test('interpolateObject correctly interpolates two [Object]s', () {
    MockObject a = new MockObject(1, [3, 10, 4]),
               b = new MockObject(5, [9, 3, 1]);
    InterpolateFn interpolator = interpolateObject(a, b);
    MockObject c = interpolator(0);
    expect(c.a, equals(1));
    expect(c.b, orderedEquals([3, 10, 4]));
    a = new MockObject(1, [3, 10, 4]);
    interpolator = interpolateObject(a, b);
    c = interpolator(0.5);
    expect(c.a, equals(3));
    expect(c.b, orderedEquals([6, 6.5, 2.5]));
    a = new MockObject(1, [3, 10, 4]);
    interpolator = interpolateObject(a, b);
    c = interpolator(1);
    expect(c.a, equals(5));
    expect(c.b, orderedEquals([9, 3, 1]));
  });

  test('interpolateTransform correctly interpolates two transforms', () {
    // Both transform string contain complete information
    InterpolateFn interpolator =
        interpolateTransform("translate(10,10)rotate(30)skewX(0.5)scale(1,1)",
            "translate(100,100)rotate(360)skewX(45)scale(3,3)");

    expect(interpolator(0),
        equals('translate(10,10)scale(1,1)rotate(390)skewX(0.5)'));
    expect(interpolator(0.5),
        equals('translate(55.0,55.0)scale(2.0,2.0)rotate(375.0)skewX(22.75)'));
    expect(interpolator(1),
        equals('translate(100,100)scale(3,3)rotate(360)skewX(45.0)'));

    // The first transform string is empty
    interpolator = interpolateTransform("",
        "translate(100,100)rotate(360)skewX(45)scale(3,3)");
    expect(interpolator(0),
        equals('translate(0,0)scale(1,1)rotate(360)skewX(0)'));
    expect(interpolator(0.5),
        equals('translate(50.0,50.0)scale(2.0,2.0)rotate(360.0)skewX(22.5)'));
    expect(interpolator(1),
        equals('translate(100,100)scale(3,3)rotate(360)skewX(45)'));

    // Two transform strings are not complete
    interpolator = interpolateTransform("translate(10,10)rotate(30)scale(1,1)",
        "skewX(45)scale(3,3)");
    expect(interpolator(0),
        equals('translate(10,10)scale(1,1)rotate(30)skewX(0)'));
    expect(interpolator(0.5),
        equals('translate(5.0,5.0)scale(2.0,2.0)rotate(15.0)skewX(22.5)'));
    expect(interpolator(1),
        equals('translate(0,0)scale(3,3)rotate(0)skewX(45)'));
  });

  test('interpolateZoom correctly interpolates two [Zoom]s', () {
    // dr != 0
    InterpolateFn interpolator = interpolateZoom([3, 5, 2], [1, 10, 4]);

    List zoom = interpolator(0);
    expect(zoom[0], closeTo(3, EPSILON));
    expect(zoom[1], closeTo(5, EPSILON));
    expect(zoom[2], closeTo(2, EPSILON));

    zoom = interpolator(0.5);
    expect(zoom[0], closeTo(2.333333333333334, EPSILON));
    expect(zoom[1], closeTo(6.666666666666665, EPSILON));
    expect(zoom[2], closeTo(5.811865258054227, EPSILON));

    zoom = interpolator(1);
    expect(zoom[0], closeTo(1, EPSILON));
    expect(zoom[1], closeTo(10, EPSILON));
    expect(zoom[2], closeTo(4, EPSILON));

    // dr == 0
    interpolator = interpolateZoom([5, 10, 4], [5, 10, 4]);

    zoom = interpolator(0);
    expect(zoom[0], closeTo(5, EPSILON));
    expect(zoom[1], closeTo(10, EPSILON));
    expect(zoom[2], closeTo(4, EPSILON));

    zoom = interpolator(0.5);
    expect(zoom[0], closeTo(5, EPSILON));
    expect(zoom[1], closeTo(10, EPSILON));
    expect(zoom[2], closeTo(4, EPSILON));

    zoom = interpolator(1);
    expect(zoom[0], closeTo(5, EPSILON));
    expect(zoom[1], closeTo(10, EPSILON));
    expect(zoom[2], closeTo(4, EPSILON));
  });

  test('interpolatorByType returns a interpolator based on paramater type', () {
    InterpolateFn interpolator = interpolatorByType(1, 1);   // Num
    expect(interpolator(0), new isInstanceOf<num>());

    interpolator = interpolatorByType([1], [1]);             // List
    expect(interpolator(0), new isInstanceOf<List>());

    interpolator = interpolatorByType({'a': 1}, {'a': 1});   // List
    expect(interpolator(0), new isInstanceOf<Map>());

    interpolator = interpolatorByType('#ffffff', '#ffffff'); // Color
    expect(interpolator(0), new isInstanceOf<Color>());

    interpolator = interpolatorByType(new Color.fromColorString('#ffffff'),
        new Color.fromColorString('#ffffff'));
    expect(interpolator(0), new isInstanceOf<Color>());

    interpolator = interpolatorByType('M1,1', 'M1,1');       // String
    expect(interpolator(0), new isInstanceOf<String>());

    interpolator = interpolatorByType(
        new MockObject(0, []), new MockObject(0, []));       // Object
    expect(interpolator(0), new isInstanceOf<MockObject>());
  });
}
