part of forge2d;

abstract class VoronoiDiagramCallback {
  void call(int aTag, int bTag, int cTag);
}

class VoronoiGenerator {
  final Vector2 center = Vector2.zero();
  int tag = 0;

  VoronoiGenerator(Vector2 center, this.tag) {
    this.center.setFrom(center);
  }
}

class VoronoiDiagramTask {
  int x = 0, y = 0, i = 0;
  VoronoiGenerator generator;

  VoronoiDiagramTask(this.x, this.y, this.i, this.generator);

  VoronoiDiagramTask.zero();

  void set(int x, int y, int i, VoronoiGenerator generator) {
    this.x = x;
    this.y = y;
    this.i = i;
    this.generator = generator;
  }
}

class VoronoiDiagram {
  final List<VoronoiGenerator> generators = <VoronoiGenerator>[];
  int _countX = 0, _countY = 0;
  // The diagram is an array of "pointers".
  List<VoronoiGenerator> _diagram;

  void getNodes(VoronoiDiagramCallback callback) {
    for (int y = 0; y < _countY - 1; y++) {
      for (int x = 0; x < _countX - 1; x++) {
        final int i = x + y * _countX;
        final VoronoiGenerator a = _diagram[i];
        final VoronoiGenerator b = _diagram[i + 1];
        final VoronoiGenerator c = _diagram[i + _countX];
        final VoronoiGenerator d = _diagram[i + 1 + _countX];
        if (b != c) {
          if (a != b && a != c) {
            callback.call(a.tag, b.tag, c.tag);
          }
          if (d != b && d != c) {
            callback.call(b.tag, d.tag, c.tag);
          }
        }
      }
    }
  }

  void addGenerator(Vector2 center, int tag) {
    generators.add(VoronoiGenerator(center, tag));
  }

  final Vector2 _lower = Vector2.zero();
  final Vector2 _upper = Vector2.zero();

  final ListQueue<VoronoiDiagramTask> _queue = ListQueue<VoronoiDiagramTask>();

  void generate(double radius) {
    assert(_diagram == null);
    final double inverseRadius = 1 / radius;
    _lower.x = double.maxFinite;
    _lower.y = double.maxFinite;
    _upper.x = -double.maxFinite;
    _upper.y = -double.maxFinite;
    for (VoronoiGenerator g in generators) {
      Vector2.min(_lower, g.center, _lower);
      Vector2.max(_upper, g.center, _upper);
    }
    _countX = 1 + (inverseRadius * (_upper.x - _lower.x)).toInt();
    _countY = 1 + (inverseRadius * (_upper.y - _lower.y)).toInt();
    _diagram = List<VoronoiGenerator>(_countX * _countY);
    _queue.clear();
    for (VoronoiGenerator g in generators) {
      g.center.setFrom((g.center - _lower)..scale(inverseRadius));
      final int x = math.max(0, math.min(g.center.x.toInt(), _countX - 1));
      final int y = math.max(0, math.min(g.center.y.toInt(), _countY - 1));
      _queue.addFirst(VoronoiDiagramTask(x, y, x + y * _countX, g));
    }
    while (_queue.isNotEmpty) {
      final VoronoiDiagramTask front = _queue.removeFirst();
      final int x = front.x;
      final int y = front.y;
      final int i = front.i;
      final VoronoiGenerator g = front.generator;
      if (_diagram[i] == null) {
        _diagram[i] = g;
        if (x > 0) {
          _queue.addFirst(VoronoiDiagramTask(x - 1, y, i - 1, g));
        }
        if (y > 0) {
          _queue.addFirst(VoronoiDiagramTask(x, y - 1, i - _countX, g));
        }
        if (x < _countX - 1) {
          _queue.addFirst(VoronoiDiagramTask(x + 1, y, i + 1, g));
        }
        if (y < _countY - 1) {
          _queue.addFirst(VoronoiDiagramTask(x, y + 1, i + _countX, g));
        }
      }
    }
    final int maxIteration = _countX + _countY;
    for (int iteration = 0; iteration < maxIteration; iteration++) {
      for (int y = 0; y < _countY; y++) {
        for (int x = 0; x < _countX - 1; x++) {
          final int i = x + y * _countX;
          final VoronoiGenerator a = _diagram[i];
          final VoronoiGenerator b = _diagram[i + 1];
          if (a != b) {
            _queue.addFirst(VoronoiDiagramTask(x, y, i, b));
            _queue.addFirst(VoronoiDiagramTask(x + 1, y, i + 1, a));
          }
        }
      }
      for (int y = 0; y < _countY - 1; y++) {
        for (int x = 0; x < _countX; x++) {
          final int i = x + y * _countX;
          final VoronoiGenerator a = _diagram[i];
          final VoronoiGenerator b = _diagram[i + _countX];
          if (a != b) {
            _queue.addFirst(VoronoiDiagramTask(x, y, i, b));
            _queue.addFirst(VoronoiDiagramTask(x, y + 1, i + _countX, a));
          }
        }
      }
      bool updated = false;
      while (_queue.isNotEmpty) {
        final VoronoiDiagramTask front = _queue.removeFirst();
        final int x = front.x;
        final int y = front.y;
        final int i = front.i;
        final VoronoiGenerator k = front.generator;
        final VoronoiGenerator a = _diagram[i];
        final VoronoiGenerator b = k;
        if (a != b) {
          final double ax = a.center.x - x;
          final double ay = a.center.y - y;
          final double bx = b.center.x - x;
          final double by = b.center.y - y;
          final double a2 = ax * ax + ay * ay;
          final double b2 = bx * bx + by * by;
          if (a2 > b2) {
            _diagram[i] = b;
            if (x > 0) {
              _queue.addFirst(VoronoiDiagramTask(x - 1, y, i - 1, b));
            }
            if (y > 0) {
              _queue.addFirst(VoronoiDiagramTask(x, y - 1, i - _countX, b));
            }
            if (x < _countX - 1) {
              _queue.addFirst(VoronoiDiagramTask(x + 1, y, i + 1, b));
            }
            if (y < _countY - 1) {
              _queue.addFirst(VoronoiDiagramTask(x, y + 1, i + _countX, b));
            }
            updated = true;
          }
        }
      }
      if (!updated) {
        break;
      }
    }
  }
}
