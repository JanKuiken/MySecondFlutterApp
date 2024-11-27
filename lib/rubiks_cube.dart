//
// A few classes to keep the state of a Rubiks cube and provide data
// to display it on a 2D medium.
//

import 'dart:math';
import 'point3d.dart';

enum RubiksColor { none, blue, green, white, yellow, red, orange }

enum RubiksAxis { x, y, z }

typedef FaceKey = (Point3D, RubiksAxis); // record to identify a face

// helper functions to make the Rubiks axis cyclical
RubiksAxis nextRubiksAxis(RubiksAxis axis) {
  switch (axis) {
    case RubiksAxis.x:
      return RubiksAxis.y;
    case RubiksAxis.y:
      return RubiksAxis.z;
    case RubiksAxis.z:
      return RubiksAxis.x;
  }
}

RubiksAxis prevRubiksAxis(RubiksAxis axis) {
  switch (axis) {
    case RubiksAxis.x:
      return RubiksAxis.z;
    case RubiksAxis.y:
      return RubiksAxis.x;
    case RubiksAxis.z:
      return RubiksAxis.y;
  }
}

RubiksAxis otherAxis(RubiksAxis axis1, RubiksAxis axis2) {
  if ((axis1 == RubiksAxis.x && axis2 == RubiksAxis.y) ||
      (axis1 == RubiksAxis.y && axis2 == RubiksAxis.x)) {
    return RubiksAxis.z;
  }
  if ((axis1 == RubiksAxis.y && axis2 == RubiksAxis.z) ||
      (axis1 == RubiksAxis.z && axis2 == RubiksAxis.y)) {
    return RubiksAxis.x;
  }
  if ((axis1 == RubiksAxis.z && axis2 == RubiksAxis.x) ||
      (axis1 == RubiksAxis.x && axis2 == RubiksAxis.z)) {
    return RubiksAxis.y;
  }
  return RubiksAxis.x; // should not happen
}

int valueInDirection(Point3Dint point, RubiksAxis axis) {
  return (axis == RubiksAxis.x)
      ? point.ix
      : ((axis == RubiksAxis.y) ? point.iy : point.iz);
}

// helper function to convert a RubiksAxis to a Point3D vector
Point3D RubiksAxis2Point3D(RubiksAxis axis) {
  switch (axis) {
    case RubiksAxis.x:
      return Point3D(1.0, 0.0, 0.0);
    case RubiksAxis.y:
      return Point3D(0.0, 1.0, 0.0);
    case RubiksAxis.z:
      return Point3D(0.0, 0.0, 1.0);
  }
}

class RubiksFace {
  // class (static) members

  //  how much smaller the visible part of faces is than the whole cubelet
  static const double offset = 0.06; // 0.15;

  // defines the colors in a 'solved state'
  static const color_map = {
    (RubiksAxis.x, -1): RubiksColor.green,
    (RubiksAxis.x, 1): RubiksColor.blue,
    (RubiksAxis.y, -1): RubiksColor.yellow,
    (RubiksAxis.y, 1): RubiksColor.white,
    (RubiksAxis.z, -1): RubiksColor.orange,
    (RubiksAxis.z, 1): RubiksColor.red,
  };

  static Matrix3x3 cubeRotationMatrix = Matrix3x3.ones();
  static Matrix3x3 displayMatrix = Matrix3x3.ones();

  // instance members

  // my_key kan vervangen worden door het volgende
  // later nog ff kijken of we dit dartonic kunnen maken:
  final Point3Dint position;
  final RubiksAxis direction;

  List<Point3D> points = []; // fixed starting points
  List<Point3D> dpoints = []; // display points
  RubiksColor color = RubiksColor.none;

  RubiksColor nextColor = RubiksColor.none; // temp. value during swap operation

  Matrix3x3 layerRotationMatrix = Matrix3x3.ones();

