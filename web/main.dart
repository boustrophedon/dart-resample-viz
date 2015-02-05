import 'dart:html';

import 'package:dart_resample_viz/renderer.dart';

ResampleRenderer current_resampler;

void main() {
  DivElement controls = querySelector('#controls');

  populate_controls(controls);

  current_resampler = new_resample();
}

void populate_controls(DivElement controls) {
  controls.nodes.clear();
  
  populate_default_controls(controls);

  SelectElement graph_type = querySelector('#graphtype-input');
  graph_type.onChange.listen((e) => populate_controls(controls));
  
  switch (graph_type.selectedOptions.first.value) {
    case 'grid':
      populate_grid_controls(controls);
      break;
    case 'random':
      populate_random_controls(controls);
      break;
    default:
      populate_grid_controls(controls);
  }
 
  populate_output_area(controls);
  style_controls(controls);
}

void populate_default_controls(DivElement controls) {
  controls.nodes.add(new BRElement());
  controls.nodes.add(new BRElement());
  controls.nodes.add(
      new LabelElement()
      ..text = "Speed: "
      ..htmlFor = "timer-value"
      ..style.lineHeight = "100%"
  );
  controls.nodes.add(
      new RangeInputElement()
      ..id="timer-value"
      ..valueAsNumber=20
      ..onChange.listen((e){
        current_resampler.step_delay = new Duration(milliseconds: e.target.valueAsNumber*10);
      })
  );
  controls.nodes.add(new BRElement());

  controls.nodes.add(
      new ButtonElement()
      ..id="toggle"
      ..text="Stop"
      ..onClick.listen((e){
        current_resampler.running = !(current_resampler.running);
        current_resampler.run();
        if (e.target.text == "Start") {
          e.target.text = "Stop";
        }
        else {
          e.target.text = "Start";
        }
      })
  );
  controls.nodes.add(
      new ButtonElement()
      ..id="new-resample"
      ..text="Restart"
      ..onClick.listen((e){
        (querySelector('#output-area') as TextAreaElement).value = '';
        current_resampler.stop();
        current_resampler = new_resample();
      })
  );
  controls.nodes.add(new BRElement());
  controls.nodes.add(
      new TextInputElement()
      ..id="size-input"
      ..size=4
      ..placeholder="Size"
  );
  controls.nodes.add(
      new TextInputElement()
      ..id="p-input"
      ..size=4
      ..placeholder="p"
  );
  controls.nodes.add(
      new TextInputElement()
      ..id="dist-input"
      ..size=4
      ..placeholder="Distribution"
  );
  controls.nodes.add(
      new TextInputElement()
      ..id="colors-input"
      ..size=4
      ..placeholder="# Colors"
  );
}

void populate_output_area(DivElement controls) {
  controls.nodes.add(new BRElement());
  controls.nodes.add(
      new TextAreaElement()
      ..id="output-area"
      ..disabled=true
      ..cols=80
      ..rows=20
  );
}

void style_controls(DivElement controls) {
  controls.querySelectorAll('input[type="text"]').forEach((e) { 
    e.size=6;
    e.style.margin="2px";
  });
  controls.style.textAlign = 'center';
}

void populate_grid_controls(DivElement controls) {
  controls.nodes.add(new BRElement());
  controls.nodes.add(
      new LabelElement()
      ..text = "Torus: "
      ..htmlFor = "torus-check"
      ..style.lineHeight = "100%"
  );
  controls.nodes.add(
      new CheckboxInputElement()
      ..id="torus-check"
  );
  controls.nodes.add(new BRElement());
  controls.nodes.add(
      new LabelElement()
      ..text = "Diagonals: "
      ..htmlFor = "diagonal-check"
      ..style.lineHeight = "100%"
  );
  controls.nodes.add(
      new CheckboxInputElement()
      ..id="diagonal-check"
      ..onClick.listen((e) {
        String vis = querySelector('#diagonal-input').style.visibility;
        if (vis == "hidden") {
          querySelector('#diagonal-input').style.visibility = 'visible';
        }
        else {
          querySelector('#diagonal-input').style.visibility = 'hidden';
        }
      })
  );
  controls.nodes.add(
      new TextInputElement()
      ..id="diagonal-input"
      ..size=4
      ..placeholder="q"
      ..style.visibility = "hidden"
  );
}

void populate_random_controls(DivElement controls) {
  controls.nodes.add(
      new TextInputElement()
      ..id="degree-input"
      ..size=4
      ..placeholder="Degree"
  );
}

ResampleRenderer new_resample() {
  ResampleRenderer r;
  SelectElement graph_type = querySelector('#graphtype-input');
  switch (graph_type.selectedOptions.first.value) {
    case 'grid':
      r = new ResampleGridRenderer(querySelector('#canvas-area'), querySelector('#controls'), querySelector('#output-area'));
      break;
    case 'random':
      r = new ResampleRandomRenderer(querySelector('#canvas-area'), querySelector('#controls'), querySelector('#output-area'));
      break;
    default:
      r = new ResampleGridRenderer(querySelector('#canvas-area'), querySelector('#controls'), querySelector('#output-area'));
  }
  r.start();
  return r;
}
