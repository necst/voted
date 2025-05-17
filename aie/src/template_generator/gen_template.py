import configparser
import os

# 1) Read the configuration file
config = configparser.ConfigParser()
config.read('kernel.cfg')

# 2) Helper: read an option, returning None if missing, blank or 'None'
def get_opt(section, option):
    if not config.has_option(section, option):
        return None
    val = config.get(section, option).strip()
    if not val or val.lower() == 'none':
        return None
    return val

# 3) Extract parameters from the [kernel] section
vector_size   = get_opt('kernel', 'vector_size')   or '4'
input1_type   = get_opt('kernel', 'input1_type')
input2_type   = get_opt('kernel', 'input2_type')
output1_type  = get_opt('kernel', 'output1_type')
output2_type  = get_opt('kernel', 'output2_type')
kernel_name   = get_opt('kernel', 'kernel_name')   or 'my_kernel_function'
header_name   = get_opt('kernel', 'header_name')   or f'{kernel_name}.h'
cpp_name      = f"{kernel_name}.cpp"

# 4) Build lists of streams present
inputs  = [(1, input1_type), (2, input2_type)]
outputs = [(1, output1_type), (2, output2_type)]

# Filter only those with a valid type
inputs  = [(n, t) for n, t in inputs  if t]
outputs = [(n, t) for n, t in outputs if t]

# 5) Build function signature parameters
def make_param_list(streams, io):
    # io: 'input' or 'output'
    params = []
    for n, t in streams:
        params.append(f"{io}_stream<{t}>* restrict {io}{n}")
    return params

param_list = make_param_list(inputs,  'input')  + make_param_list(outputs, 'output')
param_str  = ',\n                   '.join(param_list) if param_list else '/* no streams defined */'

# 6) Helper: generate include-guard macro from header filename
base, _ = os.path.splitext(header_name)
guard_macro = base.upper().replace('.', '_') + '_H'

# 7a) C++ kernel template (.cpp) with English comments
cpp_template = f'''#include "{header_name}"
#include "common.h"
#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"

// API REFERENCE for STREAM:
// https://docs.amd.com/r/en-US/ug1079-ai-engine-kernel-coding/Reading-and-Advancing-an-Input-Stream

void {kernel_name}(
                   {param_str}
)
{{
'''
# 7b) If there's at least one input, use its first vector to get tot_iterations
if inputs:
    first_n, first_t = inputs[0]
    cpp_template += f'''    // Read the first vector from input{first_n} to get the total iteration count
    aie::vector<{first_t},{vector_size}> header = readincr_v{vector_size}(input{first_n});
    int tot_iterations = header[0];

    // Main processing loop
    for (int i = 0; i < tot_iterations; i++) {{
'''
    # 7c) Inside loop: read one vector from each defined input
    for n, t in inputs:
        cpp_template += f"        aie::vector<{t},{vector_size}> vec{n} = readincr_v{vector_size}(input{n});\n"
    cpp_template += "\n"
    # 7d) (Optional) example pass-through: set each output vec = corresponding input vec
    for n, t in outputs:
        # if there is an input with same index, pass through; else leave FIXME
        if any(n == in_n for in_n, _ in inputs):
            cpp_template += f"        aie::vector<{t},{vector_size}> result{n} = vec{n};\n"
        else:
            cpp_template += f"        aie::vector<{t},{vector_size}> result{n}; // FIXME: fill result{n}\n"
    cpp_template += "\n"
    # 7e) Write each result to its output stream
    for n, _ in outputs:
        cpp_template += f"        writeincr(output{n}, result{n});\n"
    cpp_template += "    }\n"
else:
    cpp_template += "    // No input streams defined: nothing to do\n"

cpp_template += "}\n"

# 7f) Header template (.h) with include guard and prototype
header_template = f'''#ifndef {guard_macro}
#define {guard_macro}

#include "common.h"
#include "aie_api/aie.hpp"
#include "aie_api/aie_adf.hpp"
#include "aie_api/utils.hpp"

// Function prototype for {kernel_name}
void {kernel_name}(
                   {param_str}
);

#endif // {guard_macro}
'''

# 8) Write the generated files
with open(cpp_name, 'w') as f_cpp:
    f_cpp.write(cpp_template)

with open(header_name, 'w') as f_hdr:
    f_hdr.write(header_template)

print(f"Generated files:\n - {cpp_name}\n - {header_name}")
