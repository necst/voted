# scripts/pack_xo_axis.tcl
# Args:
#   <part> <kernel_name> <xo_path> <ip_dir> <kernel_xml> <rtl_files...>

set part       [lindex $argv 0]
set kname      [lindex $argv 1]
set xo_path    [lindex $argv 2]
set ip_dir     [lindex $argv 3]
set rtl_files  [lrange $argv 5 end]

puts "PART=$part KERNEL=$kname XO=$xo_path IP_DIR=$ip_dir RTL=$rtl_files"

# -----------------------------------------------------------------------------
# Create an out-of-context project and synthesize the RTL top
# -----------------------------------------------------------------------------
create_project -force ${kname}_pack _vivado_${kname} -part $part
set_property target_language Verilog [current_project]

add_files -norecurse $rtl_files
update_compile_order -fileset sources_1
set_property top $kname [current_fileset]

if {[catch {synth_design -top $kname -part $part -mode out_of_context -flatten_hierarchy none} synth_msg]} {
  puts "ERROR: synthesis failed for $kname"
  puts $synth_msg
  exit 2
}

# Minimal required ports for stream-only Vitis RTL kernel
set required_ports [list ap_clk ap_rst_n]
set missing {}
foreach p $required_ports {
  if {[llength [get_ports -quiet $p]] == 0} {
    lappend missing $p
  }
}
if {[llength $missing] != 0} {
  puts "ERROR: Missing required ports for stream-only kernel packaging:"
  foreach m $missing { puts "  - $m" }
  exit 3
}

close_design

# -----------------------------------------------------------------------------
# Package as IP and mark as Vitis RTL kernel
# -----------------------------------------------------------------------------
ipx::package_project \
  -root_dir $ip_dir \
  -vendor user.org -library user -taxonomy /UserIP \
  -import_files -set_current true

set core [ipx::current_core]
set_property sdx_kernel true     $core
set_property sdx_kernel_type rtl $core

# -----------------------------------------------------------------------------
# Associate AXIS bus interfaces to ap_clk and set clock frequency
# (Vivado 2023.1: do it as BUS PARAMETERS on the ap_clk BUS INTERFACE)
# -----------------------------------------------------------------------------
set busifs_expected [list s_axis_a s_axis_b m_axis_out]

# Get the ap_clk bus interface (should exist: xilinx.com:signal:clock:1.0)
set clk_bif [ipx::get_bus_interfaces ap_clk -of_objects $core]
if {[llength $clk_bif] == 0} {
  puts "ERROR: Could not find ipx bus interface 'ap_clk' (clock) in packaged core."
  exit 4
}

# Build list of busifs that actually exist
set assoc_list {}
foreach b $busifs_expected {
  set bobj [ipx::get_bus_interfaces $b -of_objects $core]
  if {[llength $bobj] != 0} {
    lappend assoc_list $b
  } else {
    puts "WARNING: Bus interface '$b' not found in IP-XACT; not associating to ap_clk."
  }
}

# Helper: set or create a bus parameter on a bus interface
proc set_bus_param {bif pname pvalue} {
  set p [ipx::get_bus_parameters -of_objects $bif $pname]
  if {[llength $p] == 0} {
    set p [ipx::add_bus_parameter $pname $bif]
  }
  set_property value $pvalue $p
}

if {[llength $assoc_list] != 0} {
  set assoc_str [join $assoc_list ":"]
  set_bus_param $clk_bif "ASSOCIATED_BUSIF" $assoc_str
  puts "INFO: Set ap_clk bus parameter ASSOCIATED_BUSIF = $assoc_str"
} else {
  puts "WARNING: No AXIS bus interfaces found to associate with ap_clk."
}

# Set clock frequency on clock bus interface (200 MHz)
set_bus_param $clk_bif "FREQ_HZ" "200000000"
puts "INFO: Set ap_clk bus parameter FREQ_HZ = 200000000"
# -----------------------------------------------------------------------------
# Archive sources, integrity check, save core
# -----------------------------------------------------------------------------
ipx::update_source_project_archive -component $core

if {[catch {ipx::check_integrity $core} integ_msg]} {
  puts "ERROR: ipx::check_integrity failed."
  puts $integ_msg
  exit 5
}

ipx::save_core $core

# -----------------------------------------------------------------------------
# Create XO
# NOTE: Do NOT pass -kernel_xml here, to avoid forcing language="rtl" in the XO.
# -----------------------------------------------------------------------------
package_xo -force \
  -xo_path $xo_path \
  -kernel_name $kname \
  -ctrl_protocol ap_ctrl_none \
  -ip_directory $ip_dir

puts "DONE: Generated $xo_path"
exit 0
