#include <stdint.h>

void rgba_to_i420(const uint8_t* sample, int sample_size,
                  uint8_t* dst_y, int dst_stride_y,
                  uint8_t* dst_u, int dst_stride_u,
                  uint8_t* dst_v, int dst_stride_v,
                  int src_width, int src_height);