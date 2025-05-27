/* Auto-generated (stream mode) */
#include "my_kernel_1.h"
#include "common.h"
#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"

// user compute stub
void compute_function(aie::vector<int32_t,4>& vec_input2, aie::vector<int32_t,4>& result_output2)
{
    // to be filled with user logic
}


void my_top_function(
                   input_stream<int32_t>* restrict input2,
                   output_stream<int32_t>* restrict output2
)
{
    // read header for iteration count
    aie::vector<int32_t,4> header = readincr_v<4>(input2);
    int tot_iterations = header[0];

    for (int i = 0; i < tot_iterations; i++) {
        aie::vector<int32_t,4> vec_input2 = readincr_v<4>(input2);
        aie::vector<int32_t,4> result_output2;

        compute_function(vec_input2, result_output2);

        writeincr(output2, result_output2);
    }
}