CPPFLAGS += -W -Wall -g -std=gnu++11

histogram_lexer.yy.cpp : histogram_lexer.flex
	flex -o histogram_lexer.yy.cpp  histogram_lexer.flex

histogram : histogram_lexer.yy.cpp histogram_main.cpp
	g++ $(CPPFLAGS) -o histogram  histogram_lexer.yy.cpp histogram_main.cpp

clean :
	-rm histogram histogram.exe
	-rm *.yy.cpp
	-rm test/out/*
