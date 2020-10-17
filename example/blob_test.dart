library BlobTest;

import 'dart:math' as math;
import 'demo.dart';
import 'package:forge2d/forge2d.dart';

class BlobTest extends Demo {
  /// Constructs a new BlobTest.
  BlobTest() : super("Blob test");

  /// Entrypoint.
  static void main() {
    final blob = BlobTest();
    blob.initialize();
    blob.initializeAnimation();
    blob.runAnimation();
  }

  void initialize() {
    Body ground;
    {
      PolygonShape sd = PolygonShape();
      sd.setAsBoxXY(50.0, 0.4);

      BodyDef bd = BodyDef();
      bd.position.setValues(0.0, 0.0);
      assert(world != null);
      ground = world.createBody(bd);
      ground.createFixtureFromShape(sd);

      sd.setAsBox(0.4, 50.0, Vector2(-10.0, 0.0), 0.0);
      ground.createFixtureFromShape(sd);
      sd.setAsBox(0.4, 50.0, Vector2(10.0, 0.0), 0.0);
      ground.createFixtureFromShape(sd);
    }

    ConstantVolumeJointDef jointDef = ConstantVolumeJointDef();

    double cx = 0.0;
    double cy = 10.0;
    double rx = 5.0;
    double ry = 5.0;
    double nBodies = 20.0;
    double bodyRadius = 0.5;
    for (int i = 0; i < nBodies; ++i) {
      double angle = (i / nBodies) * math.pi * 2;
      BodyDef bd = BodyDef();
      bd.fixedRotation = true;

      double x = cx + rx * math.sin(angle);
      double y = cy + ry * math.cos(angle);
      bd.position.setFrom(Vector2(x, y));
      bd.type = BodyType.DYNAMIC;
      Body body = world.createBody(bd);

      FixtureDef fd = FixtureDef();
      CircleShape cd = CircleShape();
      cd.radius = bodyRadius;
      fd.shape = cd;
      fd.density = 1.0;
      fd.filter.groupIndex = -2;
      body.createFixtureFromFixtureDef(fd);
      jointDef.addBody(body);
    }

    jointDef.frequencyHz = 10.0;
    jointDef.dampingRatio = 1.0;
    jointDef.collideConnected = false;
    world.createJoint(jointDef);

    BodyDef bd2 = BodyDef();
    bd2.type = BodyType.DYNAMIC;
    PolygonShape psd = PolygonShape();
    psd.setAsBox(3.0, 1.5, Vector2(cx, cy + 15.0), 0.0);
    bd2.position = Vector2(cx, cy + 15.0);
    Body fallingBox = world.createBody(bd2);
    fallingBox.createFixtureFromShape(psd, 1.0);
  }
}

void main() {
  BlobTest.main();
}
