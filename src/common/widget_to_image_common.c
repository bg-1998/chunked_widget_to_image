#include "widget_to_image_common.h"

uint8_t* load_bytes_to_memory(const uint8_t* bytes, size_t size) {
    if (!bytes || size <= 0) {
        return NULL;
    }
    void* mem_ptr = malloc(size);
    if (!mem_ptr) {
        return NULL;
    }
    memcpy(mem_ptr, bytes, size);
    return mem_ptr;
}