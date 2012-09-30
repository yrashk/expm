all: expm

.PHONY: ebin

ebin:
	@mix do deps.get, compile

expm: ebin
	@mix escriptize
	@cp ./expm priv/static

start: expm
	@foreman start