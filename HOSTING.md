Hosting expm Repository
=======================

It's fairly straightforward. Check out expm repository, run `make`, copy `config.exs.sample` to `config.exs`, edit it and run `make start`.

By default, it will run its own independent repository. If you, however, want to become a mirror, put something like this into your configuration:

```erlang
 config.repository quote do: Expm.Repository.Mirror.new(source: (Expm.Repository.HTTP.new url: "http://expm.co"), destination: Expm.Repository.DETS.new(filename: "expm.dat"), frequency: 1000*60)
```

This will download expm.co's repository every minute.