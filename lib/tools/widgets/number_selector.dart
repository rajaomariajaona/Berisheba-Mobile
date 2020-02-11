import 'package:flutter/material.dart';

class NumberSelector extends StatefulWidget {
  NumberSelector({@required this.increment, @required this.decrement, @required this.value,this.min = 0, this.max, Key key}){
     assert(this.value >= this.min);
    if(this.max != null)
    assert(this.value <= this.max);
  }
  final int min;
  final int max;
  final int value;
  final VoidCallback increment;
  final VoidCallback decrement;
  @override
  _NumberSelectorState createState() => _NumberSelectorState();
}

class _NumberSelectorState extends State<NumberSelector> {
  bool _btnPressed = false;
  bool _inLoop = false;

  void decrementLoop(){
    if(_inLoop) return;
    _inLoop = true;
    while(_btnPressed){
      widget.decrement();
    }
    _inLoop = false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: (widget.min != null && widget.value <= widget.min) ? null : widget.decrement,
          icon: Icon(Icons.remove),
        ),
        Text("${widget.value}"),
        IconButton(
          onPressed: (widget.max != null && widget.value >= widget.max) ? null : widget.increment,
          icon: Icon(Icons.add),  
        ),
      ],
    );
  }
}
