all: expm

.PHONY: ebin rel

ebin:
	@mix do deps.get, compile

expm: ebin
	@mix escriptize
	@cp ./expm priv/static

sys.config: sys.config.exs
	@mix run "{:ok, b} = File.read \"sys.config.exs\"; {v, _} = Code.eval(b); :io.format(\"~p.~n\", [v])" > sys.config

start: expm sys.config
	@ERL_LIBS=deps elixir --sname expm --erl "-pa ebin -config sys -s Elixir-Expm" --no-halt

rel: rel/expm

rel/expm: expm
	@mix relex.assemble

start-rel: rel sys.config
	@./rel/expm/erts-*/bin/erl -sname expm -config sys -s 'Elixir-Expm' -noinput