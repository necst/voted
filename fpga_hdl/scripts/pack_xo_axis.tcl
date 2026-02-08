# scripts/pack_xo_axis.tcl
# Args:
#   <part> <kernel_name> <xo_path> <ip_dir> <kernel_xml> <rtl_files...>

set part       [lindex $argv 0]
set kname      [lindex $argv 1]
set xo_path    [lindex $argv 2]
set ip_dir     [lindex $argv 3]
set kernel_xml [lindex $argv 4]
set rtl_files  [lrange $argv 5 end]

puts "PART=$part KERNEL=$kname XO=$xo_path IP_DIR=$ip_dir KERNEL_XML=$kernel_xml RTL=$rtl_files"

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

ipx::package_project \
  -root_dir $ip_dir \
  -vendor user.org -library user -taxonomy /UserIP \
  -import_files -set_current true

set_property sdx_kernel true     [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]

ipx::update_source_project_archive -component [ipx::current_core]
ipx::save_core [ipx::current_core]

package_xo -force \
  -xo_path $xo_path \
  -kernel_name $kname \
  -ctrl_protocol ap_ctrl_none \
  -kernel_xml $kernel_xml \
  -ip_directory $ip_dir

puts "DONE: Generated $xo_path"
exit 0
