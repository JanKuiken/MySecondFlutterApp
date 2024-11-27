import 'package:flutter/material.dart';

import 'rubiks_cube.dart';
import 'point3d.dart';

// moet weg, double format functie
String bah(double f) {
  String s = f.toStringAsFixed(2);
  if (f >= 0.0) s = '+$s';
  return s;
}

// is hier geen Flutter/Dart versie van ???
Offset normalize(Offset offset) {
  double distance = offset.distance;
  if (distance > 0.1) {
    return offset / distance;
  } else {
    return Offset(0.0, 0.0);
  }
}

class FlutterCube extends RubiksCube {
  // Deze sub klasse breidt RubiksCube uit met wat spullen
  // die we nodig hebben voor onze Flutter App.
  // (RubiksCube kan ook gebruikt worden in dart-only apps)

  static RubiksFace nullFace = RubiksFace(Point3Dint(0, 0, 0), RubiksAxis.x);
  static Offset nullOffset =
      const Offset(42, 42); // non realistic offset (for this app)

  var clickPaths = <Path, RubiksFace>{}; // set and reset by CubePainter
  double size = 0.0; // reset by CubePainter

  bool showTwoColors = false;
  bool showBorders = true;
  bool showBackfaces = true;

  RubiksFace movingFace =
      nullFace; // not nullFace if a face is selected for moving
  Offset startPan = const Offset(0, 0); // valid if movingFace != nullFace

  Offset movingDisplayAxis = nullOffset; // not nullOffset if a face is moving
  RubiksAxis movingRubiksAxis =
      RubiksAxis.x; // valid if movingDisplayAxis != nullOffset
  double movingRubiksAngle = 0.0; // valid if movingDisplayAxis != nullOffset
  int movingRubiksLayer = 0; // valid if movingDisplayAxis != nullOffset

  // double deltaRotX = 0.0;
  // double deltaRotY = 0.0;
  bool freeRotate = false;
  bool freeRotateUsesX = false;

  double lastDistance = 0.0;

  FlutterCube() : super() {
    print('FlutterCube constructor');
  }
}

class CubePainter extends CustomPainter {
  static const colorMap = {
    // colors from https://en.wikipedia.org/wiki/Rubik's_Cube#/media/File:Rubik's_cube_colors.svg
    // i might add some transparancy
    RubiksColor.green: Color(0xff009b48),
    RubiksColor.blue: Color(0xff0046ad),
    RubiksColor.yellow: Color(0xffffd500),
    RubiksColor.white: Color(0xffffffff),
    RubiksColor.orange: Color(0xffff5800),
    RubiksColor.red: Color(0xffb71234),
  };

  static const twoColorMap = {
    RubiksColor.green: Color(0xffffffff),
    RubiksColor.blue: Color(0xff0046ad),
    RubiksColor.yellow: Color(0xff0046ad),
    RubiksColor.white: Color(0xff0046ad),
    RubiksColor.orange: Color(0xffffffff),
    RubiksColor.red: Color(0xffffffff),
  };

  bool done = false;

  final FlutterCube _cube;

  CubePainter(FlutterCube cube) : _cube = cube {
    //print('CubePainter constructor');
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) =>
      this == oldDelegate; // ???

