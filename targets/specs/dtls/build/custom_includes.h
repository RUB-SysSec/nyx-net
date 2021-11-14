#pragma once

#include<stdint.h>
#include<stddef.h>
#include<stdlib.h>
#include <arpa/inet.h>

typedef struct {
    size_t len;
    size_t pkt_len;
    char* data;
    bool closed;
} socket_state_t;

extern void __assert(const char *func, const char *file, int line, const char *failedexpr);
#define INTERPRETER_ASSERT(x) do { if (x){}else{ __assert(__func__, __FILE__, __LINE__, #x);} } while (0)

#define ASSERT(x) INTERPRETER_ASSERT(x)

#define VM_MALLOC(x) malloc(x)

