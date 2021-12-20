/* abstract-tree.h */
#define MAXNAME 32

typedef enum {
  Program,
  VarDeclList,
  IntLiteral,
  CharLiteral,
  Identifier,
  Return,
  Add,
  Sub,
  Mult,
  Division,
  Type,
  Var,
  FuncDeclList,
  FuncDec,
  Affectation,
  ListParam,
  ListArg,
  Void,
  Corps,
  InstrList,
  Or,
  And,
  Equals,
  Different,
  If,
  Then,
  Else,
  While,
  Print,
  GreaterThan,
  GreaterOrEqual,
  LesserThan,
  LesserOrEqual,
  Struct,
  StructName,
  CreateStruct,
  CorpsStruct,
  AppelFonction,
  Reade,
  Readc,
  /* and allother node labels */
  /* The list must coincide with the strings in abstract-tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} Kind;

typedef struct Node {
  Kind kind;
  union {
    int integer;
    char character;
    char identifier[64];
  } u;
  struct Node *firstChild, *nextSibling;
  int lineno;
} Node;

typedef struct {
  int var_fonc; /* 0 = VAR, 1 = FONC, 2 = PAR */
  char name[MAXNAME];
  char type[64];
  int STsize; /* size of symbol table */
  int nbre_parametres;
} STentry;

typedef struct {
  STentry *symbolTable;
  char tableName[MAXNAME];
} STsymbol;

Node *makeNode(Kind kind);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling

void addVar(STentry *table, const char name[], char *type);
void printSymbolTable(STentry *table);
STentry *createSymbolTable();
STsymbol *createSymbol();
int checkSame(STentry *global, STentry *table);
int checkIn(const char name[], STentry *table, char *type);
int checkExist(STentry *table, char *var);
int checkVariable_Variable(char* variable_type1, char* variable_type2);
int checkValue_Value(Kind value, Kind value2);
int checkVariable_Value(char* variable_type, Kind value);
int clearTable(STsymbol *table, int pos);
char* find_type(STentry *table, char name[]);
