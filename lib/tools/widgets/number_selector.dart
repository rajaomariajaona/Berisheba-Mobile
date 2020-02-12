import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            GlobalKey<FormState> _form = GlobalKey<FormState>();
            TextEditingController _controller = TextEditingController();
            var value = await showDialog(
              context: context,
              builder: (BuildContext ctx) {
                int number;
                return AlertDialog(
                  content: Form(
                    key: _form,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Min: ${widget.min} " + (widget.max == null ? "" : ", Max : ${widget.max}"),
                      ),
                      controller: _controller..text = "${widget.value}",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp("[0-9]+"))
                      ],
                      onSaved: (val) {
                        number = int.tryParse(val);
                      },
                      validator: (val) {
                        var test;
                        if(val.trim() == ""){
                          return "Champ vide";
                        }
                        if ((test = int.tryParse(val)) == null) {
                          return "La valeur n'est pas entière";
                        } else {
                          if (test > widget.max) {
                            _controller.text = "${widget.max}";
                            return "La valeur excède la valeur max";
                          }
                          if (test < widget.min) {
                            _controller.text = "${widget.min}";
                            return "La valeur excède la valeur min";
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        if (_form.currentState.validate()) {
                          _form.currentState.save();
                          Navigator.of(ctx).pop(number);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(ctx).pop(null);
                      },
                    ),
                  ],
                );
              },
            );
            if (value != null) {
              widget.setValue(value);
            }
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
