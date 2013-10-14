all: expm

.PHONY: ebin rel

PREFIX ?= /usr/local

install:
	@cp -p ./expm $(PREFIX)/bin/expm

uninstall:
	rm -f $(PREFIX)/bin/expm

ebin:
	@mix do deps.get, compile

expm: ebin
	@rm priv/static/expm
	@mix escriptize
	@cp ./expm priv/static

sys.config: config.exs
	@ERL_LIBS=deps elixir -pa ebin -e "config = Expm.Config.file!(%s{config.exs}); config.sys_config!(%s{sys.config})"

start: expm sys.config
	@ERL_LIBS=deps elixir --sname expm --erl "-pa ebin -config sys -s Elixir.Expm" --no-halt

rel: rel/expm

rel/expm: expm
	@mix relex.assemble

start-rel: rel sys.config
	@./rel/expm/erts-*/bin/erl -sname expm -config sys -s 'Elixir.Expm' -noinput
