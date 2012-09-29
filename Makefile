all: ebin

.PHONY: ebin

ebin:
	mix do deps.get, compile

start: ebin
		@foreman start