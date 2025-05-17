#include "kernel_template.h"
#include "common.h"
#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"

// API REFERENCE for STREAM:
// https://docs.amd.com/r/en-US/ug1079-ai-engine-kernel-coding/Reading-and-Advancing-an-Input-Stream

void kernel_template(
                   input_stream<int32_t>* restrict input1,
                   input_stream<float>* restrict input2,
                   output_stream<int32_t>* restrict output1,
                   output_stream<float>* restrict output2
)
{
    // Read the first vector from input1 to get the total iteration count
    aie::vector<int32_t,4> header = readincr_v4(input1);
    int tot_iterations = header[0];

    // Main processing loop
    for (int i = 0; i < tot_iterations; i++) {
        aie::vector<int32_t,4> vec1 = readincr_v4(input1);
        aie::vector<float,4> vec2 = readincr_v4(input2);

        aie::vector<int32_t,4> result1 = vec1;
        aie::vector<float,4> result2 = vec2;

        writeincr(output1, result1);
        writeincr(output2, result2);
    }
}