  @override
  void paint(Canvas canvas, Size size) {
    done = false;

    _cube.size = size.width; // onze widget is vierkant

    canvas.translate(_cube.size / 2.0, _cube.size / 2.0);
    canvas.scale(_cube.size / 5.0, -_cube.size / 5.0);

    _cube.clickPaths.clear();
    //_cube.animate_rotate(Layer.z0, 180.0);

    // created a sorted list on coordinate of centre of face
    List<RubiksFace> faces_list = _cube.faces.values.toList();
    faces_list.forEach((v) => v.update_display_points());
    faces_list.sort((a, b) => (a.dpoints[4].z).compareTo(b.dpoints[4].z));

    faces_list.forEach((v) {
      Paint paint = Paint();
      paint.color =
          (_cube.showTwoColors ? twoColorMap[v.color] : colorMap[v.color]) ??
              Colors.black; // nullable shit.

      if (v.dpoints[5].z < 0) {
        //paint.color = Color(0xff444444);
        //paint.color = paint.color[200];
        //const amount = 0.2;
        //final hsl = HSLColor.fromColor(paint.color);
        //final hslDark = hsl.withLightness((hsl.lightness * amount + .1).clamp(0.0, 1.0));
        //final hslDark = hsl.withLightness(0.15);
        //paint.color = hslDark.toColor();

        //paint.color = const Color.fromARGB(255, 24, 24, 24);
        paint.color = paint.color.withOpacity(0.5);
      }

      Paint paintBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.02
        ..color = const Color(0x88000000);

      final path = Path();
      path.moveTo(v.dpoints[0].x, v.dpoints[0].y);
      path.lineTo(v.dpoints[1].x, v.dpoints[1].y);
      path.lineTo(v.dpoints[2].x, v.dpoints[2].y);
      path.lineTo(v.dpoints[3].x, v.dpoints[3].y);
      path.lineTo(v.dpoints[0].x, v.dpoints[0].y);
      if (v.dpoints[5].z >= 0 || _cube.showBackfaces) {
        canvas.drawPath(path, paint);
        if (_cube.showBorders) {
          canvas.drawPath(path, paintBorder);
        }
      }

      path.close();

      // if (_cube.movingDisplayAxis != FlutterCube.nullOffset &&
      //     _cube.movingFace== v)  {
      //   Paint paintBorder = Paint()
      //     ..style = PaintingStyle.stroke
      //     ..strokeWidth = 0.05
      //     ..color = const Color(0xff000000);
      //   final path = Path();
      //   path.moveTo(v.dpoints[4].x, v.dpoints[4].y);
      //   path.lineTo(v.dpoints[4].x + _cube.movingDisplayAxis.dx,
      //               v.dpoints[4].y + _cube.movingDisplayAxis.dy,);
      //   canvas.drawPath(path, paintBorder);
      //   path.close();

      // }

      if (v.dpoints[5].z >= 0) {
        final path = Path();
        path.moveTo(v.dpoints[6].x, v.dpoints[6].y);
        path.lineTo(v.dpoints[7].x, v.dpoints[7].y);
        path.lineTo(v.dpoints[8].x, v.dpoints[8].y);
        path.lineTo(v.dpoints[9].x, v.dpoints[9].y);
        path.lineTo(v.dpoints[6].x, v.dpoints[6].y);
        path.close();
        _cube.clickPaths[path] = v;
      }
    });

    done = true;
  }

  @override
  bool shouldRepaint(CubePainter oldDelegate) => oldDelegate.done;
}

class _CubeWidgetState extends State<CubeWidget> {
  final FlutterCube _cube;

