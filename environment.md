#### ***Problem:*** dyld: Library not loaded: /usr/local/opt/icu4c/lib/libicui18n.62.dylib
***Solution***: switch to appropriate version
```sh
brew switch icu4c 62.1
```
#
#### qt brew
```/usr/local/opt/qt@5.5/.brew```

#### Fix error while installing mysql2
For ex: ```mysql2 -v '0.4.10'```
```sh
brew install openssl
gem install mysql2 -v '0.4.10' -- --with-opt-dir="$(brew --prefix openssl)"
```
#
#### ***Problem:*** xcode-select: error: tool ‘xcodebuild’ requires Xcode, but active developer directory ‘/Library/Developer/CommandLineTools’ is a command line tools instance
***Solution***
```sh
xcode-select --install # Install Command Line Tools if you haven't already.
sudo xcode-select --switch /Library/Developer/CommandLineTools # Enable command line tools
sudo xcodebuild -license accept
```
#
#### ***Problem:*** Sometimes, there're some gems conflicted among versions while in the middle of bundle installing.
***Solution***
We could remove the specs for conflicted gem.
For ex: There's conflict for ```mysql2-0.4.10```
```sh
rm ~/.rvm/gems/ruby-2.4.3@tinypulse/specifications/mysql2-0.4.10.gemspec
```
Then re-execute ```bundle install```.
