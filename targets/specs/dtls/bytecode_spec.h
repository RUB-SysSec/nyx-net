//-------------------------
// Move this file to bytecode_spec.h
// and implemented in user spec part

//includes

#include "custom_includes.h"

#include "nyx.h"


/**

**/

void interpreter_user_init(interpreter_t *vm){
}

void interpreter_user_shutdown(interpreter_t *vm){
}


void handler_packet( interpreter_t *vm, d_vec_pkt_content *data_pkt_content){
	//void handler_packet( interpreter_t *vm, d_vec_pkt_content *data_pkt_content){

    uint32_t count = data_pkt_content->count<vm->user_data->len ? data_pkt_content->count : vm->user_data->len;

    
    
    
    if(count >= 60){
        *((uint16_t*)(data_pkt_content->vals+11)) = htons(data_pkt_content->count-13);
    }
    
    else{
        vm->user_data->len = -1;
        return;
    }
    
    
    /*
    else{
        vm->user_data->len = -1;
        return;
    }
    */
   
    memcpy(vm->user_data->data, data_pkt_content->vals, count);
    
    vm->user_data->pkt_len = data_pkt_content->count;
    vm->user_data->len = count;


    

//}
}

void handler_create_tmp_snapshot( interpreter_t *vm){
	
//hprintf("ASKING TO CREATE SNAPSHOT\n");
kAFL_hypercall(HYPERCALL_KAFL_CREATE_TMP_SNAPSHOT, 0);
kAFL_hypercall(HYPERCALL_KAFL_USER_FAST_ACQUIRE, 0);
//hprintf("RETURNING FROM SNAPSHOT\n");
vm->ops_i -= OP_CREATE_TMP_SNAPSHOT_SIZE;
}
