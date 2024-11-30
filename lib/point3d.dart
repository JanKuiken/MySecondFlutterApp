//
// A bare 3D point class and 3x3 matrix class for my Rubiks Cube program
//

import 'dart:math';

double deg2rad(double deg) {
  return pi * deg / 180.0;
}

double rad2deg(double rad) {
  return 180.0 * rad / pi;
}

class Point3D {
  double x, y, z;

  Point3D(this.x, this.y, this.z);

  @override
  String toString() {
    var sx = x.toStringAsFixed(2);
    var sy = y.toStringAsFixed(2);
    var sz = z.toStringAsFixed(2);
    return '[ $sx , $sy , $sz ]';
  }
}

class Point3Dint {
  int ix, iy, iz;

  Point3Dint(this.ix, this.iy, this.iz);

  @override
  String toString() {
    var sx = ix.toString();
    var sy = iy.toString();
    var sz = iz.toString();
    return 'Point3Dint[ $sx , $sy , $sz ]';
  }
}

class Matrix3x3 {
  double m11, m12, m13, 
         m21, m22, m23, 
         m31, m32, m33 ;

  Matrix3x3(this.m11, this.m12, this.m13, 
            this.m21, this.m22, this.m23,
            this.m31, this.m32, this.m33 );

  Matrix3x3.ones() : this( 1.0 , 0.0 , 0.0 , 
                           0.0 , 1.0 , 0.0 , 
                           0.0 , 0.0 , 1.0   );

  Matrix3x3.rotateX(double theta)
      : this(  1.0        ,  0.0        ,  0.0        , 
               0.0        ,  cos(theta) , -sin(theta) ,
               0.0        ,  sin(theta) ,  cos(theta)   );

  Matrix3x3.rotateY(double theta)
      : this(  cos(theta) ,  0.0        ,  sin(theta) ,
               0.0        ,  1.0        ,  0.0        ,
              -sin(theta) ,  0.0        ,  cos(theta)   );

  Matrix3x3.rotateZ(double theta)
      : this(  cos(theta) , -sin(theta) , 0.0         , 
               sin(theta) ,  cos(theta) , 0.0         , 
               0.0        ,  0.0        , 1.0           );

  Matrix3x3 dot(Matrix3x3 other) {
    return Matrix3x3(
        m11 * other.m11 + m12 * other.m21 + m13 * other.m31,
        m11 * other.m12 + m12 * other.m22 + m13 * other.m32,
        m11 * other.m13 + m12 * other.m23 + m13 * other.m33,
        m21 * other.m11 + m22 * other.m21 + m23 * other.m31,
        m21 * other.m12 + m22 * other.m22 + m23 * other.m32,
        m21 * other.m13 + m22 * other.m23 + m23 * other.m33,
        m31 * other.m11 + m32 * other.m21 + m33 * other.m31,
        m31 * other.m12 + m32 * other.m22 + m33 * other.m32,
        m31 * other.m13 + m32 * other.m23 + m33 * other.m33);
  }

  Matrix3x3 transpose() {
    // for a rotating matrix, this is also the the inverse
    return Matrix3x3( m11 , m21 , m31 , 
                      m12 , m22 , m32 , 
                      m13 , m23 , m33   );
  }

  Point3D operator *(Point3D p) {
    return Point3D( m11 * p.x + m12 * p.y + m13 * p.z ,
                    m21 * p.x + m22 * p.y + m23 * p.z , 
                    m31 * p.x + m32 * p.y + m33 * p.z   );
  }

  @override
  String toString() {
    var sm11 = m11.toStringAsFixed(3);
    var sm12 = m12.toStringAsFixed(3);
    var sm13 = m13.toStringAsFixed(3);
    var sm21 = m21.toStringAsFixed(3);
    var sm22 = m22.toStringAsFixed(3);
    var sm23 = m23.toStringAsFixed(3);
    var sm31 = m31.toStringAsFixed(3);
    var sm32 = m32.toStringAsFixed(3);
    var sm33 = m33.toStringAsFixed(3);
    return '[ $sm11 , $sm12 , $sm13 \n  $sm21 , $sm22 , $sm23 \n  $sm31 , $sm32 , $sm33 ]';
  }
}

class Matrix3x3int {
  int m11, m12, m13, 
      m21, m22, m23, 
      m31, m32, m33 ;

  Matrix3x3int(this.m11, this.m12, this.m13, 
               this.m21, this.m22, this.m23,
               this.m31, this.m32, this.m33 );

  Matrix3x3int.ones() : this( 1, 0, 0,
                              0, 1, 0, 
                              0, 0, 1 );

  // next methods are 90 degrees rotations

  Matrix3x3int.rotXpos() : this(  1 , 0 , 0 , 
                                  0 , 0 ,-1 , 
                                  0 , 1 , 0   );

  Matrix3x3int.rotXneg() : this(  1 , 0 , 0 , 
                                  0 , 0 , 1 , 
                                  0 ,-1 , 0   );

  Matrix3x3int.rotYpos() : this(  0 , 0 , 1 , 
                                  0 , 1 , 0 ,
                                 -1 , 0 , 0   );

  Matrix3x3int.rotYneg() : this(  0 , 0 ,-1 , 
                                  0 , 1 , 0 , 
                                  1 , 0 , 0   );

  Matrix3x3int.rotZpos() : this(  0 ,-1 , 0 ,
                                  1 , 0 , 0 , 
                                  0 , 0 , 1   );

  Matrix3x3int.rotZneg() : this(  0 , 1 , 0 ,
                                 -1 , 0 , 0 , 
                                  0 , 0 , 1   );

  Point3Dint operator *(Point3Dint p) {
    return Point3Dint(
        m11 * p.ix + m12 * p.iy + m13 * p.iz,
        m21 * p.ix + m22 * p.iy + m23 * p.iz,
        m31 * p.ix + m32 * p.iy + m33 * p.iz);
  }

  @override
  String toString() {
    var sm11 = m11.toString();
    var sm12 = m12.toString();
    var sm13 = m13.toString();
    var sm21 = m21.toString();
    var sm22 = m22.toString();
    var sm23 = m23.toString();
    var sm31 = m31.toString();
    var sm32 = m32.toString();
    var sm33 = m33.toString();
    return '[ $sm11 , $sm12  , $sm13 \n  $sm21 , $sm22  , $sm23 \n  $sm31 , $sm32  , $sm33 ]';
  }
}
