#ifndef MY_KERNEL_1_H
#define MY_KERNEL_1_H

#include "common.h"
#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"
#include <adf.h>

// user compute prototype
void compute_function(aie::vector<int32_t,4>& vec_input2, aie::vector<int32_t,4>& result_output2);

// kernel prototype (stream mode)
void my_top_function(
                   input_stream<int32_t>* restrict input2,
                   output_stream<int32_t>* restrict output2
);

#endif // MY_KERNEL_1_H