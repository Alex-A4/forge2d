part of forge2d.common;

/// A transform contains translation and rotation. It is used to represent the position and
/// orientation of rigid frames.
class Transform {
  /// The translation caused by the transform
  final Vector2 p;

  /// A matrix representing a rotation
  final Rot q;

  /// The default constructor.
  Transform.zero()
      : p = Vector2.zero(),
        q = Rot();

  /// Initialize as a copy of another transform.
  Transform.clone(final Transform xf)
      : p = xf.p.clone(),
        q = xf.q.clone();

  /// Initialize using a position vector and a rotation matrix.
  Transform.from(final Vector2 position, final Rot r)
      : p = position.clone(),
        q = r.clone();

  /// Set this to equal another transform.
  Transform set(final Transform xf) {
    p.setFrom(xf.p);
    q.setFrom(xf.q);
    return this;
  }

  /// Set this based on the position and angle.
  void setVec2Angle(Vector2 p, double angle) {
    p.setFrom(p);
    q.setAngle(angle);
  }

  /// Set this to the identity transform.
  void setIdentity() {
    p.setZero();
    q.setIdentity();
  }

  static Vector2 mulVec2(final Transform t, final Vector2 v) {
    return Vector2((t.q.c * v.x - t.q.s * v.y) + t.p.x,
        (t.q.s * v.x + t.q.c * v.y) + t.p.y);
  }

  static Vector2 mulTransVec2(final Transform t, final Vector2 v) {
    final double pX = v.x - t.p.x;
    final double pY = v.y - t.p.y;
    return Vector2(t.q.c * pX + t.q.s * pY, -t.q.s * pX + t.q.c * pY);
  }

  static Transform mul(final Transform a, final Transform b) {
    final Transform c = Transform.zero();
    c.q.setFrom(Rot.mul(a.q, b.q));
    c.p.setFrom(Rot.mulVec2(a.q, b.p));
    c.p.add(a.p);
    return c;
  }

  static Transform mulTrans(final Transform a, final Transform b) {
    final Vector2 v = b.p - a.p;
    return Transform.from(Rot.mulTransVec2(a.q, v), Rot.mulTrans(a.q, b.q));
  }

  @override
  String toString() {
    String s = "XForm:\n";
    s += "Position: $p\n";
    s += "R: \t$q\n";
    return s;
  }
}
