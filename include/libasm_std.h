#ifndef LIBASM_STD_H
# define LIBASM_STD_H

# include <errno.h>

unsigned int strlen(const char *str);
void putchar_fd(unsigned int fd, char c);

#endif