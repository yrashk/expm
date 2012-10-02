Hosting expm Repository
=======================

It's fairly straightforward. Check out expm repository, run `make`, copy `sys.config.sample.exs` to `sys.config.exs` and edit itand run `make start` (make sure foreman is installed, or consult with Procfile on how to run the server without it)

By default, it will run its own independent repository. If you, however, want to become a mirror, put something like this into your `sys.config.exs`:

```erlang
 repository: quote do: Expm.Repository.Mirror.new(source: (Expm.Repository.HTTP.new url: "http://expm.co"), destination: Expm.Repository.DETS.new(filename: "expm.dat"), frequency: 1000*60"),
```

This will download expm.co's repository every minute.