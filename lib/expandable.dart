// A library of Flutter widgets that allow creating expandable panels
library expandable;

import 'package:flutter/material.dart';
import 'dart:math';

/// Makes an [ExpandableController] available to the widget subtree.
/// Useful for making multiple [Expandable] widgets synchronized with a single controller.
class ExpandableNotifier extends InheritedNotifier<ExpandableController> {
  ExpandableNotifier(
      {
      // An optional key
      Key key,

      /// If the controller is not provided, it's created with the initial state of collapsed.
      ExpandableController controller,
      @required

          /// The child can be any widget which contains [Expandable] widgets in its widget tree.
          Widget child})
      : super(key: key, notifier: controller ?? ExpandableController(), child: child);
}

/// Controls the state (expanded or collapsed) of one or more [Expandable].
/// The controller should be provided to [Expandable] via [ExpandableNotifier].
class ExpandableController extends ValueNotifier<bool> {
  /// Returns [true] if the state is expanded, [false] if collapsed.
  bool get expanded => value;

  ExpandableController([expanded = false]) : super(expanded);

  /// Sets the expanded state.
  set expanded(bool exp) {
    value = exp;
  }

  /// Sets the expanded state to the opposite of the current state.
  void toggle() {
    expanded = !expanded;
  }

  static ExpandableController of(BuildContext context, {bool rebuildOnChange = true}) {
    final notifier = rebuildOnChange
        ? context.inheritFromWidgetOfExactType(ExpandableNotifier)
        : context.ancestorWidgetOfExactType(ExpandableNotifier);
    return (notifier as ExpandableNotifier).notifier;
  }
}

/// Shows either the expanded or the collapsed child depending on the state.
/// The state is determined by an instance of [ExpandableController] provided by [ScopedModel]
class Expandable extends StatelessWidget {
  /// Whe widget to show when collapsed
  final Widget collapsed;

  /// The widget to show when expanded
  final Widget expanded;

  /// If the controller is not specified, it will be retrieved from the context
  final ExpandableController controller;

  /// Animation duration
  final Duration animationDuration;
  final double collapsedFadeStart;
  final double collapsedFadeEnd;
  final double expandedFadeStart;
  final double expandedFadeEnd;
  final Curve fadeCurve;
  final Curve sizeCurve;

  Expandable(
      {Key key,
      this.collapsed,
      this.expanded,
      this.controller,
      /// The point in the cross-fade animation timeline (from 0 to 1)
      /// where the [collapsed] and [expanded] widgets are half-visible.
      ///
      /// If set to 0, the [expanded] widget will be shown immediately in full opacity
      /// when the size transition starts. This is useful if the collapsed widget is
      /// empty or if dealing with text that is shown partially in the collapsed state.
      ///
      /// If set to 0.5, the [expanded] and the [collapsed] widget will be shown
      /// at half of their opacity in the middle of the size animation with a
      /// cross-fade effect throughout the entire size transition. This is the default value.
      ///
      /// If set to 1, the [expanded] widget will be shown at the very end of the size animation.
      ///
      /// When collapsing, the effect of this setting is reversed. For example, if the value is 0
      /// then the [expanded] widget will remain to be shown until the end of the size animation.
      double crossFadePoint = 0.5,
      @deprecated
      double collapsedFadeStart,
      @deprecated
      double collapsedFadeEnd,
      @deprecated
      double expandedFadeStart,
      @deprecated
      double expandedFadeEnd,
      this.fadeCurve = Curves.linear,
      this.sizeCurve = Curves.fastOutSlowIn,
      this.animationDuration = const Duration(milliseconds: 300)})
      :
      this.collapsedFadeStart = collapsedFadeStart ?? crossFadePoint < 0.5 ? 0 : (crossFadePoint * 2 - 1),
      this.collapsedFadeEnd = collapsedFadeEnd ?? crossFadePoint < 0.5 ? 2 * crossFadePoint : 1,
      this.expandedFadeStart = expandedFadeStart ?? crossFadePoint < 0.5 ? 0 : (crossFadePoint * 2 - 1),
      this.expandedFadeEnd = expandedFadeEnd ?? crossFadePoint < 0.5 ? 2 * crossFadePoint : 1,
      super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ?? ExpandableController.of(context);
    return AnimatedCrossFade(
      firstChild: collapsed ?? Container(),
      secondChild: expanded ?? Container(),
      firstCurve: Interval(collapsedFadeStart, collapsedFadeEnd, curve: fadeCurve),
      secondCurve: Interval(expandedFadeStart, expandedFadeEnd, curve: fadeCurve),
      sizeCurve: sizeCurve,
      crossFadeState: controller.expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: animationDuration,
    );
  }
}

typedef Widget ExpandableBuilder(BuildContext context, Widget collapsed, Widget expanded);

/// Determines the placement of the expand/collapse icon in [ExpandablePanel]
enum ExpandablePanelIconPlacement {
  /// The icon is on the left of the header
  left,

  /// The icon is on the right of the header
  right,
}

