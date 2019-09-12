all:
	dune build first/first.cma first/pp_first.exe first/pp_combined.exe

clean:
	$(RM) -r _build

