library renderer;

import 'dart:html';
import 'dart:math';
import 'dart:async';

import 'package:dart_resample_viz/graph.dart';

class ResampleRenderer {
  CanvasElement canvas;
  CanvasRenderingContext2D context;

  DivElement controls;
  TextAreaElement output;

  final num VERTEX_RADIUS;
  Duration step_delay;
  ResampleGraph graph;

  bool running = true;

  int size = 10;
  num p = null;
  int p_distribution = null;
  int num_colors = 6;
  String resample_strategy;


  ResampleRenderer(this.canvas, this.controls, this.output, {this.VERTEX_RADIUS: 9}) {
    if (controls.querySelector('#size-input').value != "") {
      size = int.parse(controls.querySelector('#size-input').value);
    }
    if (controls.querySelector('#p-input').value != "") {
      p = num.parse(controls.querySelector('#p-input').value);
    }
    if (controls.querySelector('#dist-input').value != "") {
      p_distribution = int.parse(controls.querySelector('#dist-input').value);
    }
    if (controls.querySelector('#colors-input').value != "") {
      num_colors = int.parse(controls.querySelector('#colors-input').value);
    }
    resample_strategy = (querySelector("#strategy-input") as SelectElement).selectedOptions.first.value;

    context = canvas.context2D;

    step_delay = new Duration(milliseconds: controls.querySelector("#timer-value").valueAsNumber*10);
  }

  void output_start_text() {
    output.value += "Starting new resample run.\nProbability distribution: ${graph.probabilities}";
  }

  void start() {
    output_start_text();
    run();
  }

  void stop() {
    running = false;
  }

  void run() {
    if (!running) {
      return;
    }
    bool done = graph.step();
    if (done) {
      output.value += "\nComplete!\nTotal resamples: ${graph.total_resamples}";
      draw_graph();
      return;
    } else {
      draw_graph();
      if (step_delay == null) {
        window.requestAnimationFrame((t) => run());
      } else {
        new Future.delayed(step_delay, run);
      }
    }
  }

  void draw_vertex(Vertex v) {}

  void draw_vertex_heatmap(Vertex v) {}

  void draw_vertex_resamples(Vertex v) {}

  void draw_edge(Edge e) {}

  void draw_graph() {
    context.fillStyle = '#777777';
    context.fillRect(0, 0, canvas.width, canvas.height);

    context.lineWidth = VERTEX_RADIUS / 2;
    // draw edges and their vertices
    for (Vertex v in graph.vertices) {
      for (Edge e in v.edges) {
        if (e.vertices.first == v) {
          draw_edge(e);
        }
      }
    }
    for (Vertex v in graph.vertices) {
      draw_vertex(v);
      draw_vertex_resamples(v);
    }
  }
}

class ResampleGridRenderer extends ResampleRenderer {
  ResampleGridRenderer(canvas, controls, output, {VERTEX_RADIUS: 9}) : super(canvas, controls, output, VERTEX_RADIUS: VERTEX_RADIUS) {
    bool torus = controls.querySelector('#torus-check').checked;
    num q = 0;
    
    canvas.width = size * 4 * VERTEX_RADIUS - 2 * VERTEX_RADIUS;
    canvas.height = size * 4 * VERTEX_RADIUS - 2 * VERTEX_RADIUS;

    if (controls.querySelector('#diagonal-input').value != "") {
      q = num.parse(controls.querySelector('#diagonal-input').value);
    }
    try {
      graph = new ResampleGridGraph(size: size, p: p, p_distribution: p_distribution, num_colors: num_colors, resample_strategy: resample_strategy, is_torus: torus, q: q);
    } catch(e) {
      output.value+=e.toString();
      throw e;
    }
  } 
  
  void draw_vertex(Vertex v) {
    int x = v.x;
    int y = v.y;
    context.beginPath();
    context.arc(x * VERTEX_RADIUS * 4 + VERTEX_RADIUS,
        canvas.height - (y * VERTEX_RADIUS * 4) - VERTEX_RADIUS, VERTEX_RADIUS,
        0, 2 * PI);
    context.fillStyle = v.color;
    context.fill();
    context.closePath();
  }

  void draw_vertex_heatmap(Vertex v) {
    int x = v.x;
    int y = v.y;
    context.lineWidth = 1;

    context.beginPath();
    context.arc(x * VERTEX_RADIUS * 4 + VERTEX_RADIUS,
        canvas.height - (y * VERTEX_RADIUS * 4) - VERTEX_RADIUS, VERTEX_RADIUS,
        0, 2 * PI);
    context.fillStyle = "rgb(${v.resamples*20}, 0, 0)";
    context.fill();
    context.closePath();
  }