  // constructor
  RubiksFace(this.position, this.direction) {
    // create the four points of the visible face,
    //        the fifth point is the centre,
    //        the sixt point is the vector from the origin in the outbound direction of the face.
    //        the seventh to tenth are used for touch detection , same as the first four without the offset
    switch (direction) {
      case RubiksAxis.x:
        var x = 1.5 * position.ix;
        var y = -0.5 + position.iy;
        var z = -0.5 + position.iz;

        points.add(Point3D(x, y + offset, z + offset));
        points.add(Point3D(x, y + 1 - offset, z + offset));
        points.add(Point3D(x, y + 1 - offset, z + 1 - offset));
        points.add(Point3D(x, y + offset, z + 1 - offset));

        points.add(Point3D(
            (points[0].x + points[2].x) / 2.0,
            (points[0].y + points[2].y) / 2.0,
            (points[0].z + points[2].z) / 2.0));
        points.add(Point3D(x.sign, 0, 0));

        points.add(Point3D(x, y, z));
        points.add(Point3D(x, y + 1, z));
        points.add(Point3D(x, y + 1, z + 1));
        points.add(Point3D(x, y, z + 1));

        color = color_map[(direction, position.ix)] ?? RubiksColor.none;

      case RubiksAxis.y:
        var x = -0.5 + position.ix;
        var y = 1.5 * position.iy;
        var z = -0.5 + position.iz;

        points.add(Point3D(x + offset, y, z + offset));
        points.add(Point3D(x + 1 - offset, y, z + offset));
        points.add(Point3D(x + 1 - offset, y, z + 1 - offset));
        points.add(Point3D(x + offset, y, z + 1 - offset));

        points.add(Point3D(
            (points[0].x + points[2].x) / 2.0,
            (points[0].y + points[2].y) / 2.0,
            (points[0].z + points[2].z) / 2.0));
        points.add(Point3D(0, y.sign, 0));

        points.add(Point3D(x, y, z));
        points.add(Point3D(x + 1, y, z));
        points.add(Point3D(x + 1, y, z + 1));
        points.add(Point3D(x, y, z + 1));

        color = color_map[(direction, position.iy)] ?? RubiksColor.none;

      case RubiksAxis.z:
        var x = -0.5 + position.ix;
        var y = -0.5 + position.iy;
        var z = 1.5 * position.iz;

        points.add(Point3D(x + offset, y + offset, z));
        points.add(Point3D(x + 1 - offset, y + offset, z));
        points.add(Point3D(x + 1 - offset, y + 1 - offset, z));
        points.add(Point3D(x + offset, y + 1 - offset, z));

        points.add(Point3D(
            (points[0].x + points[2].x) / 2.0,
            (points[0].y + points[2].y) / 2.0,
            (points[0].z + points[2].z) / 2.0));
        points.add(Point3D(0, 0, z.sign));

        points.add(Point3D(x, y, z));
        points.add(Point3D(x + 1, y, z));
        points.add(Point3D(x + 1, y + 1, z));
        points.add(Point3D(x, y + 1, z));

        color = color_map[(direction, position.iz)] ?? RubiksColor.none;
    }
    //print(this);  // debugging purposes
  }

  update_display_points() {
    var m1 = RubiksFace.cubeRotationMatrix;
    var m2 = RubiksFace.displayMatrix;
    var m3 = layerRotationMatrix;
    var m = m1.dot(m2.dot(m3));
    dpoints = points.map((p) => m * p).toList();
  }

  (Point3Dint, RubiksAxis) prev_position(RubiksAxis axis, double angle) {
    Matrix3x3int m;
    RubiksAxis prevDir = direction;
    switch (axis) {
      case RubiksAxis.x:
        m = (angle > 0.0) ? Matrix3x3int.rotXneg() : Matrix3x3int.rotXpos();
      case RubiksAxis.y:
        m = (angle > 0.0) ? Matrix3x3int.rotYneg() : Matrix3x3int.rotYpos();
      case RubiksAxis.z:
        m = (angle > 0.0) ? Matrix3x3int.rotZneg() : Matrix3x3int.rotZpos();
    }
    if (axis != direction) {
      prevDir = otherAxis(axis, direction);
    }
    Point3Dint prevPoint = m * position;
    return (prevPoint, prevDir);
  }

  String toString() {
    return position.toString() +
        '\n' +
        direction.toString() +
        '\n' +
        color.toString();
  }
}

class RubiksCube {
  // class data
  var faces = Map<(int, int, int, RubiksAxis), RubiksFace>();

  // Constructor
  RubiksCube() {
    reset();
  }

