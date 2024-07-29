# Flutter, what are Widgets, RenderObjects and Elements
## Ever wondered how Flutter takes those widgets and actually converts them to pixels on the screen?

Ever wondered how Flutter takes those widgets and actually converts them to pixels on the screen? No?

You should!

Understanding how an underlying technology works makes the difference between a good developer and a great one.

You can create custom layouts and special effects more easily when you know what works and what doesn’t; and knowing this will save you a few long nights at the keyboard.

The goal of this post is to introduce you to the world beyond the surface of flutter. We will take a look at different aspects of flutter and understand how it _actually_ works.

## Let’s get started

You probably already know how to use the StatelessWidget & StatefulWidget. But those widgets only compose the other widgets. Laying out the widgets and rendering them happens elsewhere.

**I highly recommend opening your favorite IDE and following along, seeing the structures in the actual code often creates those “aha” moments. In Intellij you can double tap shift and enter a class name to find it.**

## The Opacity

To get familiar with the basic concepts of how flutter works we will take a look at the [Opacity](https://github.com/flutter/flutter/blob/f38743593d00f13b21f49d8d8ee2d2206bf820d3/packages/flutter/lib/src/widgets/basic.dart#L150) widget and examine that. Because it’s a pretty basic widget, it makes a good example to follow along.

It only accepts one child. Therefore you can wrap any widget in an `Opacity` and change the way it’s displayed. Besides the child, there is only one parameter called `opacity` which is a value between 0.0 and 1.0. It controls the opacity (duh).

## The Widget

The `Opacity` is a `SingleChildRenderObjectWidget`.

**The hierarchy of extension class extensions goes like this:**

_Opacity → SingleChildRenderObjectWidget → RenderObjectWidget → Widget_

**In contrast, the StatelessWidget and StatefulWidget goes as follows:**

_StatelessWidget/StatefulWidget → Widget_

The difference lies in the fact that the Stateless/StatefulWidget only _compose_ widgets while the Opacity widget actually changes how the widget is drawn.

But if you look at any of those classes you won’t find any code related to actually painting the opacity.

That’s because a widget only holds the configuration information. In this case, the opacity widget is only holding the opacity value.

> This is the reason why you can create new widget every time the build function is called. Because the widgets are not expensive to construct. They are merely containers for information.

## The Rendering

But where **does** the rendering happen?

**It’s inside the RenderObjects**

As you might have guessed from the name, the RenderObject is responsible for a few things, including rendering.

The Opacity widget creates and updates a RenderObject with these methods.

```Dart
@override
RenderOpacity createRenderObject(BuildContext context) => new RenderOpacity(opacity: opacity);

@override
void updateRenderObject(BuildContext context, RenderOpacity renderObject) {
  renderObject.opacity = opacity;
}
```

[_source_](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/basic.dart#L188)

## RenderOpacity

The `Opacity` widget sizes itself to be exactly the same size as its child. It basically mimics every aspect of the child **but** the painting. Before painting its child it is adding an opacity to it.

In this case, the RenderOpacity needs to implement all the methods (for example performing layout/ hit testing/ computing sizes) and ask its child to do the actual work.

The `RenderOpacity` extends the `RenderProxyBox` (which mixes in a few other classes). Those are exactly implementing those methods and deferring the actual calculation to the only child.

```Dart
double get opacity => _opacity;
double _opacity;
set opacity(double value) {
  _opacity = value;
  markNeedsPaint();
}
```

_I removed a lot of assertions/ optimizations in this code. Take a look at the original for the full method._ [_source_](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/proxy_box.dart#L736)

Fields usually expose a getter to the private variable. And a setter, which in addition to setting the field, also calls `markNeedsPaint()` or `markNeedsLayout()`_._ As the name suggests, it tells the system “Hey I have changed, please repaint/relayout me”.

Inside the `RenderOpacity` we find this method:

```Dart
@override
void paint(PaintingContext context, Offset offset) {
    context.pushOpacity(offset, _alpha, super.paint);
}
```

_Again, removed optimization and assertions._ [_source_](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/proxy_box.dart#L757)

The `PaintingContext` is basically a fancy canvas. And on this fancy canvas there is a method called pushOpacity. _BINGO_.

This one line is the _actual_ opacity implementation.

## To recap

-   The `Opacity` is not a `StatelessWidget` or a `StatefulWidget` but instead a `SingleChildRenderObjectWidget`.
-   The `Widget` only holds information which the renderer can use.
-   In this case the `Opacity` is holding a double representing the opacity.
-   The `RenderOpacity`, which extends the `RenderProxyBox` does the actual layouting/ rendering etc.
-   Because the opacity behaves pretty much exactly as its child it delegates every method call to the child.
-   It overrides the paint method and calls _pushOpacity_ which adds the desired opacity to the widget.

## That’s it? Kind of.

Remember, the widget is only a configuration and the `RenderObject` only manages layout/rendering etc.

In Flutter you recreate widgets basically all the time. When your `build()` methods gets called you create a bunch of widgets. This build method is called every time something changes. When an animation happens for example, the build method gets called very often. This means you can’t rebuild the whole sub tree every time. Instead you want to update it.

> You can’t get the size or location on the screen of a widget, because a widget is like a blueprint, it’s not actually on the screen. It’s only a description of what variables the underlying render object should use.

**Introducing the Element**

The element is a concrete widget in the big tree.

**Basically what happens is:**

The first time when a widget is created, it is inflated to an `Element`. The element then gets inserted it into the tree. If the widget later changes, it is compared to the old widget and the element updates accordingly. The important thing is, the element doesn’t get rebuilt, it only gets updated.

Elements are a central part of the core framework and there is obviously more to them, but for now this is enough information.

## Where is the element created in the opacity example?

_Just a little paragraph for those who are curios._

The `SingleChildRenderObjectWidget` creates it.

```Dart
@override
SingleChildRenderObjectElement createElement() => new SingleChildRenderObjectElement(this);
```

[_source_](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/framework.dart#L1631)

And the `SingleChildRenderObjectElement` is just an Element which has single child.

## The element creates the RenderObject, but in our case the Opacity widget creates its own RenderObject?

This is just for a smooth API. Because more often then not, the widget needs a `RenderObject` but no custom `Element`. The `RenderObject` is actually created by the `Element`, let’s take a look:

```Dart
SingleChildRenderObjectElement(SingleChildRenderObjectWidget widget) : super(widget);
```

[_source_](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/framework.dart#L4643)

The `SingleChildRenderObjectElement` gets a reference to the `RenderObjectWidget` (which has the methods to create a `RenderObject`).

The mount method is the place where the element gets inserted into the element tree, and here the magic happens (RenderObjectElement class):

```Dart
@override
void mount(Element parent, dynamic newSlot) {
  super.mount(parent, newSlot);
  _renderObject = widget.createRenderObject(this);
  attachRenderObject(newSlot);
  _dirty = false;
}
```

_(Right after super.mount(parent,newSlot);_ [_source_](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/framework.dart#L4287)

Only once (when it get’s mounted) it asks the widget “Please give me the renderobject you’d like to use so I can save it”.

source: https://medium.com/flutter-community/flutter-what-are-widgets-renderobjects-and-elements-630a57d05208
