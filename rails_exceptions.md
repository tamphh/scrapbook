# The list of built-in exception subclasses on Ruby 2.5 looks like this:
```
- NoMemoryError 
- ScriptError 
    - LoadError 
    - NotImplementedError 
    - SyntaxError 
- SecurityError 
- SignalException 
    - Interrupt 
- StandardError (default for `rescue`) 
    - ArgumentError 
      - UncaughtThrowError 
    - EncodingError 
    - FiberError 
    - IOError 
      - EOFError 
    - IndexError 
      - KeyError 
      - StopIteration 
    - LocalJumpError 
    - NameError 
      - NoMethodError 
    - RangeError 
      - FloatDomainError 
    - RegexpError 
    - RuntimeError (default for `raise`) 
    - SystemCallError 
      - Errno::* 
    - ThreadError 
    - TypeError 
    - ZeroDivisionError 
- SystemExit 
- SystemStackError 
- fatal (impossible to rescue)
```