/// Determines the alignment of the header relative to the expand icon
enum ExpandablePanelHeaderAlignment {
  /// The header and the icon are aligned at their top positions
  top,

  /// The header and the icon are aligned at their center positions
  center,

  /// The header and the icon are aligned at their bottom positions
  bottom,
}

/// A configurable widget for showing user-expandable content with an optional expand button.
class ExpandablePanel extends StatefulWidget {
  /// If specified, the header is always shown, and the expandable part is shown under the header
  final Widget header;

  /// The widget shown in the collapsed state
  final Widget collapsed;

  /// The widget shown in the expanded state
  final Widget expanded;

  /// If true then the panel is expanded initially
  final bool initialExpanded;

  /// If true, the header can be clicked by the user to expand
  final bool tapHeaderToExpand;

  /// If true, the body can be clicked by the user to collapse
  final bool tapBodyToCollapse;

  /// If true, Expand icon is shown on the right
  final bool hasIcon;

  /// Builds an Expandable object
  final ExpandableBuilder builder;

  /// Expand icon placement
  final ExpandablePanelIconPlacement iconPlacement;

  // Expand icon color
//  final Color iconColor;

  /// Alignment of the header widget relative to the icon
  final ExpandablePanelHeaderAlignment headerAlignment;

  static Widget defaultExpandableBuilder(BuildContext context, Widget collapsed, Widget expanded) {
    return Expandable(
      collapsed: collapsed,
      expanded: expanded,
      crossFadePoint: 0,
    );
  }

  ExpandablePanel({
    Key key,
    this.collapsed,
    this.header,
    this.expanded,
    this.initialExpanded = false,
    this.tapHeaderToExpand = true,
    this.tapBodyToCollapse = false,
    this.hasIcon = true,
    this.iconPlacement = ExpandablePanelIconPlacement.right,
//    this.iconColor, // The default color is based on the theme
    this.builder = defaultExpandableBuilder,
    this.headerAlignment = ExpandablePanelHeaderAlignment.top,
  }) : super(key: key);

  @override
  _ExpandablePanelState createState() => _ExpandablePanelState();
}

class _ExpandablePanelState extends State<ExpandablePanel> {
  ExpandableController expandableController;

  @override
  void initState() {
    super.initState();
    expandableController = ExpandableController(widget.initialExpanded);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildHeaderRow(Widget child) {
      if (!widget.hasIcon) {
        return child;
      } else {
        final rowChildren = <Widget>[
          Expanded(
            child: child,
          ),
//          ExpandableIcon(color: widget.iconColor,),
          ExpandableIcon(),
        ];
        return Row(
          crossAxisAlignment: calculateHeaderCrossAxisAlignment(),
          children:
              widget.iconPlacement == ExpandablePanelIconPlacement.right ? rowChildren : rowChildren.reversed.toList(),
        );
      }
    }

    Widget buildHeader(Widget child) {
      return widget.tapHeaderToExpand ? ExpandableButton(child: child) : child;
    }

    Widget buildBody(Widget child) {
      return widget.tapBodyToCollapse ? ExpandableButton(child: child) : child;
    }

    Widget buildWithHeader() {
      return Column(
        children: <Widget>[
          buildHeaderRow(buildHeader(widget.header)),
          widget.builder(context, widget.collapsed, buildBody(widget.expanded))
        ],
      );
    }

    Widget buildWithoutHeader() {
      return buildHeaderRow(widget.builder(context, buildHeader(widget.collapsed), buildBody(widget.expanded)));
    }

    return ExpandableNotifier(
      controller: expandableController,
      child: this.widget.header != null ? buildWithHeader() : buildWithoutHeader(),
    );
  }

  CrossAxisAlignment calculateHeaderCrossAxisAlignment() {
    switch (widget.headerAlignment) {
      case ExpandablePanelHeaderAlignment.top:
        return CrossAxisAlignment.start;
      case ExpandablePanelHeaderAlignment.center:
        return CrossAxisAlignment.center;
      case ExpandablePanelHeaderAlignment.bottom:
        return CrossAxisAlignment.end;
    }
    assert(false);
    return null;
  }
}

/// An down/up arrow icon that toggles the state of [ExpandableController] when the user clicks on it.
/// The model is accessed via [ScopedModelDescendant].
class ExpandableIcon extends StatelessWidget {

  final Color color;

  ExpandableIcon({this.color});

  @override
  Widget build(BuildContext context) {
    final controller = ExpandableController.of(context);
    return ExpandIcon(
//      color: color,
      isExpanded: controller.expanded,
      onPressed: (exp) {
        controller.toggle();
      },
    );
  }
}

/// Toggles the state of [ExpandableController] when the user clicks on it.
class ExpandableButton extends StatelessWidget {
  final Widget child;

  ExpandableButton({this.child});

  @override
  Widget build(BuildContext context) {
    final controller = ExpandableController.of(context);
    return InkWell(
        onTap: () {
          controller.toggle();
        },
        child: child);
  }
}
