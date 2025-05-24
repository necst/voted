# Skip first 3 args which are -f, scriptname, --
set script_args [lrange $argv 3 end]

if {[llength $script_args] != 5} {
    puts "Usage: vitis_hls -f full_test_hls.tcl -- <PROJ_ROOT> <SRC_FILE> <TB_FILE> <SRC_BASE> <PART_NAME>"
    puts "You passed [llength $script_args] arguments."
    exit 1
}

set PROJ_ROOT [lindex $script_args 0]
set SRC_FILE  [lindex $script_args 1]
set TB_FILE   [lindex $script_args 2]
set SRC_BASE  [lindex $script_args 3]
set PART_NAME [lindex $script_args 4]

puts "DEBUG: PROJECT ROOT = '$PROJ_ROOT'"
puts "DEBUG: SRC_FILE = '$SRC_FILE'"
puts "DEBUG: TB_FILE = '$TB_FILE'"
puts "DEBUG: SRC_BASE = '$SRC_BASE'"
puts "DEBUG: PART_NAME = '$PART_NAME'"
flush stdout

open_project $PROJ_ROOT
set_top $SRC_BASE
add_files "$PROJ_ROOT/build/$SRC_FILE"
add_files -tb "$PROJ_ROOT/build/testbench/$TB_FILE"
open_solution solution1
set_part $PART_NAME
create_clock -period 4 -name default

csim_design
csynth_design
cosim_design