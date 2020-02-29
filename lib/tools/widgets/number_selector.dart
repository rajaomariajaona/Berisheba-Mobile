import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';

typedef SetValueCallback = void Function(int value);

class NumberSelector extends StatefulWidget {
  NumberSelector(
      {this.increment,
      this.decrement,
      @required this.value,
      @required this.setValue,
      this.min = 0,
      this.max,
      Key key}) {
    assert(this.value >= this.min);
    if (this.max != null) assert(this.value <= this.max);
  }
  final int min;
  final int max;
  final int value;
  final SetValueCallback setValue;
  final VoidCallback increment;
  final VoidCallback decrement;
  @override
  _NumberSelectorState createState() => _NumberSelectorState();
}

class _NumberSelectorState extends State<NumberSelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: (widget.min != null && widget.value <= widget.min)
              ? null
              : widget.decrement ?? () => widget.setValue(widget.value - 1),
          icon: Icon(Icons.remove),
        ),
        GestureDetector(
          child: Text("${widget.value}"),
          onTap: () async {
            Picker(
                    adapter: NumberPickerAdapter(data: [
                      NumberPickerColumn(
                          begin: widget.min,
                          end: widget.max,
                          initValue: widget.value),
                    ]),
                    hideHeader: true,

                    title: new Text("Veuillez selectionner"),
                    onConfirm: (Picker picker, List<int> values) {
                      widget.setValue(values[0]);
                    },
                    cancelText: "Annuler",
                    confirmText: "Confirmer")
                .showDialog(context);
          },
        ),
        IconButton(
          onPressed: (widget.max != null && widget.value >= widget.max)
              ? null
              : widget.increment ?? () => widget.setValue(widget.value + 1),
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