  reset() {
    print('RubiksCube constructor called...');

    // var m1 = Matrix3x3.rotateX(deg2rad(rotX));  //  30.0
    // var m2 = Matrix3x3.rotateY(deg2rad(rotY));  // -30.0
    // RubiksFace.displayMatrix = m1.dot(m2);

    var m1 = Matrix3x3.rotateX(deg2rad(30.0));
    var m2 = Matrix3x3.rotateY(deg2rad(-30.0));
    RubiksFace.displayMatrix = m1.dot(m2);
    RubiksFace.cubeRotationMatrix = Matrix3x3.ones();

    for (var ix in [-1, 0, 1]) {
      for (var iy in [-1, 0, 1]) {
        for (var iz in [-1, 0, 1]) {
          for (RubiksAxis axis in RubiksAxis.values) {
            if ((axis == RubiksAxis.x &&
                    ix != 0) // exclude the centre-centre-centre
                ||
                (axis == RubiksAxis.y && iy != 0) // or core point
                ||
                (axis == RubiksAxis.z && iz != 0)) {
              // create stuff
              RubiksFace face = RubiksFace(Point3Dint(ix, iy, iz), axis);
              // store the stuff
              faces[(ix, iy, iz, axis)] = face;
            }
          }
        }
      }
    }
  }

  (RubiksAxis, double) whatsUp(Point3D s) {
    // return rubiks-axis and direction from "3d screen axis coordinates" ??
    Matrix3x3 inverse = RubiksFace.displayMatrix.transpose();
    Point3D p = inverse * s;
    return (p.x.abs() > p.y.abs() && p.x.abs() > p.y.abs())
        ? (RubiksAxis.x, p.x.sign)
        : (p.y.abs() > p.x.abs() && p.y.abs() > p.z.abs())
            ? (RubiksAxis.y, p.y.sign)
            : (RubiksAxis.z, p.z.sign);
  }

  updateRotationMatrixTemp(double deltaRotX, double deltaRotY) {
    // double rx = deg2rad(deltaRotX);
    // double ry = deg2rad(deltaRotX);

    // Matrix3x3 dus = Matrix3x3(rx, 0.0, 0.0, 0.0, ry, 0.0, 0.0, 0.0, 0.0);

    // RubiksFace.cubeRotationMatrix =
    //     RubiksFace.displayMatrix.transpose().dot(dus);

    // var (axis1, sign1) = whatsUp(Point3D(0.0, 1.0, 0.0));
    // var (axis2, sign2) = whatsUp(Point3D(1.0, 0.0, 0.0));

    // print(RubiksFace.color_map[(axis1, sign1.toInt())]);
    // print(RubiksFace.color_map[(axis2, sign2.toInt())]);

    // Matrix3x3 m1 = (axis1 == RubiksAxis.x)
    //     ? Matrix3x3.rotateX(deg2rad(sign1 * deltaRotX))
    //     : (axis1 == RubiksAxis.y)
    //         ? Matrix3x3.rotateY(deg2rad(sign1 * deltaRotX))
    //         : Matrix3x3.rotateZ(deg2rad(sign1 * deltaRotX));

    // Matrix3x3 m2 = (axis2 == RubiksAxis.x)
    //     ? Matrix3x3.rotateX(deg2rad(sign2 * deltaRotY))
    //     : (axis1 == RubiksAxis.y)
    //         ? Matrix3x3.rotateY(deg2rad(sign2 * deltaRotY))
    //         : Matrix3x3.rotateZ(deg2rad(sign2 * deltaRotY));

    // RubiksFace.cubeRotationMatrix = m2.dot(m1);

    var m1 = Matrix3x3.rotateX(deg2rad(deltaRotY));
    var m2 = Matrix3x3.rotateY(deg2rad(-deltaRotY));
    RubiksFace.cubeRotationMatrix = m1.dot(m2);
  }

  updateDisplayMatrix() {
    var m1 = RubiksFace.cubeRotationMatrix;
    var m2 = RubiksFace.displayMatrix;
    RubiksFace.displayMatrix = m1.dot(m2);
    RubiksFace.cubeRotationMatrix = Matrix3x3.ones();
  }

