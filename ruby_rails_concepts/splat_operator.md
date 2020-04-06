### Single splat ```*args```:
- to handle an undefined number of arguments in ruby we have a parameter with the splat operator (*)
- a parameter with the splat operator takes only those arguments for which there were no other parameters
- a parameter with the splat operator is optional
- a parameter with the splat operator the arguments to an array
- if we do not pass any arguments for a parameter with the splat operator then a local variable within a method will reference to an empty array
- the arguments are passed in the same order in which they are specified when a method is called.
- a method can’t have two parameters with splat operator at the same time
source: https://medium.com/@sologoubalex/parameter-with-splat-operator-in-ruby-part-1-2-a1c2176215a5

### Double splat ```**args```:
- in ruby, we can define a parameter with the double splat operator (**)
- this type of parameter created specifically for processing hashes
- parameter with double splat operator is optional
- works only with one hash
- must be the last parameter in a parameter list, in another case we will see an error
- the rule of the last hash parameter is also valid for a parameter with the double splat operator
- keyword parameter plus parameter with double splat operator are compatible
source: https://medium.com/@sologoubalex/parameter-with-double-splat-operator-in-ruby-d944d234de34
