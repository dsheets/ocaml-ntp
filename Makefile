.PHONY: all clean distclean setup build doc install test
all: build

J ?= $(shell nproc)
PREFIX ?= /usr/local
NAME=ntp

LWT ?= $(shell if ocamlfind query lwt.unix >/dev/null 2>&1; then echo --enable-lwt;fi)
MIRAGE ?= $(shell if ocamlfind query mirage-net >/dev/null 2>&1; then echo --enable-mirage; fi)
ifneq ($(MIRAGE_OS),xen)
TESTS ?= --enable-tests
endif

setup.ml:
	oasis setup

setup.bin: setup.ml
	ocamlopt.opt -o $@ $< || ocamlopt -o $@ $< || ocamlc -o $@ $<
	$(RM) setup.cmx setup.cmi setup.o setup.cmo

setup.data: setup.bin
	./setup.bin -configure $(LWT) $(MIRAGE) $(TESTS) --prefix $(PREFIX)

clean:
	./setup.bin -distclean
	./setup.bin -clean
	$(RM) -f setup.data setup.bin setup.ml _tags myocamlbuild.ml

build: setup.data setup.bin
	./setup.bin -build -j $(J) $(OFLAGS)

install: setup.data setup.bin
	ocamlfind remove $(NAME) $(OFLAGS)
	./setup.bin -install

doc: setup.data setup.bin
	./setup.bin -doc -j $(J) $(OFLAGS)