  animateRotate(RubiksAxis axis, int layer, double angle /* degrees*/) {
    Matrix3x3 m;

    switch (axis) {
      case RubiksAxis.x:
        m = Matrix3x3.rotateX(deg2rad(angle));
      case RubiksAxis.y:
        m = Matrix3x3.rotateY(deg2rad(angle));
      case RubiksAxis.z:
        m = Matrix3x3.rotateZ(deg2rad(angle));
    }
    ;

    faces.values.forEach((v) {
      if ((axis == RubiksAxis.x && layer == v.position.ix) ||
          (axis == RubiksAxis.y && layer == v.position.iy) ||
          (axis == RubiksAxis.z && layer == v.position.iz)) {
        v.layerRotationMatrix = m;
      } else {
        v.layerRotationMatrix = Matrix3x3.ones();
      }
    });

    faces.values.forEach((v) => v.update_display_points());
  }

  resetRotate() {
    // reset face rotations
    faces.values.forEach((v) {
      v.layerRotationMatrix = Matrix3x3.ones();
    });
  }

  finishRotate(RubiksAxis axis, int layer, double angle /* degrees*/) {
    // set next_RubiksColor of all faces to its current RubiksColor
    faces.values.forEach((v) => v.nextColor = v.color);

    // reset face rotations
    faces.values.forEach((v) {
      if ((axis == RubiksAxis.x && layer == v.position.ix) ||
          (axis == RubiksAxis.y && layer == v.position.iy) ||
          (axis == RubiksAxis.z && layer == v.position.iz)) {
        var (point, dir) = v.prev_position(axis, angle);
        print(point.toString() + ' ' + dir.toString());
        RubiksFace? face = faces[(point.ix, point.iy, point.iz, dir)];
        print(face);
        if (face != null) {
          print('dus 2');
          v.nextColor = face.color;
        }
      }
    });

    // set RubiksColor of all faces to its possible changed next_RubiksColor
    faces.values.forEach((v) => v.color = v.nextColor);
  }

  /// Produce a abstract ASCII art of the cube
  String ascii_art() {
    int N_lines = 40;
    int N_chars = N_lines * 2 + 10;
    String line = ' ' * N_chars;
    List<String> lines = List.filled(N_lines, line);

    const color_to_char_small = {
      RubiksColor.green: 'g',
      RubiksColor.blue: 'b',
      RubiksColor.yellow: 'y',
      RubiksColor.white: 'w',
      RubiksColor.red: 'r',
      RubiksColor.orange: 'o',
    };
    const color_to_char_big = {
      RubiksColor.green: 'G',
      RubiksColor.blue: 'B',
      RubiksColor.yellow: 'Y',
      RubiksColor.white: 'W',
      RubiksColor.red: 'R',
      RubiksColor.orange: 'O',
    };

    // van/naar internet (https://stackoverflow.com/questions/52083836/how-to-replace-only-one-character-in-a-string-in-dart)
    String replaceCharsAt(String oldString, int index, String newstring) {
      return oldString.substring(0, index) +
          newstring +
          oldString.substring(index + newstring.length);
    }

    void set_pixel(double x, double y, RubiksColor color, bool zdir) {
      int px = (N_chars / 2 + x * 14.0 + 0.5).floor();
      int py = (N_lines / 2 - y * 7.0 + 0.5).floor();
      String pixel = zdir ? color_to_char_big[color] ?? '=' : ' ';
      lines[py] = replaceCharsAt(lines[py], px, pixel);
    }

    // update the diplay position for each face
    faces.values.forEach((v) => v.update_display_points());

    // created a sorted list on coordinate of centre of face
    List<RubiksFace> faces_list = faces.values.toList();
    faces_list.sort((a, b) => a.dpoints[4].z.compareTo(b.dpoints[4].z));

    void update_ascii_art(RubiksFace v) {
      double px, py;
      for (int ix = 0; ix <= 10; ix++) {
        for (int iy = 0; iy <= 10; iy++) {
          px = v.dpoints[0].x +
              ix * (v.dpoints[1].x - v.dpoints[0].x) / 10.0 +
              iy * (v.dpoints[3].x - v.dpoints[0].x) / 10.0;
          py = v.dpoints[0].y +
              ix * (v.dpoints[1].y - v.dpoints[0].y) / 10.0 +
              iy * (v.dpoints[3].y - v.dpoints[0].y) / 10.0;

          set_pixel(px, py, v.color, v.dpoints[5].z > 0.0001);
          //true);
        }
      }
    }

    faces_list.forEach((v) => update_ascii_art(v));

    return lines.join("\n");
  }
}
