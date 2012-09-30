Publishing packages
===================

Publishing packages with expm is fairly trivial

Defining a package
------------------

Every expm package is defined using `Expm.Package` record (look at the [example](https://github.com/yrashk/expm/blob/master/package.exs))

Normally you put this definition into `package.exs`. However, if you're intending to publish named versions as well (such as `:head`), our suggestion is to put such package definitions into `package.NAME.exs` (like [here](https://github.com/yrashk/expm/blob/master/package.head.exs))

Authorization
-------------

Current expm's implementation of security is a little bit funny. There's no need to create an account in order to publish your package.

Simply use `username` and `password` options when claiming new package and this username and password combination will be attached to your package on the server. No one without your username and password can update the package.

At this moment it is not possible to delegate the package maintainership to somebody else, but it will not be that way forever.

### Security considerations

Although the server will not store your password in plaintext, it would still be advisable to use a separate password from any other system you use. Besides, until [expm.co](http://expm.co) gets an HTTPS certificate, your password will be transmitted as basic HTTP auth (which means it is almost plaintext).

We do plan to equip [expm.co](http://expm.co) with the certificate to make it more secure.

Command line
------------

The easiest way to publish a package is to use `expm` command line utility:

```
$ expm --username USERNAME --password PASSWORD publish [package.exs]
```

If it prints out package specification, everything went fine.

Also, if you need to publish it to some other than central repository, you can do so by specifying that repository's URL using --repository/-r option.

Programmatically
----------------

You can also publish your package using Expm's API:

```elixir
repo = Expm.Repository.HTTP.new [url: ...]
Expm.Package.publish repo, Expm.Package.read(filename // "package.exs")
```