package br.maua.cic303;

import java_cup.runtime.Symbol; // Importação necessária para o CUP

%%

%class Lexer
%public
%unicode
%cup       // <-- CRÍTICO: Esta diretiva ativa a integração com o CUP
%line
%column

%{
    // Funções auxiliares para gerar objetos Symbol para o CUP
    private Symbol symbol(int type) {
        return new Symbol(type, yyline, yycolumn);
    }
    
    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}

/* ========================================================================= */
/* MACROS (Expressões Regulares Auxiliares)                                  */
/* ========================================================================= */
LineTerminator = \r|\n|\r\n
WhiteSpace     = {LineTerminator} | [ \t\f]

/* TODO 1: Crie a macro para Número (Notação de Engenharia) */
Number = [0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?

/* TODO 2: Crie a macro para Identificador */
Letter = [a-zA-Z]
Digit  = [0-9]
Identifier = {Letter}({Letter}|{Digit}|_){0,31}

/* MACRO ADICIONAL: Necessária para a regra de erro no final do arquivo */
OversizedIdentifier = {Letter}({Letter}|{Digit}|_){32}({Letter}|{Digit}|_)*

%%
/* ========================================================================= */
/* REGRAS LÉXICAS (Altere para retornar sym.XXX)                                 */
/* ========================================================================= */

<YYINITIAL> {
    
    /* Regra para ignorar espaços em branco */
    {WhiteSpace}    { /* Não faz nada */ }

    /* TODO 3: Palavras Reservadas (if, then, else, while) */
    "if"            { return symbol(sym.IF); }
    "then"          { return symbol(sym.THEN); }
    "else"          { return symbol(sym.ELSE); }
    "while"         { return symbol(sym.WHILE); }

    /* TODO 4: Pontuação ( ) { } ; */
    "("             { return symbol(sym.LPAREN); }
    ")"             { return symbol(sym.RPAREN); }
    "{"             { return symbol(sym.LBRACE); }
    "}"             { return symbol(sym.RBRACE); }
    ";"             { return symbol(sym.SEMI); }

    /* TODO 5: Operadores de Atribuição e Relacionais (=, ==, !=, <, >, <=, >=) */
    /* Operadores duplos vêm primeiro para evitar conflitos de casamento de padrão */
    "==" | "!=" | "<=" | ">=" | "<" | ">" { return symbol(sym.REL_OP, yytext()); }
    "="             { return symbol(sym.ASSIGN); }

    /* TODO 6: Operadores Matemáticos (+, -, *, /, %) */
    "+" | "-"       { return symbol(sym.ADD_OP, yytext()); }
    "*" | "/" | "%" { return symbol(sym.MUL_OP, yytext()); }

    /* Regras para as Macros */
    {Identifier}    { return symbol(sym.ID, yytext()); }
    {Number}        { return symbol(sym.NUMBER, yytext()); }

    /* Identificadores grandes demais (Captura o erro) */
   {OversizedIdentifier} { throw new RuntimeException("Erro Léxico: Identificador gigante -> " + yytext()); }

    /* Fallback: Qualquer outro caractere não reconhecido gera um Erro */
    .   {throw new RuntimeException("Erro Léxico: Caractere Ilegal -> " + yytext()); }
}

/* Regra para o Final do Arquivo */
<<EOF>>             { return symbol(sym.EOF, ""); }
