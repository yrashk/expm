all: expm

.PHONY: ebin

ebin:
	@mix do deps.get, compile

expm: ebin
	@mix escriptize
	@cp ./expm priv/static

start: expm
	@mix run "{:ok, b} = File.read \"sys.config.exs\"; {v, _} = Code.eval(b); :io.format(\"~p.~n\", [v])" > sys.config
	@foreman start