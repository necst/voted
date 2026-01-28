# scripts/pack_xo.tcl
# Usage:
#   vivado -mode batch -source scripts/pack_xo.tcl \
#     -tclargs <part> <kernel_name> <xo_path> <ip_dir> <kernel_xml> <rtl_files...>

set part       [lindex $argv 0]
set kname      [lindex $argv 1]
set xo_path    [lindex $argv 2]
set ip_dir     [lindex $argv 3]
set kernel_xml [lindex $argv 4]
set rtl_files  [lrange $argv 5 end]

puts "PART=$part KERNEL=$kname XO=$xo_path IP_DIR=$ip_dir KERNEL_XML=$kernel_xml RTL=$rtl_files"

if { $part eq "" || $kname eq "" || $xo_path eq "" || $ip_dir eq "" || $kernel_xml eq "" || [llength $rtl_files] == 0 } {
  puts "ERROR: args missing."
  puts "Expected: <part> <kernel_name> <xo_path> <ip_dir> <kernel_xml> <rtl_files...>"
  exit 1
}

# Create temp project
create_project -force ${kname}_pack _vivado_${kname} -part $part
set_property target_language Verilog [current_project]

# Add RTL
add_files -norecurse $rtl_files
update_compile_order -fileset sources_1
set_property top $kname [current_fileset]

# ----------------------------
# TEST 1: sanity check ports
# ----------------------------
# Need elaboration to query ports reliably
if {[catch {synth_design -top $kname -part $part -mode out_of_context -flatten_hierarchy none} synth_msg]} {
  puts "ERROR: synthesis failed for $kname"
  puts $synth_msg
  exit 2
}

# Required ports
set required_ports [list ap_clk ap_rst_n \
  s_axi_control_awaddr s_axi_control_awvalid s_axi_control_awready \
  s_axi_control_wdata  s_axi_control_wstrb  s_axi_control_wvalid  s_axi_control_wready \
  s_axi_control_bresp  s_axi_control_bvalid s_axi_control_bready \
  s_axi_control_araddr s_axi_control_arvalid s_axi_control_arready \
  s_axi_control_rdata  s_axi_control_rresp  s_axi_control_rvalid  s_axi_control_rready \
]

set missing {}
foreach p $required_ports {
  if {[llength [get_ports -quiet $p]] == 0} {
    lappend missing $p
  }
}

if {[llength $missing] != 0} {
  puts "ERROR: Missing required ports for Vitis kernel packaging:"
  foreach m $missing { puts "  - $m" }
  exit 3
}

# ----------------------------
# TEST 2: synth reports (resources/timing)
# ----------------------------
file mkdir build
report_utilization -hierarchical -file "build/util_${kname}.rpt"
report_timing_summary -max_paths 10 -file "build/timing_${kname}.rpt"
puts "INFO: Wrote build/util_${kname}.rpt and build/timing_${kname}.rpt"

# Close synthesized design so IP packaging doesn't get confused
close_design

# ----------------------------
# Package as IP (let Vivado infer interfaces as much as possible)
# ----------------------------
ipx::package_project \
  -root_dir $ip_dir \
  -vendor user.org -library user -taxonomy /UserIP \
  -import_files -set_current true

set_property sdx_kernel true     [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]

ipx::update_source_project_archive -component [ipx::current_core]
ipx::save_core [ipx::current_core]

# ----------------------------
# Generate XO (kernel args come from kernel_xml)
# ----------------------------
package_xo -force \
  -xo_path $xo_path \
  -kernel_name $kname \
  -ctrl_protocol ap_ctrl_hs \
  -kernel_xml $kernel_xml \
  -ip_directory $ip_dir

puts "DONE: Generated $xo_path"
exit 0
