; ModuleID = '/home/users/giuseppe.sorrentino/VOTED/FPGA/_x/setup_aie_hw/setup_aie/setup_aie/solution/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"class.hls::stream<ap_int<128>, 0>" = type { %"struct.ap_int<128>" }
%"struct.ap_int<128>" = type { %"struct.ap_int_base<128, true>" }
%"struct.ap_int_base<128, true>" = type { %"struct.ssdm_int<128, true>" }
%"struct.ssdm_int<128, true>" = type { i128 }

; Function Attrs: inaccessiblememonly nounwind
declare void @llvm.sideeffect() #0

; Function Attrs: inaccessiblemem_or_argmemonly noinline
define void @apatb_setup_aie_ir(i32 %size, i32* noalias nocapture nonnull readonly %input, %"class.hls::stream<ap_int<128>, 0>"* noalias nocapture nonnull dereferenceable(16) %s) local_unnamed_addr #1 {
entry:
  %input_copy = alloca [100 x i32], align 512
  %s_copy = alloca %"class.hls::stream<ap_int<128>, 0>", align 512
  call void @llvm.sideeffect() #8 [ "stream_interface"(%"class.hls::stream<ap_int<128>, 0>"* %s_copy, i32 0) ]
  %0 = bitcast i32* %input to [100 x i32]*
  call fastcc void @copy_in([100 x i32]* nonnull %0, [100 x i32]* nonnull align 512 %input_copy, %"class.hls::stream<ap_int<128>, 0>"* nonnull %s, %"class.hls::stream<ap_int<128>, 0>"* nonnull align 512 %s_copy)
  %1 = getelementptr inbounds [100 x i32], [100 x i32]* %input_copy, i32 0, i32 0
  call void @apatb_setup_aie_hw(i32 %size, i32* %1, %"class.hls::stream<ap_int<128>, 0>"* %s_copy)
  call void @copy_back([100 x i32]* %0, [100 x i32]* %input_copy, %"class.hls::stream<ap_int<128>, 0>"* %s, %"class.hls::stream<ap_int<128>, 0>"* %s_copy)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_in([100 x i32]* noalias readonly, [100 x i32]* noalias align 512, %"class.hls::stream<ap_int<128>, 0>"* noalias, %"class.hls::stream<ap_int<128>, 0>"* noalias align 512 "fpga.caller.interfaces"="layout_transformed") unnamed_addr #2 {
entry:
  call fastcc void @onebyonecpy_hls.p0a100i32([100 x i32]* align 512 %1, [100 x i32]* %0)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* align 512 %3, %"class.hls::stream<ap_int<128>, 0>"* %2)
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @onebyonecpy_hls.p0a100i32([100 x i32]* noalias align 512, [100 x i32]* noalias readonly) unnamed_addr #3 {
entry:
  %2 = icmp eq [100 x i32]* %0, null
  %3 = icmp eq [100 x i32]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx1 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [100 x i32], [100 x i32]* %0, i64 0, i64 %for.loop.idx1
  %src.addr = getelementptr [100 x i32], [100 x i32]* %1, i64 0, i64 %for.loop.idx1
  %5 = load i32, i32* %src.addr, align 4
  store i32 %5, i32* %dst.addr, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx1, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 100
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* noalias align 512 "fpga.caller.interfaces"="layout_transformed", %"class.hls::stream<ap_int<128>, 0>"* noalias "fpga.caller.interfaces"="layout_transformed") unnamed_addr #4 {
entry:
  %2 = icmp eq %"class.hls::stream<ap_int<128>, 0>"* %0, null
  %3 = icmp eq %"class.hls::stream<ap_int<128>, 0>"* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  call fastcc void @"streamcpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* nonnull align 512 %0, %"class.hls::stream<ap_int<128>, 0>"* nonnull %1)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @"streamcpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* noalias nocapture align 512 "fpga.caller.interfaces"="layout_transformed", %"class.hls::stream<ap_int<128>, 0>"* noalias nocapture "fpga.caller.interfaces"="layout_transformed") unnamed_addr #5 {
entry:
  %2 = alloca %"class.hls::stream<ap_int<128>, 0>"
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_16(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %2 to i8*
  %6 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %1 to i8*
  call void @fpga_fifo_pop_16(i8* %5, i8* %6)
  %7 = load volatile %"class.hls::stream<ap_int<128>, 0>", %"class.hls::stream<ap_int<128>, 0>"* %2
  %8 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %2 to i8*
  %9 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %0 to i8*
  call void @fpga_fifo_push_16(i8* %8, i8* %9)
  br label %empty, !llvm.loop !5

ret:                                              ; preds = %empty
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_out([100 x i32]* noalias, [100 x i32]* noalias readonly align 512, %"class.hls::stream<ap_int<128>, 0>"* noalias, %"class.hls::stream<ap_int<128>, 0>"* noalias align 512 "fpga.caller.interfaces"="layout_transformed") unnamed_addr #6 {
entry:
  call fastcc void @onebyonecpy_hls.p0a100i32([100 x i32]* %0, [100 x i32]* align 512 %1)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* %2, %"class.hls::stream<ap_int<128>, 0>"* align 512 %3)
  ret void
}

declare void @apatb_setup_aie_hw(i32, i32*, %"class.hls::stream<ap_int<128>, 0>"*)

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_back([100 x i32]* noalias, [100 x i32]* noalias readonly align 512, %"class.hls::stream<ap_int<128>, 0>"* noalias, %"class.hls::stream<ap_int<128>, 0>"* noalias align 512 "fpga.caller.interfaces"="layout_transformed") unnamed_addr #6 {
entry:
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* %2, %"class.hls::stream<ap_int<128>, 0>"* align 512 %3)
  ret void
}

define void @setup_aie_hw_stub_wrapper(i32, i32*, %"class.hls::stream<ap_int<128>, 0>"*) #7 {
entry:
  %3 = bitcast i32* %1 to [100 x i32]*
  call void @copy_out([100 x i32]* null, [100 x i32]* %3, %"class.hls::stream<ap_int<128>, 0>"* null, %"class.hls::stream<ap_int<128>, 0>"* %2)
  %4 = bitcast [100 x i32]* %3 to i32*
  call void @setup_aie_hw_stub(i32 %0, i32* %4, %"class.hls::stream<ap_int<128>, 0>"* %2)
  call void @copy_in([100 x i32]* null, [100 x i32]* %3, %"class.hls::stream<ap_int<128>, 0>"* null, %"class.hls::stream<ap_int<128>, 0>"* %2)
  ret void
}

declare void @setup_aie_hw_stub(i32, i32*, %"class.hls::stream<ap_int<128>, 0>"*)

declare i1 @fpga_fifo_not_empty_16(i8*)

declare void @fpga_fifo_pop_16(i8*, i8*)

declare void @fpga_fifo_push_16(i8*, i8*)

attributes #0 = { inaccessiblememonly nounwind }
attributes #1 = { inaccessiblemem_or_argmemonly noinline "fpga.wrapper.func"="wrapper" }
attributes #2 = { argmemonly noinline "fpga.wrapper.func"="copyin" }
attributes #3 = { argmemonly noinline norecurse "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #4 = { argmemonly noinline "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #5 = { argmemonly noinline "fpga.wrapper.func"="streamcpy_hls" }
attributes #6 = { argmemonly noinline "fpga.wrapper.func"="copyout" }
attributes #7 = { "fpga.wrapper.func"="stub" }
attributes #8 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="128" "xlx.source"="user" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.rotate.disable"}
