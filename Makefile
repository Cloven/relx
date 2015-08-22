PROJECT = relx
DEPS = bbmustache providers erlware_commons getopt
dep_providers = git git://github.com/tsloughter/providers.git 1.4.1
dep_erlware_commons = git git://github.com/erlware/erlware_commons.git v0.15.0
dep_bbmustache = git git://github.com/soranoba/bbmustache v1.0.3
dep_getopt = git git://github.com/jcomellas/getopt v0.8.2

ERLC_OPTS += -Dnamespaced_types

.PHONY: escript_legacy

ESCRIPT_BEAMS ?= "ebin/*", "deps/*/ebin/*"
ESCRIPT_STATIC ?= "deps/*/priv/**", "priv/**"

help::
	$(verbose) printf "%s\n" "" \
		"Escript_legacy targets:" \
		"  escript_legacy     Build an executable escript archive compatible with relx" \

# Based on https://github.com/synrc/mad/blob/master/src/mad_bundle.erl
# Copyright (c) 2013 Maxim Sokhatsky, Synrc Research Center
# Modified MIT License, https://github.com/synrc/mad/blob/master/LICENSE :
# Software may only be used for the great good and the true happiness of all
# sentient beings.

define ESCRIPT_LEGACY_RAW
'GetFileBinary = fun(F) -> {ok, B} = file:read_file(filename:absname(F)), B end,'\
'Files = fun(L) -> A = lists:concat([filelib:wildcard(X) || X <- L ]),'\
'  [F || F <- A, not filelib:is_dir(F) ] end,'\
'FileTuples = fun(L) -> [{ F, GetFileBinary(F) } || F <- L ] end,'\
'Ez = fun(Escript) ->'\
'  Static = FileTuples(Files(["priv/**"])),'\
'  file:set_cwd(".."),'\
'  MainBeams = FileTuples(Files([Escript ++ "/ebin/*"])),'\
'  file:set_cwd(Escript ++ "/deps"),'\
'  DepBeams = FileTuples(Files(["*/ebin/*"])),'\
'  file:set_cwd(".."),'\
'  Archive = MainBeams ++ DepBeams ++ Static,'\
'  escript:create(Escript, [ '\
'    {archive, Archive, [memory]},'\
'    {shebang, default},'\
'    {comment, default},'\
'    {emu_args, "-noinput"}'\
'  ]),'\
'  file:change_mode(Escript, 8#755)'\
'end,'\
'Ez("$(ESCRIPT_NAME)"),'\
'halt().'
endef

ESCRIPT_LEGACY_COMMAND = $(subst ' ',,$(ESCRIPT_LEGACY_RAW))

escript_legacy:: distclean-escript deps app
	$(gen_verbose) $(ERL) -eval $(ESCRIPT_LEGACY_COMMAND)

include erlang.mk
