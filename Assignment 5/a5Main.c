#include <stdio.h>
#include <stdlib.h>

/*  Constants  */
#define MAXOP   20
#define NUMBER  '0'
#define TOOBIG  '9'

/*  Function prototypes  */
int push(int f);
int pop();
void clear();
int getop(char *s, int lim);
int getch();
void ungetch(int c);

int main(){
	int type;
	char s[MAXOP];
	int op2;
	
	while ((type = getop(s, MAXOP)) != EOF) {
		switch (type) {
		case NUMBER:
			push(atoi(s));
			break;
		case '+':
			push(pop() + pop());
			break;
		case '*':
			push(pop() * pop());
			break;
		case '-':
			op2 = pop();
			push(pop() - op2);
			break;
		case '/':
			op2 = pop();
			if (op2 != 0)
				push(pop() / op2);
			else
				printf("zero divisor popped\n");
			break;
		case '=':
			printf("\n%d\n\n", push(pop()));
			break;
		case 'c':
			clear();
			break;
		case TOOBIG:
			printf("%.20s ... is too long\n", s);
			break;
		default:
			printf("unknown command %c\n", type);
			break;}
	}
	return 0;
}
//extern int new_sp;
//extern int val[];
//extern char buf[];
//extern int bufp;

//END OF MAIN
/* #define MAXVAL  100
int new_sp = 0;
int val[MAXVAL];


int push(int f){
	if (new_sp < MAXVAL)
		return val[new_sp++] = f;
	else {
		printf("error: stack full\n");
		clear();
		return 0;
	}
} */

// int pop(){
// 	if (new_sp > 0)
// 		return val[--new_sp];
// 	else {
// 		printf("error: stack empty\n");
// 		clear();
// 		return 0;
// 	}
// }

/* void clear(){
	new_sp = 0;
}  */

/* int getop(char *s, int lim){
	int i, c;
	while ((c = getch()) == ' ' || c == '\t' || c == '\n')
		;

	if (c < '0' || c > '9')
		return c;
	
	s[0] = c;
	for (i = 1; (c = getchar()) >= '0' && c <= '9'; i++)
		if (i < lim)
			s[i] = c;
	
	if (i < lim) {
		ungetch(c);
		s[i] = '\0';
		return NUMBER;
	} 
	else {
		while (c != '\n' && c != EOF)
			c = getchar();
		s[lim-1] = '\0';
		return TOOBIG;}}
 */
/* #define BUFSIZE   100
		
		char buf[BUFSIZE];
		int bufp = 0; */

/* int getch(){
	return bufp > 0 ? buf[--bufp] : getchar();
} */

/* void ungetch(int c){
	if (bufp > BUFSIZE)
		printf("ungetch: too many characters\n");
	else
		buf[bufp++] = c;
} */
