SOURCES := $(wildcard *.cr)
TARGETS := $(patsubst %.cr,bin/%,$(SOURCES))

.PHONY: all clean

all: $(TARGETS)

bin/%: %.cr | bin
	crystal build $< -o $@

bin:
	mkdir -p bin

clean:
	rm -rf bin
