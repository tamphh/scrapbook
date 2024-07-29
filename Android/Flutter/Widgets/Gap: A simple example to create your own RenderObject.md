# Gap: A simple example to create your own RenderObject
### Romain Rastel

I love how Flutter is designed. The combination of immutables objects, the `Widgets` and mutables ones called `RenderObjects` is very powerful although not super intuitive for beginners.

We can do a lot just by composing widgets with `StatelessWidgets` and `StatefulWidgets`, but we cannot do everything, or not in an efficient way. That’s why you need to understand how to create your own `RenderObject` when it’s necessary.  
In this post I will not explain what is the difference between a `Widget` and a `RenderObject` but I will show you how I created a simple `RenderObject` in order for you to do the same when you need it. If you want to know more about `Widgets`, `Elements` and `RenderObjects` before reading this, I advise you to read this excellent [article](https://medium.com/flutter-community/flutter-what-are-widgets-renderobjects-and-elements-630a57d05208) of [Norbert](https://medium.com/u/aca5101434f?source=post_page-----88eacca2a4--------------------------------).

## Some context

Last week I was fed up with adding gaps between my widgets in some `Columns` and `Rows`. I use `SizedBoxes` for that, but we need to specify the width or the height depending on whether we are inside a `Column` or a `Row`. I don’t find this very productive so I ended up creating my own `RenderObject` for that. I called the underlaying widget `**Gap**`!

_Fun fact_ 🙃_: Three days after I started to work on this widget, I saw this tweet in my TL:_

_I was very amused by the timing! I read the_ [_article_](https://medium.com/@eibaan_54644/adding-a-gap-to-flutter-e4277715b6a5) _of_ [_Stefan Matthias Aust_](https://medium.com/u/38d0d8a11fad?source=post_page-----88eacca2a4--------------------------------) _where he explains how he created a Gap widget with pretty much the same implementation than mine. I will try to make a different analyze_ 😉_._

The following code is the prototype of my widget. I think it’s simple enough to explain how to easily create a new `Widget` and its associated`RenderObject`.

## The RenderObject

The `RenderObject` is the piece of code responsible of computing the layout and paint it to the screen. I start with the render layer, because it’s completely independent from the widget layer.

There are (for the moment) two kinds of `RenderObjects`: `RenderBoxes` and `RenderSlivers`.

To know which of them you must extend, it’s pretty simple: If your component needs to be aware of the scroll constraints (for a scroll effect or because it needs to be in a scroll container), the `RenderObject` must extend `RenderSliver`, otherwise it must extend `RenderBox`.  
**Pro tip** 💪: In most of the cases you want a `RenderBox` 😉.

In our context, the parent of our widget will be a `Flex` widget, which only understands `RenderBoxes`, so we don’t even have a choice, our `RenderObject` must extend `RenderBox`.
```Dart
class _RenderGap extends RenderBox {
  _RenderGap({
    double mainAxisExtent,
  }) : _mainAxisExtent = mainAxisExtent;

  double get mainAxisExtent => _mainAxisExtent;
  double _mainAxisExtent;
  set mainAxisExtent(double value) {
    if (_mainAxisExtent != value) {
      _mainAxisExtent = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final AbstractNode flex = parent;
    if (flex is RenderFlex) {
      if (flex.direction == Axis.horizontal) {
        size = constraints.constrain(Size(mainAxisExtent, 0));
      } else {
        size = constraints.constrain(Size(0, mainAxisExtent));
      }
    } else {
      throw FlutterError(
        'A Gap widget must be placed directly inside a Flex widget',
      );
    }
  }
}
```
Our `RenderGap` have only one property called `mainAxisExtent`. This is the extent of our gap in the direction of its parent: if the widget’s parent is a `Column`, then this is the height and if it’s a `Row` then it represents the width.

We set the `mainAxisExtent` at the creation and we can update it with the associated setter. This setter makes a call to `markNeedsLayout`, which tells the framework that it needs to re-run the `performLayout` method before rendering the frame.

But what it this `performLayout` method? As its name indicates, it’s the method responsible for computing the layout of our component. In the case of a `RenderBox`, it does so by setting its `size` property.  
In this method we know that the constraints are already computed and we can use them to determine our size.

As I mentioned before, the parent of our widget is either a `Column` or a `Row`. Both of them extend `Flex` and the associated `RenderObject` of a `Flex` is a `RenderFlex`.  
We want our `RenderGap` to only work if the parent is a `RenderFlex`, so this is the first thing we do in the `performLayout` method. Then we look at the `direction` of its parent to know how to compute the `size`. If it’s `Axis.horizontal`, then we are in a `Row`, and we want the `size` to have a `width` of the value of our `mainAxisExtent`, and a height of 0. But we need to constrain our requested size with the constraints imposed by the parent. If the `Gap` is the direct child of a `Row`, it will not be constrained horizontally (`maxWidth` will have an infinite value), but if there is a `Flexible` between the `Row` and the `Gap`, then the `maxWidth` constrain will have a finite value, and thus we have to take into account this constraint. This is the meaning of `constraints.constrain(Size(mainAxisExtent, 0));`.

Oh wait, didn’t I tell you that the parent of a `Gap` must be a `Flex` widget before? Then how a `Flexible` can be between a `Row` and a `Gap`??  
Well, I wasn’t totally precise. I should have written that the direct parent of a `RenderGap` must be a `RenderFlex` but the direct parent of a `Gap` is not necessarily a `Flex` widget.  
This can be possible because there are widgets which are not visible and thus don’t need to be tied up with a `RenderObject`.  
This is the case for example with the `Flexible` widget. If we look at the code we can see that `Flexible` extends `ParentDataWidget<Flex>` and it does not create any `RenderObject`.

This is all for the `RenderObject`. We don’t even need to override the `paint` method because we don’t want to paint anything, we just want to tell the framework that our component takes some place and that’s it.

To fully respect the `RenderObject` contract we should also implement other methods such as `computeMinIntrinsicWidth`, but we will stop here for now.

## The Widget

We already have our `RenderObject`, now we need to create a specific widget in order to add it to the `build` method of another widget. Our widget must extend `RenderObjectWidget` since it’s associated with a `RenderGap`. If we don’t want to manage the children ourselves, we can use one of the three out-of-the-box classes depending on the number of children the widget can take:

-   For zero children the widget must extends `LeafRenderObjectWidget`.
-   For one child the widget must extends `SingleChildRenderObjectWidget`.
-   For two or more children the widget must extends `MultiChildRenderObjectWidget`.

In our case, the `Gap` widget has no children, that’s why `Gap` extends `LeafRenderObjectWidget`.

There are two methods to override when we extend `RenderObjectWidget`:

-   `createRenderObject`: this method is called the first time the widget is added to the widget tree. It must return a new instance of the associated`RenderObject` populated with the properties set or computed from the widget.
-   `updateRenderObject`: this method is called every time the widget is updated. It must update the previous instance of the associated `RenderObject` with the properties set or computed from the widget.

In our case, the code is very simple since we have only one property to pass to the `RenderObject`.
```Dart
class Gap extends LeafRenderObjectWidget {
  const Gap(
    this.mainAxisExtent, {
    Key key,
  })  : assert(mainAxisExtent != null &&
            mainAxisExtent >= 0 &&
            mainAxisExtent < double.infinity),
        super(key: key);

  final double mainAxisExtent;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGap(mainAxisExtent: mainAxisExtent);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderGap renderObject) {
    renderObject.mainAxisExtent = mainAxisExtent;
  }
}
```
Our `RenderGap` needs a `mainAxisExtent`, so our widget also needs to have a `mainAxisExtent` property in order to be set within a `build` method.

And that’s it, this is the only things we have to do for the widget layer.

## Example

This is a small example of this widget for testing it. Enjoy!

## Conclusion

This was a very simple widget which uses directly a `RenderObject` behind the scene. I made it a package downloadable on [pub.dev](https://pub.dev/packages/gap) if you find it useful. The code of the package is a little more complex because I added some options to allow the `Gap` to set its own `crossAxisExtent` and a `color`. Feel free to look at the full [code](https://github.com/letsar/gap/blob/master/lib/gap.dart) on GitHub.

The rendering world is beautiful, but it can be difficult to understand, you’ll have to start with simple use cases and add complexity step by step.

source: https://romain-rastel.medium.com/gap-a-simple-example-to-create-your-own-renderobject-88eacca2a4
