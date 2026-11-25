# Pizza compiler build (M1-1). Order matters: bison writes parser.tab.h,
# which lexer.l includes.
#
#   make          build ./pizza
#   make test     build, then run every test in tests/
#   make clean    remove generated files
#
# Tool names can be overridden, e.g. on Windows with WinFlexBison:
#   make FLEX=win_flex BISON=win_bison

CC     = gcc
FLEX   = flex
BISON  = bison
CFLAGS = -Wall -g
TARGET = pizza

GENERATED = parser.tab.c parser.tab.h parser.output lex.yy.c

all: $(TARGET)

parser.tab.c: parser.y
	$(BISON) -d -o parser.tab.c parser.y

parser.tab.h: parser.tab.c

lex.yy.c: lexer.l parser.tab.h
	$(FLEX) -o lex.yy.c lexer.l

$(TARGET): parser.tab.c parser.tab.h lex.yy.c main.c
	$(CC) $(CFLAGS) -o $@ parser.tab.c lex.yy.c main.c

test: $(TARGET)
	bash tests/run_tests.sh ./$(TARGET)

clean:
	rm -f $(GENERATED) $(TARGET) $(TARGET).exe

.PHONY: all test clean
