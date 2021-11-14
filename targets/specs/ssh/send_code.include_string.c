//void handler_packet( interpreter_t *vm, d_vec_pkt_content *data_pkt_content){

    uint32_t count = data_pkt_content->count<vm->user_data->len ? data_pkt_content->count : vm->user_data->len;
	if(count <= 2){
        vm->user_data->len = 0;
		return;
	}
    memcpy(vm->user_data->data, data_pkt_content->vals, count);
    vm->user_data->data[count-2]='\x0d';
    vm->user_data->data[count-1]='\x0a';
    vm->user_data->len = count;

//}
