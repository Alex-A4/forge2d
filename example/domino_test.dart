library domino_test;

import 'demo.dart';

import 'package:forge2d/forge2d.dart';

/// Demonstration of dominoes being knocked over.
class DominoTest extends Demo {
  DominoTest() : super("Domino test");

  @override
  void initialize() {
    {
      // Floor
      final FixtureDef fd = FixtureDef();
      final PolygonShape sd = PolygonShape();
      sd.setAsBoxXY(50.0, 10.0);
      fd.shape = sd;

      final BodyDef bd = BodyDef();
      bd.position = Vector2(0.0, -10.0);
      final body = world.createBody(bd);
      body.createFixture(fd);
      bodies.add(body);
    }

    {
      // Platforms
      for (int i = 0; i < 4; i++) {
        final FixtureDef fd = FixtureDef();
        final PolygonShape sd = PolygonShape();
        sd.setAsBoxXY(15.0, 0.125);
        fd.shape = sd;

        final BodyDef bd = BodyDef();
        bd.position = Vector2(0.0, 5.0 + 5 * i);
        final body = world.createBody(bd);
        body.createFixture(fd);
        bodies.add(body);
      }
    }

    // Dominoes
    {
      final FixtureDef fd = FixtureDef();
      final PolygonShape sd = PolygonShape();
      sd.setAsBoxXY(0.125, 2.0);
      fd.shape = sd;
      fd.density = 25.0;

      final BodyDef bd = BodyDef();
      bd.type = BodyType.DYNAMIC;

      const double friction = .5;
      const int numPerRow = 25;

      for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < numPerRow; j++) {
          fd.friction = friction;
          bd.position =
              Vector2(-14.75 + j * (29.5 / (numPerRow - 1)), 7.3 + 5 * i);
          if (i == 2 && j == 0) {
            bd.angle = -.1;
            bd.position.x += .1;
          } else if (i == 3 && j == numPerRow - 1) {
            bd.angle = .1;
            bd.position.x -= .1;
          } else {
            bd.angle = 0.0;
          }
          final Body body = world.createBody(bd);
          body.createFixture(fd);
          bodies.add(body);
        }
      }
    }
  }
}

void main() {
  final domino = DominoTest();
  domino.initialize();
  domino.initializeAnimation();
  domino.runAnimation();
}
