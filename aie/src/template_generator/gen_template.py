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
if mode == 'window':
    conn = get_opt('communication', 'sync')  # sync/async

# -------------------------
# 3) Print parameters
# -------------------------
print("=== Kernel generation parameters ===")
print(f"  file_name   = {file_name}")
print(f"  kernel_name = {kernel_name}")
print(f"  header_name = {header_name}")
print(f"  mode        = {mode}")
print(f"  communication = {conn if mode=='window' else 'N/A'}")
print("  streams:")
for role in ('input1', 'input2', 'output1', 'output2'):
    t = get_opt(f'{role}_type')
    s = get_opt(f'{role}_size')
    if t and s:
        print(f"    {role}: type={t}, size={s}")
print("======================================\n")

# -------------------------
# 4) Type → bitwidth map
# -------------------------
type_bw = {
    'int8_t': 8,   'uint8_t': 8,
    'int16_t': 16, 'uint16_t': 16,
    'int32_t': 32, 'uint32_t': 32,
    'int64_t': 64, 'uint64_t': 64,
    'float': 32,   'double': 64
}

# -------------------------
# 5) Collect streams
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
# 6) Build function signature
# -------------------------
# window type mapping
window_type_map = {
    'int8_t': 'int8', 'int16_t': 'int16', 'int32_t': 'int32', 'int64_t': 'int64',
    'uint8_t': 'uint8', 'uint16_t': 'uint16', 'uint32_t': 'uint32', 'uint64_t': 'uint64',
    'float': 'float', 'double': 'float'
}

params = []
for r, t, _ in inputs:
    if mode == 'stream':
        params.append(f"input_stream<{t}>* restrict {r}")
    else:
        wtype = window_type_map[t]
        params.append(f"input_window_{wtype}* {r}")
for r, t, _ in outputs:
    if mode == 'stream':
        params.append(f"output_stream<{t}>* restrict {r}")
    else:
        wtype = window_type_map[t]
        params.append(f"output_window_{wtype}* {r}")
param_str = ',\n                   '.join(params)

# -------------------------
# 7) Include guard & filenames
# -------------------------
base, _   = os.path.splitext(header_name)
guard     = base.upper().replace('.', '_') + '_H'
cpp_name  = f"{file_name}.cpp"

# -------------------------
# 8) Compute-function stub
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
# 9) Generate .cpp
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
    # window mode
    if conn == 'sync':
        for i, (r, t, vs) in enumerate(inputs):
            wtype = window_type_map[t]
            if i == 0:
                lines += [
                    '    // read header for iteration count',
                    f'    aie::vector<{t},{vs}> header = window_readincr_v{vs}({r});',
                    '    int tot_iterations = header[0];',
                    '',
                    '    for (int i = 0; i < tot_iterations; i++) {'
                ]
            lines.append(f'        aie::vector<{t},{vs}> vec_{r} = window_readincr_v{vs}({r});')
        for r, t, vs in outputs:
            lines.append(f'        aie::vector<{t},{vs}> result_{r};')
        vecs = [f"vec_{r}" for r, _, _ in inputs]
        ress = [f"result_{r}" for r, _, _ in outputs]
        lines += [
            '',
            f'        compute_function({", ".join(vecs + ress)});',
            ''
        ]
        for r, t, vs in outputs:
            lines.append(f'        window_writeincr({r}, result_{r});')
        lines.append('    }')
    else:
        for i, (r, t, vs) in enumerate(inputs):
            wtype = window_type_map[t]  # tipo corretto per la window
            if i == 0:
                lines += [
                    '    // read header for iteration count',
                    f'    window_acquire({r});',
                    f'    aie::vector<{t},{vs}> header = window_readincr_v{vs}({r});',
                    f'    window_release({r});',
                    '    int tot_iterations = header[0];',
                    '',
                    '    for (int i = 0; i < tot_iterations; i++) {'
                ]
            lines += [
                f'        window_acquire({r});',
                f'        aie::vector<{t},{vs}> vec_{r} = window_readincr_v{vs}({r});',
                f'        window_release({r});'
            ]

        for r, t, vs in outputs:
            lines += [
                f'        aie::vector<{t},{vs}> result_{r};',
                f'        window_acquire({r});',
                f'        window_writeincr({r}, result_{r});',
                f'        window_release({r});'
            ]

        vecs = [f"vec_{r}" for r, _, _ in inputs]
        ress = [f"result_{r}" for r, _, _ in outputs]
        lines += [
            '',
            f'        compute_function({", ".join(vecs + ress)});',
            ''
        ]

        lines.append('    }')

lines.append('}')

cpp_content = '\n'.join(lines)

# -------------------------
# 10) Generate .h
# -------------------------
hdr = [
    f'#ifndef {guard}',
    f'#define {guard}',
    '',
    '#include "common.h"',
    '#include "aie_api/aie.hpp"',
    '#include "aie_api/aie_adf.hpp"',
    '#include "aie_api/utils.hpp"',
    '#include <adf.h>',   # aggiunto
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

# -------------------------
# 11) Write output
# -------------------------
out_cpp    = os.path.join('..', cpp_name)
out_header = os.path.join('..', header_name)

os.makedirs(os.path.dirname(out_cpp) or '..', exist_ok=True)

with open(out_cpp, 'w') as f: f.write(cpp_content)
with open(out_header, 'w') as f: f.write(hdr_content)

print(f"Generated ({mode} mode):\n - {out_cpp}\n - {out_header}")
