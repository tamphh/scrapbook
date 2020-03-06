## Strftime

Formats date according to the directives in the given format string. The directives begins with a percent (%) character. Any text not listed as a directive will be passed through to the output string.

Syntax : ```strftime( format )```
```ruby
t.strftime("%H")  => "19"      # Hour of the time in 24 hour clock format
t.strftime("%I")  => "07"      # Hour of the time in 12 hour clock format
t.strftime("%M")  => "29"      # Minutes of the time
t.strftime("%S")  => "38"      # Seconds of the time
t.strftime("%Y")  => "2017"    # Year of the time
t.strftime("%m")  => "10"      # month of the time
t.strftime("%d")  => "06"      # day of month of the time
t.strftime("%w")  => "5"       # day of week of the time
t.strftime("%a")  => "Fri"     # name of week day in short form of the
t.strftime("%A")  => "Friday"  # week day in full form of the time
t.strftime("%b")  => "Oct"     # month in short form of the time
t.strftime("%B")  => "October" # month in full form of the time
t.strftime("%y")  => "17"      # year without century of the time
t.strftime("%Z")  => "UTC"     # Time Zone of the time
t.strftime("%p")  => "PM"      # AM / PM of the time
```
Ref: https://apidock.com/ruby/DateTime/strftime

## Strptime: parse a string into a DateTime object. Controlled.

Just as you can format a string from a Time object with ```Time#strftime```, you can also parse a string in a defined format into a ```DateTime``` or ```Date``` object, using ```DateTime#strptime``` or ```Date#strptime``` respectively (```Date#strptime``` only creates a date without the time, though).

```ruby
require 'date'

parsed_time = DateTime.strptime('03/05/2010 14:25:00', '%d/%m/%Y %H:%M:%S')

parsed_time.to_s
=> "2010-05-03T14:25:00+00:00"
```

See the docs for more info: DateTime#strptime and Date#strptime.
