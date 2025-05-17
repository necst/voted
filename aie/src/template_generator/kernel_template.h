#ifndef KERNEL_TEMPLATE_H
#define KERNEL_TEMPLATE_H

#include "common.h"
#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"

// Function prototype for kernel_template
void kernel_template(
                   input_stream<int32_t>* restrict input1,
                   input_stream<float>* restrict input2,
                   output_stream<int32_t>* restrict output1,
                   output_stream<float>* restrict output2
);

#endif // KERNEL_TEMPLATE_H
