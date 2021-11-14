#define _GNU_SOURCE  
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include "stdbool.h"
#include <string.h>
#include TARGET_PATH

interpreter_t *vm = NULL;
socket_state_t vm_state;
uint32_t opcode_count = 0;

static void setup_interpreter(void *payload_buffer)
{
    uint64_t *offsets = (uint64_t *)payload_buffer;
    //printf("checksum: %lx, %llx\n",offsets[0], INTERPRETER_CHECKSUM);
    ASSERT(offsets[0] == INTERPRETER_CHECKSUM);
    ASSERT(offsets[1] < 0xffffff);
    ASSERT(offsets[2] < 0xffffff);
    ASSERT(offsets[3] < 0xffffff);
    ASSERT(offsets[4] < 0xffffff);
    uint64_t *graph_size = &offsets[1];
    uint64_t *data_size = &offsets[2];

    //printf("graph_size: %ld\n", *graph_size);
    //printf("data_size: %ld\n", *data_size);
    //printf("graph_offset: %ld\n", offsets[3]);
    //printf("data_offset: %ld\n", offsets[4]);

    uint16_t *graph_ptr = (uint16_t *)(payload_buffer + offsets[3]);
    uint8_t *data_ptr = (uint8_t *)(payload_buffer + offsets[4]);
    ASSERT(offsets[3] + (*graph_size) * sizeof(uint16_t) <= PAYLOAD_SIZE);
    ASSERT(offsets[4] + *data_size <= PAYLOAD_SIZE);
    init_interpreter(vm, graph_ptr, graph_size, data_ptr, data_size, &opcode_count);
    interpreter_user_init(vm);
    vm->user_data = &vm_state;
}

int main(int argc, char **argv)
{
    #define PACKET_BUFFER_SIZE (1<<14)
    static char data_buffer[PACKET_BUFFER_SIZE];
    uint8_t* payload = calloc(PAYLOAD_SIZE, 1);

    if (argc < 2)
    {
        printf("usage: %s $inputfile\ncompiled for %s", argv[0], TARGET_SPEC);
        exit(0);
    }
    int fd = open(argv[1], O_RDONLY);
    if(fd == -1){
        printf("couldn't open input file %s (%s)\n", argv[1], strerror(errno));
        exit(0);
    }
    size_t res = 0;
    size_t bytes = 0;
    while((bytes<PAYLOAD_SIZE) && (res = read(fd, payload+bytes,PAYLOAD_SIZE-bytes))){
        if(res == -1){
            printf("couldn't read input file %s (%s)\n", argv[1], strerror(errno));
            exit(0);
        } 
        bytes += res;
    }

    vm = new_interpreter();
    setup_interpreter(payload);

    vm_state.data = data_buffer;
    vm_state.len = PACKET_BUFFER_SIZE;

    while (interpreter_run(vm))
    {
        size_t written = 0;
        while (written < vm->user_data->len)
        {
            size_t res = write(1, vm->user_data->data, vm->user_data->len - written);
            if (res == -1)
            {
                printf("error writing to stdout: (%s)\n", strerror(errno));
                exit(0);
            }
            written += res;
        }
        vm_state.data = data_buffer;
        vm_state.len = PACKET_BUFFER_SIZE;
    }
}