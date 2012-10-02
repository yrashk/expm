Using expm
==========

This manual explains how to use expm to discover and use packages.

Basics
------

A little bit of necessary theory here.

expm has a very few basic primitives:

* Package, represented by specification defined by Expm.Package record
* Package version: named and specific. Named versions are atoms and specific versions are binaries (Like `:head` and `"0.1"`). Package version is part of package specification (Expm.Package.version)
* Repository, an entity that implements Expm.Repository protocol. Normally all you need to know is Expm.Repository.HTTP type of repositories. This is what expm uses by default (pointing to [http://expm.co](expm.co) repository)


Command line
------------

### The utility

There are two ways to get expm's command line utility:

#### Ready-made

Go [http://expm.co/](http://expm.co/) and grab it using the download link at the bottom. If you want to do this automatically, use this shell command:

```
curl -o expm http://expm.co/__download__/expm
```

After downloading the binary, make it executable:

```
chmod +x expm
```

#### DIY

Clone [yrashk/expm](https://github.com/yrashk/expm) and type `make`. Please note, however,
that for this to work, Elixir (normally the very latest `master` at this moment) has to be built and its binaries should be in your `PATH`

### Usage

#### Common options

* --repository URL (-r URL)

By default, this is [http://expm.co/](http://expm.co/)

* --username USER and --password PASSWORD

Used when publishing a package to the repository

#### --version

Prints expm's version

#### server --version

Prints repository's expm server's version

#### list

Lists all packages in the repository

#### search KEYWORD

Searches all packages that match the KEYWORD. KEYWORD can be a partial regular expression.

#### spec[:FIELD] PACKAGE [--format mix|rebar|asis] [--format-opts OPTS]

Prints out topmost PACKAGE's version's specification.

If FIELD is specified, only that field is printed.

#### spec[:FIELD] PACKAGE VERSION [--format mix|rebar|asis] [--format-opts OPTS]

Prints out specific PACKAGE's VERSION's specification.

If FIELD is specified, only that field is printed.

#### versions PACKAGE

Prints a list of PACKAGE's versions

#### publish [package.exs]

Publishes package to the repository. If the file name is omitted, `package.exs` will be used.

Web interface
-------------

Web interface allows you to browse and search packages using your browser. The central repository is available at [expm.co](http://expm.co)

Programmatically
----------------

You can retrieve packages in your modules. Here's a brief example:

```elixir
defmodule MyModule do
  use Expm[, url: ...][, repository: ...][,format: Expm.Package.Format.Mix | Expm.Package.Format.Asis]

  def my_function do
     [
       expm("genx"),
       expm("esession", version: "0.1")
     ]
  end
end
```