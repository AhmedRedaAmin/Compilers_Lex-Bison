all:
	flex lexical_analyzer_java.l
	bison -y -d parser_java.y
	g++ -std=c++11 lex.yy.c y.tab.c


exec: all
	./a.out


error:
	bison --verbose parser_java.y

calc.tab.c calc.tab.h:	calc.y
	bison -d calc.y

lex.yy.c: calc.l calc.tab.h
	flex c alc.l

calc: lex.yy.c calc.tab.c calc.tab.h
	gcc -o calc calc.tab.c lex.yy.c

clean:
	rm calc calc.tab.c lex.yy.c calc.tab.h
