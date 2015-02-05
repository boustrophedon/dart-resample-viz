import 'dart:math';
import 'package:dart_resample_viz/graph.dart';

void main() {
  //var probabilities = [0.005, 0.0053, 0.007, 0.0094, 0.0125, 0.0167, 0.0222, 0.0297, 0.0395, 0.0527, 0.0703, 0.0937, 0.125, 0.1666];
  var probabilities = [0.005, 0.0053, 0.007, 0.0094, 0.0125, 0.0167, 0.0222, 0.0297, 0.0396, 0.0527, 0.0703, 0.0938, 0.125, 0.1562, 0.1797, 0.1973, 0.2104, 0.2203, 0.2278, 0.2333, 0.2375, 0.2406, 0.243, 0.2447, 0.245, 0.25];
  var sizes = [1000,2000,5000];
  var dist = 4;
  var type = "Torus";
  for (int size in sizes) {
    print("${size}x${size} $type");
    print("probability,resamples,stdev,rel_stdev");
    for (num p in probabilities) {
      List<int> runs = new List<int>();
      for (int i = 0; i<10; i++) {
        ResampleGridGraph graph = new ResampleGridGraph(size: size, p:p, p_distribution:dist, is_torus: true);
        bool done = false;
        while (!done) {
          done = graph.step();
        }
        runs.add(graph.total_resamples);
      }
      int avg_resamples = runs.reduce((a,b) => (a+b))~/(runs.length);
      var devs = new List.from(runs.map((a) => (pow((a-avg_resamples), 2))));
      int stdev = sqrt(devs.reduce((a,b) => (a+b))~/(devs.length-1)).toInt();
      num percent = ((10000*(stdev/avg_resamples)).round())/100;
      print("${p},${avg_resamples},${stdev},${percent}");
    }
    print("\n");
  }
}
