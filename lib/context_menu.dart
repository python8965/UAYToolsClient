import 'package:flutter/material.dart';

enum ContextMenuType { Text, User }

abstract class ContextMenuCallback {}

class TextContextMenuCallback implements ContextMenuCallback {
  final Function onEdit;
  final Function onReply;
  final Function onCopy;
  final Function onDelete;

  TextContextMenuCallback(
      {required this.onEdit,
      required this.onReply,
      required this.onCopy,
      required this.onDelete});
}

class AddMessageContextMenuCallback implements ContextMenuCallback {
  final Function onAddFile;

  AddMessageContextMenuCallback({required this.onAddFile});
}

class ContextMenuBuilder<T extends ContextMenuCallback> {
  final BuildContext context;
  final T contextMenuCallback;

  final RelativeRect? position;

  ContextMenuBuilder(
      {required this.context,
      required this.contextMenuCallback,
      this.position});

  void showContextMenu() {
    List<PopupMenuEntry<dynamic>> widgets = [];
    switch (contextMenuCallback) {
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

  List<PopupMenuEntry<dynamic>> _buildTextContextMenu(
      TextContextMenuCallback t) {
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

  void _showContextMenu(
      BuildContext context, List<PopupMenuEntry<dynamic>> widgets) {
    // The equivalent of the "smallestWidth" qualifier on Android.
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;

    if (useMobileLayout) {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //for the round edges
        builder: (context) {
          return
              //specify height, so that it does not fill the entire screen
              DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.0,
                  maxChildSize: 1.0,
                  expand: false,
                  snap: true,
                  snapSizes: [0.6, 1.0],
                  builder: (context, controller) {
                    return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                            controller: controller,
                            child: Column(children: [
                              // Container(
                              //   margin: const EdgeInsets.only(top: 8.0),
                              //   width: 30.0,
                              //   height: 3.0,
                              //   decoration: BoxDecoration(
                              //     color: Colors.grey,
                              //     borderRadius: BorderRadius.circular(24.0),
                              //   ),
                              // ),
                              SizedBox(
                                height: kMinInteractiveDimension,
                                width: kMinInteractiveDimension,
                                child: Center(
                                  child: Container(
                                    height: 4,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(32 / 2),
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              ...widgets
                            ])));
                  });
        },
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
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