  void draw_vertex_resamples(Vertex v) {
    int x = v.x;
    int y = v.y;
    context.font = "10pt Arial";
    context.fillStyle = "#000000";
    TextMetrics size = context.measureText("${v.resamples}");
    context.fillText("${v.resamples}", 
        x * VERTEX_RADIUS * 4 + VERTEX_RADIUS - (size.width / 2),
        (10 / 2) +
        canvas.height - (y * VERTEX_RADIUS * 4) - VERTEX_RADIUS);
  }

  void draw_edge(Edge e) {
    if ((e.vertices[0].x > e.vertices[1].x) || (e.vertices[0].y > e.vertices[1].y)) {
      return;
    }
    if (e.isbad) {
      context.strokeStyle = '#FF0000';
    } else if ((e.vertices[0].x != e.vertices[1].x) && (e.vertices[0].y != e.vertices[1].y)) {
      // diagonal edges are white
      context.strokeStyle = '#FFFFFF';
    } else {
      return;
    }
    context.lineWidth = 4;
    context.beginPath();
    context.moveTo(e.vertices[0].x * VERTEX_RADIUS * 4 + VERTEX_RADIUS,
        canvas.height - (e.vertices[0].y * VERTEX_RADIUS * 4) - VERTEX_RADIUS);
    context.lineTo(e.vertices[1].x * VERTEX_RADIUS * 4 + VERTEX_RADIUS,
        canvas.height - (e.vertices[1].y * VERTEX_RADIUS * 4) - VERTEX_RADIUS);
    context.stroke();
    context.closePath();
  }
}
class ResampleRandomRenderer extends ResampleRenderer {
  num scale;
  ResampleRandomRenderer(canvas, controls, output, {VERTEX_RADIUS: 9}) : super(canvas, controls, output, VERTEX_RADIUS: VERTEX_RADIUS) {
    int degree = 4;

    scale = size * VERTEX_RADIUS;

    canvas.width = 2*scale + 2*VERTEX_RADIUS;
    canvas.height =2*scale + 2*VERTEX_RADIUS;

    if (controls.querySelector('#degree-input').value != "") {
      degree = int.parse(controls.querySelector('#degree-input').value);
    }
    try {
      graph = new ResampleRandomGraph(size: size, p: p, p_distribution: p_distribution, num_colors: num_colors, resample_strategy: resample_strategy, degree: degree);
    } catch(e) {
      output.value+=e.toString();
      throw e;
    }
  }

  void output_start_text() {
    output.value += "Starting new resample run.\nProbability distribution: ${graph.probabilities}";
    num avg_degree = graph.vertices.fold(0, (sum, v) => (sum+v.edges.length))/graph.vertices.length;
    output.value+="\nAverage degree: ${avg_degree}\n";
  }

  void draw_vertex(Vertex v) {
    num x = v.x;
    num y = v.y;
    context.beginPath();
    context.arc(scale*x + scale + VERTEX_RADIUS,
        scale*y+ scale + VERTEX_RADIUS, VERTEX_RADIUS,
        0, 2 * PI);
    context.fillStyle = v.color;
    context.fill();
    context.closePath();
  }

  void draw_vertex_resamples(Vertex v) {
    int x = v.x;
    int y = v.y;
    context.font = "10pt Arial";
    context.fillStyle = "#000000";
    TextMetrics size = context.measureText("${v.resamples}");
    context.fillText("${v.resamples}", 
        x * scale + scale + VERTEX_RADIUS - (size.width / 2),
        (10 / 2) +
        y * scale + scale + VERTEX_RADIUS);
  }

  void draw_edge(Edge e) {
    if (e.isbad) {
      context.strokeStyle = '#FF0000';
    } else {
      context.strokeStyle = '#FFFFFF';
    }
    context.lineWidth = 4;
    context.beginPath();
    context.moveTo(e.vertices[0].x*scale + scale + VERTEX_RADIUS,
        e.vertices[0].y*scale + scale + VERTEX_RADIUS);
    context.lineTo(e.vertices[1].x*scale + scale + VERTEX_RADIUS,
        e.vertices[1].y*scale + scale + VERTEX_RADIUS);
    context.stroke();
    context.closePath();
  }
}
