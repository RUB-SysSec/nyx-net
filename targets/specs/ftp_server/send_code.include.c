//void handler_packet( interpreter_t *vm, d_vec_pkt_content *data_pkt_content){

        
        char* term = "\r\n";
        char* repl = "\n ";
        size_t termlen = strlen(term);
        ASSERT(strlen(term)==strlen(repl));

        uint32_t count = data_pkt_content->count<vm->user_data->len ? data_pkt_content->count : vm->user_data->len;
        if(count+termlen > vm->user_data->len){
            count = vm->user_data->len-termlen;
        }

        memcpy(vm->user_data->data, data_pkt_content->vals, count);
        //replace any terminator in the input
        char* d = memmem(vm->user_data->data, count, term, termlen);
        while(d){
            memcpy(d,repl,strlen(term));
            d = memmem(vm->user_data->data, count, term, termlen);
        }
        memcpy(vm->user_data->data+count, term, termlen);
        vm->user_data->len = count+termlen;



//}
