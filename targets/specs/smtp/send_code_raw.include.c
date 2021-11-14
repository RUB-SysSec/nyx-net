
    uint32_t count = data_pkt_content->count<vm->user_data->len ? data_pkt_content->count : vm->user_data->len;
	if(count <= 0){
        vm->user_data->len = 0;
		return;
	}
    memcpy(vm->user_data->data, data_pkt_content->vals, count);
    vm->user_data->len = count;

