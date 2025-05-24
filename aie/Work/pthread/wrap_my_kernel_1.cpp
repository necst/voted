#include "adf.h"
#include "../../src/my_kernel_1.cpp"
void b0_kernel_wrapper(x86sim::stream_internal * arg0, x86sim::stream_internal * arg1)
{
  auto _arg0 = (input_stream_int32 *)(arg0);
  auto _arg1 = (output_stream_int32 *)(arg1);
  return my_top_function(_arg0, _arg1);
}
