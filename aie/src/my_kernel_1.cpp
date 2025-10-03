/* Auto-generated (stream mode) */
#include "my_kernel_1.h"
#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"
#include "common.h"

#define VECTOR_SIZE 4

void my_top_function(
    adf::input_buffer<
        uint32_t, adf::extents<adf::inherited_extent, adf::inherited_extent>>
        &__restrict inA,
    adf::output_buffer<
        uint32_t, adf::extents<adf::inherited_extent, adf::inherited_extent>>
        &__restrict outC) {

  auto pA = aie::begin_vector<sizeof(int32) * VECTOR_SIZE>(inA);
  auto pC = aie::begin_vector<sizeof(int32) * VECTOR_SIZE>(outC);

  aie::vector<uint32_t, VECTOR_SIZE> vect1;

  // read header for iteration count
  vect1 = aie::load_v<VECTOR_SIZE>(pA);
  int tot_iterations = vect1[0];

  for (int i = 0; i < tot_iterations; i++) {
    vect1 = aie::load_v<VECTOR_SIZE>(pA);
    pA += VECTOR_SIZE;
    aie::store_v<VECTOR_SIZE>(pC, vect1);
    pC += VECTOR_SIZE;
  }
}