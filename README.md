#Back-On-Promise

NOTE: This project is still in development, and not production ready. Though hopefully soon it will be.

[Backbone](http://backbonejs.org/) allows you to communicate beteween models on the client and server.
Back-On-Promise is a library that wraps some of the Backbone methods (e.g. ```get```) to return promises for data.
A developer can then use these relationships transparently without worrying about whether the relationship has been synced or not.

Back-On-Promise is aiming to be usable in both a browser, and a node.js server. Back-On-Promise, its tests, and its examples are written in coffeescipt because typing ```function``` hundreds of times is not fun.

To install

```
npm install back-on-promise
```

##Examples
The easiest way to describe its features is to give a few examples based on creating a blog.

```
BOP = require 'back-on-promise'

class User extends BOP.BOPModel

class Post extends BOP.BOPModel

class Posts extends Backbone.Collection
  model: Post
```

BOP lets you define relationships between backbone models using the ```has 'attribute', Model, {options}``` function.
By default the relationship will be treated as a subdocument, e.g.

Given a ```Post``` looks like:

```
{
  name: 'FooBar Post',
  tags: [{name: 'foo'}, {name: 'bar'}]
}
```

This relationship is defined like:

```
class Tag extends Backbone.Model

class Tags extends Backbone.Collection

class Post extends BOP.BOPModel
  @has 'tags', Tags
```

NOTE: Tag does not have to be a BOPModel

Relationships between documents are defined by passing the option ```method: 'fetch'```, e.g.

```
class Posts extends Backbone.Collection
  url: -> 'http://user/#{@user.id}/posts
  model: Post

class User extends BOP.BOPModel
  @has 'posts', Posts, method: 'fetch', reverse: 'user'

user = new User(id: 1)
$.when(user.get('posts')).done( (posts) -> console.log posts)

```

Fetching the ```posts``` by calling ```get('posts')``` is expencive, so it returns a promise for the posts which can be handeled later.


#Development Goals
Testing and implementation of basic blog in node.


