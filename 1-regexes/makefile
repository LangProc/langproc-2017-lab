CPPFLAGS += -W -Wall -g -std=c++11

# Avoid warnings about yyunput not used
CPPFLAGS += -Wno-unused-function

all : histogram

histogram_lexer.yy.cpp : histogram_lexer.flex
	flex -o histogram_lexer.yy.cpp  histogram_lexer.flex

histogram : histogram_lexer.yy.o histogram_main.o
	g++ $(CPPFLAGS) -o histogram  histogram_lexer.yy.o histogram_main.o

clean :
	-rm histogram histogram.exe
	-rm *.yy.cpp
	-rm test/out/*