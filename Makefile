SOURCES := $(wildcard *.cr)
TARGETS := $(patsubst %.cr,bin/%,$(SOURCES))

.PHONY: all clean format

all: format $(TARGETS)

format:
	crystal tool format

bin/%: %.cr | bin
	crystal build $< -o $@

bin:
	mkdir -p bin

clean:
	rm -rf bin
