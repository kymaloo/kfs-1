#ifndef LIBASM_STD_H
# define LIBASM_STD_H

unsigned int strlen(const char *str);
void putchar_fd(unsigned int fd, char c);
void putchar(char c);
void putstr(char *str);

int printf(const char *format, ...);


#endif