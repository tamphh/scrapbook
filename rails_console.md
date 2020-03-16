### 1. Rolling Back After the End of a Session
It is possible to run the console in a mode called ```sandbox```. In that mode, every change made to the database will be automatically rolled back when the session terminates:
```sh
$ rails console --sandbox
```

### 2. Retrieving the Previous Execution Value
The result of the immediately previous console execution can be retrieved and, as the example suggests, assigned to a local variable by calling the ```_```:
```sh
>> Game.all.map(&:name)
=> ["zelda", "mario", "gta"]
>> names = _
=> ["zelda", "mario", "gta"]
```

### 3. Searching for Methods With grep
It is possible to find out the complete name of a method having only a part of it. By calling ```grep``` from ```Array```, one can execute a handy search over the methods of a given object:
```sh
>> Game.first.methods.grep(/lumn/)
Game Load (0.8ms)  SELECT  "games".* FROM "games" ORDER BY "games"."id" ASC LIMIT $1  [["LIMIT", 1]]
=> [:column_for_attribute, :update_column, :update_columns]
```

### 4. Finding Out a Method’s Location
The ```source_location``` method from the Object class returns the full path of a method’s file definition, including the line where it was defined. It can be especially useful when exploring third-party libraries:
```sh
>> 'Luis Vasconcellos'.method(:inquiry).source_location
=> ["/usr/local/bundle/gems/activesupport-5.2.1/lib/active_support/core_ext/string/inquiry.rb", 12]
```

### 5. Returning the Source Code of a Method
While it is interesting to know the exact location of a method, there are cases where it might be even better to output its source code directly to the console. This can be achieved by calling ```source``` from ```Object```:
```sh
>> 'Luis Vasconcellos'.method(:inquiry).source.display
def inquiry
    ActiveSupport::StringInquirer.new(self)
  end
=> nil
```

### 6. The Helper Object
The console provides an object called ```helper```, which can be used to directly access any view helper from a Rails application:
```sh
>> helper.truncate('Luis Vasconcellos', length: 9)
=> "Luis V..."
```

### 7. The App Object
The console also provides an interesting object called ```app```, which is basically an instance of your application. With this object, it’s possible to interact with your application as an HTTP client would, among other interesting things.
- Access to ```GET``` endpoints:
```sh
>> app.get('/')
Started GET "/" for 127.0.0.1 at 2018-08-25 22:46:52 +0000
   (0.5ms)  SELECT "schema_migrations"."version" FROM "schema_migrations" ORDER BY "schema_migrations"."version" ASC
Processing by HomeController#show as HTML
  Rendering home/show.html.erb within layouts/application
  Rendered home/show.html.erb within layouts/application (11417.2ms)
  Rendered shared/_menu.html.erb (3.6ms)
  Rendered shared/header/_autocomplete.html.erb (292.2ms)
  Rendered shared/_header.html.erb (312.9ms)
  Rendered shared/_footer.html.erb (3.7ms)
Completed 200 OK in 11957ms (Views: 11945.5ms | ActiveRecord: 0.0ms)
=> 200
```
- Access to POST endpoints:
```sh
>> app.post('/games/zelda/wishlist_placements.js')
Started POST "/games/zelda/wishlist_placements.js" for 127.0.0.1 at 2018-08-25 23:03:21 +0000
Processing by OwnlistPlacementsController#create as JS
  Parameters: {"game_slug"=>"zelda"}
  Game Load (0.6ms)  SELECT  "games".* FROM "games" WHERE "games"."slug" = $1 LIMIT $2  [["slug", "zelda"], ["LIMIT", 1]]
  Rendering wishlist_placements/create.js.erb
  Rendered wishlist_placements/create.js.erb (194.8ms)
Completed 200 OK in 261ms (Views: 252.9ms | ActiveRecord: 0.6ms)
=> 200
```
- Search for a _path helper from a Game route:
```sh
>> app.methods.grep(/_path/).grep(/game/)
=> [:search_games_path, :game_ownlist_placements_path, :game_ownlist_placement_path, :game_wishlist_placements_path, :game_wishlist_placement_path, :game_path]
```
- Combining the previous tricks in a more useful way:
```sh
>> app.get(app.root_path)
Started GET "/" for 127.0.0.1 at 2018-08-26 02:27:40 +0000
Processing by HomeController#show as HTML
  Rendering home/show.html.erb within layouts/application
  Rendered home/show.html.erb within layouts/application (12550.2ms)
  Rendered shared/_menu.html.erb (3.8ms)
  Rendered shared/header/_autocomplete.html.erb (1.2ms)
  Rendered shared/_header.html.erb (28.0ms)
  Rendered shared/_footer.html.erb (3.8ms)
Completed 200 OK in 12835ms (Views: 12810.0ms | ActiveRecord: 0.0ms)
=> 200
>> app.body.response
=> "\n<!DOCTYPE html>\n<html>\n  <head>\n    <title> ...
>> app.cookies
=> #<Rack::Test::CookieJar:0x0000556ee95c33e0 @default_host="www.example.com", @cookies=[#<Rack::Test::Cookie:0x0000556eeb72b2d0 @default_host="www.example.com", ...
```
Ref: https://medium.com/better-programming/rails-console-magic-tricks-da1fdd657d32
