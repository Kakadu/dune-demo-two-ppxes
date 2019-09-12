all:
	dune build first/first.cma first/pp_first.exe first/pp_combined.exe hello/hello_world.exe

clean:
	$(RM) -r _build