  _CubeWidgetState(FlutterCube cube) : _cube = cube {
    print('_CubeWidgetState constructor');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => handleOnPanStart(details),
      onPanUpdate: (details) => handleOnPanUpdate(details),
      onPanEnd: (details) => handleOnPanEnd(details),
      child: Container(
        width: 500,
        child: CustomPaint(
          painter: CubePainter(_cube),
        ),
      ),
    );
  }

  void handleOnPanStart(var details) {
    Offset offset = details.localPosition
        .translate(-_cube.size / 2.0, -_cube.size / 2.0)
        .scale(5.0 / _cube.size, -5.0 / _cube.size);

    _cube.movingFace = FlutterCube.nullFace;
    _cube.movingDisplayAxis = FlutterCube.nullOffset;
    _cube.startPan = offset;

    for (Path path in _cube.clickPaths.keys) {
      if (path.contains(offset)) {
        RubiksFace? face = _cube.clickPaths[path];
        if (face != null) {
          print(face);

          _cube.movingFace = face;
          _cube.movingDisplayAxis = FlutterCube.nullOffset;
        }
        //setState(() => {});
      }
    }
  }

  void handleOnPanUpdate(var details) {
    Offset delta = details.localPosition
            .translate(-_cube.size / 2.0, -_cube.size / 2.0)
            .scale(5.0 / _cube.size, -5.0 / _cube.size) -
        _cube.startPan;

    if (_cube.movingFace != FlutterCube.nullFace) {
      //print("we're not nullFace, " + _cube.movingDisplayAxis.toString());

      if (delta.distance > 0.1 &&
          _cube.movingDisplayAxis == FlutterCube.nullOffset) {
        // the tricky stuff..., determine which layer is moving
        print("determine which layer is moving");

        // step 1) create a list of possibilities
        List<(RubiksAxis, Offset, double)> tmpDecisionList = [];
        Matrix3x3 m = RubiksFace.displayMatrix;
        for (RubiksAxis axis in RubiksAxis.values) {
          if (axis != _cube.movingFace.direction) {
            Point3D display3DAxis = m *
                RubiksAxis2Point3D(otherAxis(axis, _cube.movingFace.direction));
            Offset display2DAxis =
                normalize(Offset(display3DAxis.x, display3DAxis.y));
            double dotProduct =
                display2DAxis.dx * delta.dx + display2DAxis.dy * delta.dy;
            tmpDecisionList.add((axis, display2DAxis, dotProduct));
          }
        }
        // print(tmpDecisionList);

        // step 2) remove the face direction (we don't want 'palm of the hand steering')
        // tmpDecisionList.removeWhere((item) => item.$1 == _cube.movingFace.direction);

        // step 3) sort on absolute value of the dot product
        tmpDecisionList.sort((a, b) => a.$3.abs().compareTo(b.$3.abs()));

        // step 4) select and copy the best stuff (last item of the list)
        _cube.movingRubiksAxis = tmpDecisionList.last.$1;
        _cube.movingDisplayAxis = tmpDecisionList.last.$2;
        switch (_cube.movingRubiksAxis) {
          case RubiksAxis.x:
            _cube.movingRubiksLayer = _cube.movingFace.position.ix;
          case RubiksAxis.y:
            _cube.movingRubiksLayer = _cube.movingFace.position.iy;
          case RubiksAxis.z:
            _cube.movingRubiksLayer = _cube.movingFace.position.iz;
        }
        // print("determined : ");
        // print(_cube.movingRubiksAxis.toString());
        // print(_cube.movingRubiksLayer.toString());
        // print(_cube.movingDisplayAxis.toString());
      } // if (delta.distance > 0.1 && movingDisplayAxis == FlutterCube.nullOffset)

      if (_cube.movingDisplayAxis != FlutterCube.nullOffset) {
        double dotProduct = _cube.movingDisplayAxis.dx * delta.dx +
            _cube.movingDisplayAxis.dy * delta.dy;
        _cube.movingRubiksAngle = (180.0 * dotProduct).clamp(-90.0, 90.0);

        //print(_cube.movingDisplayAxis.toString() + ' ' + bah(dotProduct));

        // dunno, but works
        // if (prevRubiksAxis(_cube.movingRubiksAxis) == _cube.movingFace.direction) {
        //   _cube.movingRubiksAngle *= -1.0 * valueInDirection(_cube.movingFace.position, _cube.movingFace.direction);
        // }
        _cube.movingRubiksAngle *= valueInDirection(
            _cube.movingFace.position, _cube.movingFace.direction);
        if (prevRubiksAxis(_cube.movingRubiksAxis) ==
            _cube.movingFace.direction) {
          _cube.movingRubiksAngle *= -1.0;
        }

        //print(valueInDirection(_cube.movingFace.position, _cube.movingFace.direction));

        _cube.animateRotate(_cube.movingRubiksAxis, _cube.movingRubiksLayer,
            _cube.movingRubiksAngle);

        _cube.lastDistance = delta.distance;

        setState(() => {}); // force redraw
      } // if (_cube.movingRubiksAxis != null && _cube.movingDisplayAxis != null)
    } else {
      // print('wheeh freee moving...');
      if (delta.distance > 0.1 && !_cube.freeRotate) {
        _cube.freeRotate = true;
        _cube.freeRotateUsesX = delta.dx.abs() >= delta.dy.abs();
      }
      if (_cube.freeRotate) {
        // if (_cube.freeRotateUsesX) {
        //   _cube.updateRotationMatrixTemp(0.0, );
        // } else {
        //   _cube.updateRotationMatrixTemp(-delta.dy * 90.0, 0.0);
        // }
        _cube.updateRotationMatrixTemp(
          delta.dx * 90.0,
          -delta.dy * 90.0,
        );

        //print(RubiksFace.color_map[_cube.whatsUp()]);
        setState(() => {}); // force redraw
      }
    }
  }

  void handleOnPanEnd(var details) {
    if (_cube.movingDisplayAxis != FlutterCube.nullOffset) {
      _cube.resetRotate();
      if (_cube.lastDistance > 0.2) {
        //print('finish');
        _cube.finishRotate(_cube.movingRubiksAxis, _cube.movingRubiksLayer,
            _cube.movingRubiksAngle);
      }
    } else {
      // print('wheeh freee moving... finish');
      _cube.freeRotate = false;
      _cube.updateDisplayMatrix();
    }

    setState(() => {}); // force redraw
    _cube.movingFace = FlutterCube.nullFace;
    _cube.movingRubiksAxis = RubiksAxis.x;
    _cube.movingRubiksLayer = 0;
  }
}

//class CubeWidget extends StatelessWidget {
class CubeWidget extends StatefulWidget {
  final FlutterCube _cube;

  CubeWidget(FlutterCube cube) : _cube = cube {
    super.key;
    print('CubeWidget constructor');
  }

  @override
  State<CubeWidget> createState() => _CubeWidgetState(_cube);
}
