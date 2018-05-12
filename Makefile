all:
	flex lexical_analyzer_java.l
	bison -y -d parser_java.y
	g++ -std=c++11 lex.yy.c y.tab.c


exec: all
	./a.out


error:
	bison --verbose parser_java.y

clean:
	rm lex.yy.c *.tab.c *.tab.h a.out *.class
	rm -r cmake-build-debug
