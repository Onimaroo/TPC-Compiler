CC = gcc
CFLAGS = -Wall
LDFLAGS = -Wall -lfl
EXEC = ProjCompilL3
SUPP = abstract-tree
SUPP2 = translation

all :
	make tpcc
	make clean

tpcc : lex.yy.c $(EXEC).tab.c $(EXEC).tab.h $(SUPP).o $(SUPP2).o
	$(CC) -o ../bin/$@ $^ $(LDFLAGS)

$(EXEC).tab.c $(EXEC).tab.h : $(EXEC).y 
	bison -d $(EXEC).y

%.o : %.c
	$(CC) -o $@ -c $< $(LDFLAGS)

lex.yy.c : $(EXEC).lex $(EXEC).tab.h
	flex $(EXEC).lex

clean :
	rm -f $(EXEC) *.o
	rm -f *.tab.[hc]
	rm -f lex.yy.c
