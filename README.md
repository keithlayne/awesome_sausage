# AwesomeSausage

A small (and perhaps slightly opinionated) library to address some pet peeves
with ActiveRecord and Arel.

## Motivation

### Boring Story

ActiveRecord and Arel are great.  When I started using Ruby and Rails, I
knew very little about RDBs, and I had little interest in learning everything
about every different flavor of SQL...I want my ORM to handle all that jazz.
I was writing Rails apps that were mostly CRUDdy (pun intended) and I was
happy, because I could follow the pattern established by every other Rails
CRUD app without dealing with any DB details.  Life was good.

Later I found myself working on a Rails project that was decidedly outside
the CRUD sweet spot.  It eschewed all the conventions that make Rails so easy
to use, especially with the database.  It had ActiveRecord "models" that
had thousands of lines of raw SQL.  And oh yeah, it used MySQL, so good
luck to me if I ever wanted to use a different DB implementation.  Life was
suddenly not so good.

What I had was a mess that was pretty much impossible to maintain or modify.
I started digging in anyway, trying to abstract some of the queries into
some pieces that I could compose and make into a more manageable mess.  To
do this, I needed to be able to replicate some of the craziness in the
handwritten SQL.  I found ActiveRecord and Arel to be lacking in this
department.

### What I really want

1.  **Simple, common things should be easy**

    Really, ActiveRecord?  There's no way to do a query with an `OR` in it 
    without resorting to Arel?  I'm disappointed.  Want to test for 
    `NOT NULL`?  Too bad, use Arel or write it in a string.  Want to do a
    `LEFT OUTER JOIN` without ActiveRecord doing crazy shenanigans behind
    your back?  More of the same.

