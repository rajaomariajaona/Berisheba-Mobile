import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';

class NavigationItem {
  final String _title;
  final IconData _iconData;
  final VoidCallback _fn;
  final BuildContext _context;

  NavigationItem(this._context, this._title, this._iconData, this._fn);

  Widget get item => Flexible(
        flex: 1,
        child: Container(
          height: MediaQuery.of(_context).size.height * 0.2,
          child: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
              return AspectRatio(
                  aspectRatio: 1.0,
                  child: RaisedButton(
                    padding: EdgeInsets.all(0),
                    child: Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                          color: Config.acceuilNavItemColor,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                              flex: 7,
                              child: Icon(
                                _iconData,
                                color: Colors.white,
                                size: constraints.maxHeight * 0.5,
                              )),
                          Flexible(
                            flex: 3,
                            child: Text(
                              _title,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: _fn,
                  ));
            },
          ),
        ),
      );
}
