#ifndef MY_KERNEL_1_H
#define MY_KERNEL_1_H

#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"
#include "common.h"
#include <adf.h>

extern "C" {

// kernel prototype (stream mode)
void my_top_function(
    adf::input_buffer<int32_t, adf::extents<4>> &__restrict inA,
    adf::output_buffer<int32_t, adf::extents<4>> &__restrict outC);
}
#endif // MY_KERNEL_1_H