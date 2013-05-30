PLT_APPS ?=
DIALYZER_OPTS ?= -Werror_handling -Wrace_conditions \
-Wunmatched_returns # -Wunderspecs
SRC ?= src

all: compile

compile:
	rebar compile

get-deps:
	rebar get-deps

demo-shell:
	erl -pa deps/*/ebin ebin -s $(PROJECT)

shell:
	erl -pa deps/*/ebin ebin

test:
	rebar eunit

# Dialyzer.

build-plt:
	@dialyzer --build_plt --output_plt .$(PROJECT).plt \
	    --apps erts kernel stdlib $(PLT_APPS)

dialyze:
	@dialyzer --src $(SRC) \
	    --plt .$(PROJECT).plt --no_native $(DIALYZER_OPTS)
