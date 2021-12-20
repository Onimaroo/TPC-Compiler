void translate_start(FILE *file);
void translate_end(FILE *file);
void translate_declaration(FILE *file);
void translate_declaration_fonction(FILE *file, char name[]);
void translate_addsub_divstar(FILE *file, Kind operande);
void translate_assignment(FILE *file, char name[], int address_op);
