#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import configparser, os, sys

# -------------------------
# 1) Read kernel.cfg
# -------------------------
cfg = configparser.ConfigParser()
cfg.read('kernel.cfg')

def get_opt(key, default=None):
    """
    Return the value of 'key' in [kernel], stripping comments,
    or default if missing/blank/'None'.
    """
    raw = cfg.get('kernel', key, fallback=None)
    if raw is None:
        return default
    # strip inline comments starting with '#' or ';'
    val = raw.split('#',1)[0].split(';',1)[0].strip()
    return val if val else default

# -------------------------
# 2) General parameters
# -------------------------
file_name   = get_opt('file_name', 'my_kernel')
kernel_name = get_opt('kernel_name', file_name)
header_name = get_opt('header_name', f'{file_name}.h')
mode        = get_opt('mode', 'stream').lower()
if mode not in ('stream', 'window'):
    print("ERROR: 'mode' must be 'stream' or 'window'", file=sys.stderr)
    sys.exit(1)

# ➊ Print all the parameters to the console
print("=== Kernel generation parameters ===")
print(f"  file_name   = {file_name}")
print(f"  kernel_name = {kernel_name}")
print(f"  header_name = {header_name}")
print(f"  mode        = {mode}")
print("  streams:")
for role in ('input1', 'input2', 'output1', 'output2'):
    t = get_opt(f'{role}_type')
    s = get_opt(f'{role}_size')
    if t and s:
        print(f"    {role}: type={t}, size={s}")
print("======================================\n")

# -------------------------
# 3) Type→bitwidth map
# -------------------------
type_bw = {
    'int8_t': 8,   'uint8_t': 8,
    'int16_t': 16, 'uint16_t': 16,
    'int32_t': 32, 'uint32_t': 32,
    'int64_t': 64, 'uint64_t': 64,
    'float': 32,   'double': 64
}

# -------------------------
# 4) Collect streams
# -------------------------
streams = []
for role in ('input1', 'input2', 'output1', 'output2'):
    t = get_opt(f'{role}_type')
    s = get_opt(f'{role}_size')
    if not (t and s):
        continue
    try:
        vs = int(s)
    except ValueError:
        print(f"ERROR: {role}_size must be an integer", file=sys.stderr)
        sys.exit(1)
    if t not in type_bw:
        print(f"ERROR: unknown type '{t}' for {role}", file=sys.stderr)
        sys.exit(1)
    if vs * type_bw[t] > 1024:
        print(f"ERROR: {role}: {vs * type_bw[t]} bits exceeds 1024-bit limit", file=sys.stderr)
        sys.exit(1)
    streams.append((role, t, vs))

inputs  = [s for s in streams if s[0].startswith('input')]
outputs = [s for s in streams if s[0].startswith('output')]

# -------------------------
# 5) Build function signature
# -------------------------
params = []
for r, t, _ in inputs:
    if mode == 'stream':
        params.append(f"input_stream<{t}>* restrict {r}")
    else:
        params.append(f"input_window<{t}>* {r}")
for r, t, _ in outputs:
    if mode == 'stream':
        params.append(f"output_stream<{t}>* restrict {r}")
    else:
        params.append(f"output_window<{t}>* {r}")
param_str = ',\n                   '.join(params)

# -------------------------
# 6) Include guard & filenames
# -------------------------
base, _   = os.path.splitext(header_name)
guard     = base.upper().replace('.', '_') + '_H'
cpp_name  = f"{file_name}.cpp"

# -------------------------
# 7) Compute-function stub
# -------------------------
compute_args = []
for r, t, vs in inputs:
    compute_args.append(f"aie::vector<{t},{vs}>& vec_{r}")
for r, t, vs in outputs:
    compute_args.append(f"aie::vector<{t},{vs}>& result_{r}")
compute_sig = f"void compute_function({', '.join(compute_args)})"
compute_def = f"""{compute_sig}
{{
    // to be filled with user logic
}}
"""

# -------------------------
# 8) Generate .cpp
# -------------------------
lines = [
    f'/* Auto-generated ({mode} mode) */',
    f'#include "{header_name}"',
    '#include "common.h"',
    '#include "aie_api/aie.hpp"',
    '#include "aie_api/aie_adf.hpp"',
    '#include "aie_api/utils.hpp"',
    '',
    '// user compute stub',
    compute_def,
    '',
    f'void {kernel_name}(',
    f'                   {param_str}',
    ')',
    '{'
]

if mode == 'stream':
    if inputs:
        r0, t0, vs0 = inputs[0]
        lines += [
            '    // read header for iteration count',
            f'    aie::vector<{t0},{vs0}> header = readincr_v<{vs0}>({r0});',
            '    int tot_iterations = header[0];',
            '',
            '    for (int i = 0; i < tot_iterations; i++) {'
        ]
    for r, t, vs in inputs:
        lines.append(f'        aie::vector<{t},{vs}> vec_{r} = readincr_v<{vs}>({r});')
    for r, t, vs in outputs:
        lines.append(f'        aie::vector<{t},{vs}> result_{r};')
    vecs = [f"vec_{r}" for r, _, _ in inputs]
    ress = [f"result_{r}" for r, _, _ in outputs]
    lines += [
        '',
        f'        compute_function({", ".join(vecs + ress)});',
        ''
    ]
    for r, _, _ in outputs:
        lines.append(f'        writeincr({r}, result_{r});')
    lines.append('    }')

else:
    if inputs:
        r0, t0, vs0 = inputs[0]
        lines += [
            '    // read header for iteration count',
            f'    window_acquire({r0});',
            f'    aie::vector<{t0},{vs0}> header = window_readincr_v{vs0}({r0});',
            f'    window_release({r0});',
            '    int tot_iterations = header[0];',
            '',
            '    for (int i = 0; i < tot_iterations; i++) {'
        ]
    for r, t, vs in inputs:
        lines += [
            f'        window_acquire({r});',
            f'        aie::vector<{t},{vs}> vec_{r} = window_readincr_v{vs}({r});',
            f'        window_release({r});'
        ]
    for r, t, vs in outputs:
        lines.append(f'        aie::vector<{t},{vs}> result_{r};')
    vecs = [f"vec_{r}" for r, _, _ in inputs]
    ress = [f"result_{r}" for r, _, _ in outputs]
    lines += [
        '',
        f'        compute_function({", ".join(vecs + ress)});',
        ''
    ]
    for r, _, _ in outputs:
        lines += [
            f'        window_acquire({r});',
            f'        window_writeincr({r}, result_{r});',
            f'        window_release({r});'
        ]
    lines.append('    }')

lines.append('}')

cpp_content = '\n'.join(lines)

# -------------------------
# 9) Generate .h
# -------------------------
hdr = [
    f'#ifndef {guard}',
    f'#define {guard}',
    '',
    '#include "common.h"',
    '#include "aie_api/aie.hpp"',
    '#include "aie_api/aie_adf.hpp"',
    '#include "aie_api/utils.hpp"',
    '',
    '// user compute prototype',
    compute_sig + ';',
    '',
    f'// kernel prototype ({mode} mode)',
    f'void {kernel_name}(',
    f'                   {param_str}',
    ');',
    '',
    f'#endif // {guard}'
]
hdr_content = '\n'.join(hdr)

with open(cpp_name,    'w') as f: f.write(cpp_content)
with open(header_name, 'w') as f: f.write(hdr_content)

print(f"Generated ({mode} mode):\n - {cpp_name}\n - {header_name}")