1.  **No strings attached**

    Okay, so I can do anything I can do in SQL by using...SQL.  Doesn't seem
    like a big win to me.  As soon as you resort to raw SQL in a string,
    you're pretty much tossing the free Arel goodies like quoting column
    names right out the window, which won't help if you switch DBs.
    
    On top of that, AR/Arel give you nice SQL injection protection with the 
    `?` thing in SQL strings, but I **never** use this feature.  It's ugly to
    me (I don't like strings, after all) and it moves the value you want to 
    use away from the point of use, which I don't like.

1.  **Fail fast**

    This really is related to the previous entry...how do you find out that
    there is a typo in your SQL?  The query fails.  Can't we do better?
    
    We may not be able to do a ton better without static typing and a compile
    step, but at least we can get meaningful errors from Ruby instead of the
    DB engine in some cases by using a more DSL-like approach.

1.  **No magic**

    "Convention over Configuration" (I get that backwards all the time) is
    really cool and all, but I think it leads to a Great and Powerful Oz
    situation...there's a lot of stuff going on behind the scenes that the
    average person doesn't know about. I think that of all the Rails source
    code I've read (nowhere near all of it), ActiveRecord queries and
    relations code is some of the most difficult to follow.
    
    I count it as a major plus that Rails source code is so accessible and
    Ruby in general reads easily.  However, "You have to go read the Rails
    source to know what's going on" is not something a newcomer can easily do.
    
    Arel is an entirely different animal.  It's part of Rails, but the only
    real documentation I've found is in the API docs and a few random blog
    posts.  It is really powerful in some ways, but unless you know the magic
    incantations it's hard to use.

1.  **Support for standard SQL concepts**

    Arel only implements the features that are common and standard or
    something like that [[citation needed]]().  I don't intend to read any of
    the ANSI SQL standards, but I know that Arel is lacking here.  An example
    that is pretty common in the SQL I inherited is use of `CASE WHEN...`.
    This is included in the ANSI standard (so I've heard) and is implemented
    by every RDB vendor I'm aware of (not too many).
    
    This library should be a repository of standard stuff like this that can
    be implemented in terms of a decent DSL for every supported RDB
    implementation, even if the generated SQL is different.  You know, kind of
    like Arel is supposed to do... 

1.  **Less verbosity**

    Arel's syntax is a pretty effective deterrent from using it in all of your
    queries.  This library should harness the SQL-fu of Arel while making it
    **much** nicer to read and write.
    
    Here's an example of Arel in practice:
    
    ```ruby
    Foo.select(Foo.arel_table[::Arel.star]).where(Foo.arel_table[:bar].not_eq nil)
    ```
        
    And with AwesomeSausage:
    
    ```ruby
    Foo.select(Foo.*).where(Foo.bar != nil)
    ```
    
    One of the downsides of Ruby is its über-OO approach...operators are actually
    methods, and Ruby only exposes certain overridable infix methods.  If we could
    define arbitrary infix methods, we could make a totally sweet DSL.  But we
    can't so we will make use of the overridable infix methods where it makes
    sense and follows the semantics you'd expect from those operators.
    
    One shortcoming of the DSL syntax is that one cannot override the logical
    operators (as in `&&` and `||`).  Ideally we'd want something just like those
    because they have the precedence rules we want.  We could override the bitwise
    operators, but then the syntax starts diverging from the target language and
    would need to be explicitly parenthesized.  Bummer.

1.  **Strict opt-in**

    I'm not a big fan of monkey-patches.  I think they often obscure what's
    really happening and can really make debugging harder.  My preference is
    that if you want to modify something as ubiquitous as the Arel node types
    or ActiveRecord::Base, you should do so in a way that is obvious to the
    reader without having to grep through the whole project, or looking at any
    other files, for that matter.

## What's up with the name?

I make up words all the time.  Don't judge me!  No really, I think I use the 
word 'awesome' in the title of every library I write.  I guess you could say
that I'm obsessed with being awesome.  And delusional.

AwesomeSausage is a play on AwesomeSauce, which is probably already a gem.
But wait, there's more!  Most of us don't really want to know how sausage is
made, we just want to enjoy the end product.  Much like an ORM - we don't want
to dig into the gory details and syntax of the innards (Arel in this case), we
would like it all wrapped up and ready to consume.  Make sense now?

## Why not use one of the other similar gems out there?

I looked at several, and I hastily decided that I didn't like any of them for
one reason or another.  Mostly it had to do with things like imbuing symbols
with magical powers in queries and subtly changing AR semantics just by using
a gem.

## Dependencies

AwesomeSausage's only runtime dependency is ActiveRecord.  I haven't yet nailed
down which versions of AR will be supported, with which versions and
implementations of Ruby, etc.  The original ideas for this library came while
working on a Rails 3.2.x project using Ruby MRI 1.9.3 - 2.1.0, so you can
expect it to work with those combinations.

## Database Support

Again, the original motivation for this library came while working on a project
using MySQL.  The initial cut will probably be MySQL-specific, but the goal
is to eventually map the common RDB concepts that aren't easily done with Arel
to all of the DBs that ActiveRecord supports.

## Installation

Add this line to your application's Gemfile:

    gem 'awesome_sausage'

And then execute:

    $ bundle

## Usage

Here's a little example setup to demonstrate some features of AwesomeSausage (if you clone and run bundler, you can try this with `pry --gem`):

```ruby
> require 'sqlite3'
> db = SQLite3::Database.new 'test.db'
> db.execute('create table foos (id INTEGER, bar DOUBLE, name TEXT)')
> ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: 'test.db'
> class Foo < ::ActiveRecord::Base; include AwesomeSausage::ActiveRecord; end
```
    
Now we should be all set up to demonstrate some features.  Note that we're relying on
the natural goodness of ActiveRecord to wire up our class `Foo`, and we just add a little
sugar on top.

### ActiveRecord Sugar

#### Arel attribute aliases

The first convenience that we get is class methods on `Foo` for every column.  This is a big
factor in cutting down verbosity in queries:

```ruby
> Foo.id
=> {
  :name => "id",
  :relation => #<Arel::Table:0x007fd22163ee08 @name="foos", @engine=Foo(id: integer, bar: float, name: text), @columns=nil, @aliases=[], @table_alias=nil, @primary_key=nil>
}
```
    
Many of you will recognize the hash barf in the result - I promise not to do that any more,
but you will know that this is a legit instance of `Arel::Attributes::Attribute`, with all of
the Arel goodness baked in. To me, this creates a natural complement to the instance methods
that ActiveRecord creates for all the columns - an instance can refer to the value by name,
and a class can refer to the column similarly.

##### But what about name clashes?

The more astute readers (I always love when authors say that, it makes me feel dumb) will be asking, "What happens when you try to call `.name` on `Foo`?  ActiveRecord already defines
a class method called `.name`."  How very astute of you.  AwesomeSausage uses a really simple
rule to handle name clashes - if the class already responds to a method with same name as a
column, we append '\_column' to the name.  Too easy.  If you name your DB columns with a
'\_column' suffix, then, um...maybe this library is not for you.

```ruby
> Foo.name
=> "Foo"
> Foo.name_column
=> {...Arel barf...}
```

#### Class Methods

##### `.none`

Just what it looks like - this method returns an empty relation.  You know, for the times when
you need one.  This is for ActiveRecord versions prior to 4.0 - it should work just the same
as the class method that it introduced.

##### `.*`

This is purely a convenience method that I only implemented because I thought it looked cool.
It definitely adds to the DSL quality of these extensions.  Its utility is dubious, but at
least it will be quoted correctly when used in queries:

```ruby
> puts Foo.select(Foo.*).to_sql
# SELECT "foos".* FROM "foos"
```

---

The following methods shouldn't necessarily be defined on AR subclasses, but they are for now.
What they should really be is namespaced functions - then they could be arguably more useful
and have better names.  I'm thinking maybe `SQL`...suggestions welcome, more to come.

In general, these help with situations that I commonly want to represent in complicated
queries or those that I want to translate from raw SQL to the Arel equivalent.  This section
can and should be expanded with whatever idiomatic uses exist.

##### `.make_if`, `.count_if`, `.sum_if`

The most important method here is `.make_if`; the others are implemented in terms of it.  The
example that follows shows how the library can shorten syntax even more within the context of
an AR class or class method.

TODO: Fix `.sum_if` to take a parameter of what to sum when the condition is met.

```ruby
2.0.0 (main):0 > cd Foo
2.0.0 (Foo):1 > puts make_if(id == 1, 12, bar + 3).to_sql
# CASE WHEN "foos"."id" = 1 THEN 12 ELSE ("foos"."bar" + 3) END
2.0.0 (Foo):1 > puts count_if(name_column !~ 'rhubarb%').to_sql
# COUNT(CASE WHEN "foos"."name" NOT LIKE 'rhubarb%' THEN 1 ELSE NULL END)
=> nil
2.0.0 (Foo):1 > puts sum_if(id <= 200).to_sql
# SUM(CASE WHEN "foos"."id" <= 200 THEN 1 ELSE NULL END) AS sum_id
```

##### `.case_when`

This method is handy, and its signature is definitely likely to change.  Right now, it's a
little clunky.  The important parameter is the second one, a Hash that defines the guts of the
`CASE` statement:

```ruby
> puts case_when(id, { 1 => 'One', 2 => 'Two' }, 'Yowza')
# CASE "foos"."id" WHEN 1 THEN 'One' WHEN 2 THEN 'Two'  ELSE 'Yowza' END
> puts case_when(nil, { (id == 1).to_sql => "One", (id == 2).to_sql => 'Two' }, 'Yowza')
# CASE  WHEN "foos"."id" = 1 THEN 'One' WHEN "foos"."id" = 2 THEN 'Two'  ELSE 'Yowza' END
```

##### `.function`

Another slightly clunky method right now...it uses Arel's `NamedFunction` node type to create
whatever function you need.  I don't know if this should really be exposed to clients...it
provides great flexibility with better syntax than the pure Arel version.  This method also
creates a real possibility to improve readability of queries using methods, lambdas, or procs.

```ruby
> puts function('CONCAT', id, '_', bar, 1337, name_column).to_sql
# CONCAT("foos"."id", '_', "foos"."bar", 1337, "foos"."name")
```

### Arel Goodness

There are some handy things here, but there is so much more that can be done.  With my policy
of explicit opt-in, some decisions need to be made.  All of the Arel column methods attached
to the model classes return Arel nodes that extend the AwesomeSausage Arel mixin.  A big key
to the usefulness of this mixin is that all the methods that return Arel nodes also imbue the
nodes with superpowers.  A monkey-patch may be necessary to make this work cleanly.

#### `#to_sql`
A big pet peeve of mine is that Arel really wants to limit what you can call `#to_sql` on -
the implementers recognize this as a big performance bottleneck I think.  I would say that
Ruby and Rails have plenty of performance issues, including, well, Ruby and Rails.  We're not
going to let that stop us, so now we can do wonderful stuff like this:

```ruby
> puts Foo.id.to_sql
# "foos"."id"  
```

#### Relational and Aritmetic Operators

There have been some of these lurking around these examples, but here is the current list:

Operator | Notes
:------: | -----
`<`      |
`<=`     |
`>`      |
`>=`     |
`==`     |
`!=`     |
`=~`     | Corresponds to `LIKE`, maybe can additionally handle a regex on RHS for MySQL `LIKE REGEX`
`!~`     | `NOT LIKE`
`+`      |
`-`      |
`*`      |
`/`      |
`%`      | This is defined for MySQL, which also uses `%` as a modulo operator

#### Miscellany

There are a few other methods laying around, some that are special purpose for my own needs
that in retrospect are kind of silly, but some may survive.

## Contributing

Create an issue or pull request.  I appreciate any type of contribution, as
long as it's constructive - criticism included.
