all: expm

.PHONY: ebin

ebin:
	@mix do deps.get, compile

expm: ebin
	@mix escriptize

start: ebin
	@foreman start