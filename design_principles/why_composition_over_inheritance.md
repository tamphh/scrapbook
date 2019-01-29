
On composition, a class, which desire to use functionality of an existing class, doesn't inherit, instead it holds a reference of that class in a member variable, that’s why the name composition. Inheritance and composition relationships are also referred as IS-A and HAS-A relationships.

Because of IS-A relationship, an instance of sub class can be passed to a method, which accepts instance of super class. This is a kind of Polymorphism, which is achieved using Inheritance.

1) One reason of favoring Composition over Inheritance in Java is fact that Java doesn't support multiple inheritance.

2) Composition offers better test-ability of a class than Inheritance. If one class is composed of another class, you can easily create Mock Object representing composed class for sake of testing.

3) Many object oriented design patterns mentioned by Gang of Four in there timeless classic Design Patterns: Elements of Reusable Object-Oriented Software, favors Composition over Inheritance.

4) Though both Composition and Inheritance allows you to reuse code, one of the disadvantage of Inheritance is that it breaks encapsulation. If sub class is depending on super class behavior for its operation, it suddenly becomes fragile. When behavior of super class changes, functionality in sub class may get broken, without any change on its part.

Source: https://javarevisited.blogspot.com/2013/06/why-favor-composition-over-inheritance-java-oops-design.html
