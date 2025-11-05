#include "my_kernel_1.h"
#include <aie_api/aie.hpp>
#include <aie_api/aie_adf.hpp>

#define VECTOR_SIZE 4

extern "C" {

void my_top_function(
    adf::input_buffer<int32_t, adf::extents<4>> &__restrict inA,
    adf::output_buffer<int32_t, adf::extents<4>> &__restrict outC) {

  auto pA = aie::begin_vector<VECTOR_SIZE>(inA);
  auto pC = aie::begin_vector<VECTOR_SIZE>(outC);

  // the begin vector returns a vector iterator!
  aie::vector<int32_t, VECTOR_SIZE> v = *pA++;

  aie::vector<int32_t, VECTOR_SIZE> one =
      aie::broadcast<int32_t, VECTOR_SIZE>(2);

  v = aie::add(v, one);

  *pC++ = v;
}
}
