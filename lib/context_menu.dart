


import 'package:flutter/material.dart';


enum ContextMenuType{
  Text,
  User
}

abstract class ContextMenuCallback{

}

class TextContextMenuCallback implements ContextMenuCallback{
  final Function onEdit;
  final Function onReply;
  final Function onCopy;
  final Function onDelete;

  TextContextMenuCallback({required this.onEdit, required this.onReply, required this.onCopy, required this.onDelete});

}

class ContextMenuBuilder<T extends ContextMenuCallback>{
  final BuildContext context;
  final T contextMenuCallback;

  final RelativeRect? position;

  ContextMenuBuilder({required this.context, required this.contextMenuCallback, this.position});


  void showContextMenu(){
    List<PopupMenuEntry<dynamic>> widgets = [];
    switch (contextMenuCallback){

      case TextContextMenuCallback t:
        widgets = _buildTextContextMenu(t);
    // TODO: Handle this case.
      default:
        //Cannot Reach
        throw Exception("Type Error");
      // TODO: Handle this case.
    }

    _showContextMenu(context, widgets);
  }

  List<PopupMenuEntry<dynamic>> _buildTextContextMenu(TextContextMenuCallback t){


    return [
      PopupMenuItem(
        value: 1,
        child: Text("채팅 수정하기"),
        onTap: () => t.onEdit(),
      ),
      PopupMenuItem(
        value: 1,
        child: Text("답장하기"),
        onTap: () => t.onReply(),
      ),
      PopupMenuItem(
        value: 1,
        child: Text("채팅 복사하기"),
        onTap: () => t.onCopy(),
      ),
      PopupMenuDivider(),
      PopupMenuItem(
        value: 1,
        child: Text("채팅 삭제하기"),
        onTap: () => t.onDelete(),
      ),
    ];
  }

  void _showContextMenu(BuildContext context, List<PopupMenuEntry<dynamic>> widgets) {
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;

    if (useMobileLayout) {

      showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), //for the round edges
        builder: (context) {

          return Container(
            //specify height, so that it does not fill the entire screen
              child: Column(children: widgets) //what you want to have inside, I suggest using a column
          );
        },
        isDismissible: true,
        isScrollControlled: true,
      );
    } else {
      showMenu(
        context: context,

        position: position ?? RelativeRect.fill,
        items: widgets,
        popUpAnimationStyle: AnimationStyle.noAnimation,
        elevation: 8.0,
      );
    }
  }
}

