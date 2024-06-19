abstract class Model {}

class User extends Model {}

mixin Shareable {
  void share(String content) {
    print('Share the $content');
  }
}

class Post extends Model with Shareable {}

class Comment extends Model with Shareable {}

class Video with Shareable {}

void main() {
  Post().share('The first post.');

  Comment().share('My first comment.');

  Video().share('My video');
}