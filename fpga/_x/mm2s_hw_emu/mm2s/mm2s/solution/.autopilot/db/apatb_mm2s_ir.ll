; ModuleID = '/home/gsorrentino/projects/voted_hdl/voted/fpga/_x/mm2s_hw_emu/mm2s/mm2s/solution/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"struct.ap_int<128>" = type { %"struct.ap_int_base<128, true>" }
%"struct.ap_int_base<128, true>" = type { %"struct.ssdm_int<128, true>" }
%"struct.ssdm_int<128, true>" = type { i128 }
%"class.hls::stream<ap_int<128>, 0>" = type { %"struct.ap_int<128>" }

; Function Attrs: inaccessiblememonly nounwind
declare void @llvm.sideeffect() #0

; Function Attrs: inaccessiblemem_or_argmemonly noinline
define void @apatb_mm2s_ir(i32 %size, %"struct.ap_int<128>"* noalias nocapture nonnull readonly "maxi" %inputA, %"struct.ap_int<128>"* noalias nocapture nonnull readonly "maxi" %inputB, %"class.hls::stream<ap_int<128>, 0>"* noalias nocapture nonnull dereferenceable(16) %outA, %"class.hls::stream<ap_int<128>, 0>"* noalias nocapture nonnull dereferenceable(16) %outB) local_unnamed_addr #1 {
entry:
  %inputA_copy = alloca [100 x i128], align 512
  %inputB_copy = alloca [100 x i128], align 512
  %outA_copy = alloca i128, align 512
  call void @llvm.sideeffect() #9 [ "stream_interface"(i128* %outA_copy, i32 0) ]
  %outB_copy = alloca i128, align 512
  call void @llvm.sideeffect() #9 [ "stream_interface"(i128* %outB_copy, i32 0) ]
  %0 = bitcast %"struct.ap_int<128>"* %inputA to [100 x %"struct.ap_int<128>"]*
  %1 = bitcast %"struct.ap_int<128>"* %inputB to [100 x %"struct.ap_int<128>"]*
  call fastcc void @copy_in([100 x %"struct.ap_int<128>"]* nonnull %0, [100 x i128]* nonnull align 512 %inputA_copy, [100 x %"struct.ap_int<128>"]* nonnull %1, [100 x i128]* nonnull align 512 %inputB_copy, %"class.hls::stream<ap_int<128>, 0>"* nonnull %outA, i128* nonnull align 512 %outA_copy, %"class.hls::stream<ap_int<128>, 0>"* nonnull %outB, i128* nonnull align 512 %outB_copy)
  call void @apatb_mm2s_hw(i32 %size, [100 x i128]* %inputA_copy, [100 x i128]* %inputB_copy, i128* %outA_copy, i128* %outB_copy)
  call void @copy_back([100 x %"struct.ap_int<128>"]* %0, [100 x i128]* %inputA_copy, [100 x %"struct.ap_int<128>"]* %1, [100 x i128]* %inputB_copy, %"class.hls::stream<ap_int<128>, 0>"* %outA, i128* %outA_copy, %"class.hls::stream<ap_int<128>, 0>"* %outB, i128* %outB_copy)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_in([100 x %"struct.ap_int<128>"]* noalias readonly "unpacked"="0", [100 x i128]* noalias nocapture align 512 "unpacked"="1.0", [100 x %"struct.ap_int<128>"]* noalias readonly "unpacked"="2", [100 x i128]* noalias nocapture align 512 "unpacked"="3.0", %"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="4", i128* noalias nocapture align 512 "unpacked"="5.0", %"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="6", i128* noalias nocapture align 512 "unpacked"="7.0") unnamed_addr #2 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a100struct.ap_int<128>.30"([100 x i128]* align 512 %1, [100 x %"struct.ap_int<128>"]* %0)
  call fastcc void @"onebyonecpy_hls.p0a100struct.ap_int<128>.30"([100 x i128]* align 512 %3, [100 x %"struct.ap_int<128>"]* %2)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>.12"(i128* align 512 %5, %"class.hls::stream<ap_int<128>, 0>"* %4)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>.12"(i128* align 512 %7, %"class.hls::stream<ap_int<128>, 0>"* %6)
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define void @"arraycpy_hls.p0a100struct.ap_int<128>"([100 x %"struct.ap_int<128>"]* %dst, [100 x %"struct.ap_int<128>"]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [100 x %"struct.ap_int<128>"]* %src, null
  %1 = icmp eq [100 x %"struct.ap_int<128>"]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond7 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond7, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx8 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [100 x %"struct.ap_int<128>"], [100 x %"struct.ap_int<128>"]* %src, i64 0, i64 %for.loop.idx8, i32 0, i32 0, i32 0
  %dst.addr.0.0.06 = getelementptr [100 x %"struct.ap_int<128>"], [100 x %"struct.ap_int<128>"]* %dst, i64 0, i64 %for.loop.idx8, i32 0, i32 0, i32 0
  %3 = load i128, i128* %src.addr.0.0.05, align 16
  store i128 %3, i128* %dst.addr.0.0.06, align 16
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx8, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_out([100 x %"struct.ap_int<128>"]* noalias "unpacked"="0", [100 x i128]* noalias nocapture readonly align 512 "unpacked"="1.0", [100 x %"struct.ap_int<128>"]* noalias "unpacked"="2", [100 x i128]* noalias nocapture readonly align 512 "unpacked"="3.0", %"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="4", i128* noalias nocapture align 512 "unpacked"="5.0", %"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="6", i128* noalias nocapture align 512 "unpacked"="7.0") unnamed_addr #4 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a100struct.ap_int<128>"([100 x %"struct.ap_int<128>"]* %0, [100 x i128]* align 512 %1)
  call fastcc void @"onebyonecpy_hls.p0a100struct.ap_int<128>"([100 x %"struct.ap_int<128>"]* %2, [100 x i128]* align 512 %3)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* %4, i128* align 512 %5)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* %6, i128* align 512 %7)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="0" %dst, i128* noalias nocapture align 512 "unpacked"="1.0" %src) unnamed_addr #5 {
entry:
  %0 = icmp eq %"class.hls::stream<ap_int<128>, 0>"* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call fastcc void @"streamcpy_hls.p0class.hls::stream<ap_int<128>, 0>.7"(%"class.hls::stream<ap_int<128>, 0>"* nonnull %dst, i128* align 512 %src)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @"streamcpy_hls.p0class.hls::stream<ap_int<128>, 0>.7"(%"class.hls::stream<ap_int<128>, 0>"* noalias nocapture "unpacked"="0", i128* noalias nocapture align 512 "unpacked"="1.0") unnamed_addr #6 {
entry:
  %2 = alloca i128
  %3 = alloca %"class.hls::stream<ap_int<128>, 0>"
  br label %empty

empty:                                            ; preds = %push, %entry
  %4 = bitcast i128* %1 to i8*
  %5 = call i1 @fpga_fifo_not_empty_16(i8* %4)
  br i1 %5, label %push, label %ret

push:                                             ; preds = %empty
  %6 = bitcast i128* %2 to i8*
  %7 = bitcast i128* %1 to i8*
  call void @fpga_fifo_pop_16(i8* %6, i8* %7)
  %8 = load volatile i128, i128* %2
  %.ivi = insertvalue %"class.hls::stream<ap_int<128>, 0>" undef, i128 %8, 0, 0, 0, 0
  store %"class.hls::stream<ap_int<128>, 0>" %.ivi, %"class.hls::stream<ap_int<128>, 0>"* %3
  %9 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %3 to i8*
  %10 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %0 to i8*
  call void @fpga_fifo_push_16(i8* %9, i8* %10)
  br label %empty, !llvm.loop !5

ret:                                              ; preds = %empty
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>.12"(i128* noalias nocapture align 512 "unpacked"="0.0" %dst, %"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="1" %src) unnamed_addr #5 {
entry:
  %0 = icmp eq %"class.hls::stream<ap_int<128>, 0>"* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call fastcc void @"streamcpy_hls.p0class.hls::stream<ap_int<128>, 0>.15"(i128* align 512 %dst, %"class.hls::stream<ap_int<128>, 0>"* nonnull %src)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @"streamcpy_hls.p0class.hls::stream<ap_int<128>, 0>.15"(i128* noalias nocapture align 512 "unpacked"="0.0", %"class.hls::stream<ap_int<128>, 0>"* noalias nocapture "unpacked"="1") unnamed_addr #6 {
entry:
  %2 = alloca %"class.hls::stream<ap_int<128>, 0>"
  %3 = alloca i128
  br label %empty

empty:                                            ; preds = %push, %entry
  %4 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %1 to i8*
  %5 = call i1 @fpga_fifo_not_empty_16(i8* %4)
  br i1 %5, label %push, label %ret

push:                                             ; preds = %empty
  %6 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %2 to i8*
  %7 = bitcast %"class.hls::stream<ap_int<128>, 0>"* %1 to i8*
  call void @fpga_fifo_pop_16(i8* %6, i8* %7)
  %8 = load volatile %"class.hls::stream<ap_int<128>, 0>", %"class.hls::stream<ap_int<128>, 0>"* %2
  %.evi = extractvalue %"class.hls::stream<ap_int<128>, 0>" %8, 0, 0, 0, 0
  store i128 %.evi, i128* %3
  %9 = bitcast i128* %3 to i8*
  %10 = bitcast i128* %0 to i8*
  call void @fpga_fifo_push_16(i8* %9, i8* %10)
  br label %empty, !llvm.loop !7

ret:                                              ; preds = %empty
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @"onebyonecpy_hls.p0a100struct.ap_int<128>"([100 x %"struct.ap_int<128>"]* noalias "unpacked"="0" %dst, [100 x i128]* noalias nocapture readonly align 512 "unpacked"="1.0" %src) unnamed_addr #7 {
entry:
  %0 = icmp eq [100 x %"struct.ap_int<128>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a100struct.ap_int<128>.26"([100 x %"struct.ap_int<128>"]* nonnull %dst, [100 x i128]* %src, i64 100)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define void @"arraycpy_hls.p0a100struct.ap_int<128>.26"([100 x %"struct.ap_int<128>"]* "unpacked"="0" %dst, [100 x i128]* nocapture readonly "unpacked"="1.0" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [100 x %"struct.ap_int<128>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [100 x i128], [100 x i128]* %src, i64 0, i64 %for.loop.idx2
  %dst.addr.0.0.06 = getelementptr [100 x %"struct.ap_int<128>"], [100 x %"struct.ap_int<128>"]* %dst, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %1 = load i128, i128* %src.addr.0.0.05, align 16
  store i128 %1, i128* %dst.addr.0.0.06, align 16
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @"onebyonecpy_hls.p0a100struct.ap_int<128>.30"([100 x i128]* noalias nocapture align 512 "unpacked"="0.0" %dst, [100 x %"struct.ap_int<128>"]* noalias readonly "unpacked"="1" %src) unnamed_addr #7 {
entry:
  %0 = icmp eq [100 x %"struct.ap_int<128>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a100struct.ap_int<128>.33"([100 x i128]* %dst, [100 x %"struct.ap_int<128>"]* nonnull %src, i64 100)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define void @"arraycpy_hls.p0a100struct.ap_int<128>.33"([100 x i128]* nocapture "unpacked"="0.0" %dst, [100 x %"struct.ap_int<128>"]* readonly "unpacked"="1" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [100 x %"struct.ap_int<128>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [100 x %"struct.ap_int<128>"], [100 x %"struct.ap_int<128>"]* %src, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %dst.addr.0.0.06 = getelementptr [100 x i128], [100 x i128]* %dst, i64 0, i64 %for.loop.idx2
  %1 = load i128, i128* %src.addr.0.0.05, align 16
  store i128 %1, i128* %dst.addr.0.0.06, align 16
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

declare void @apatb_mm2s_hw(i32, [100 x i128]*, [100 x i128]*, i128*, i128*)

; Function Attrs: argmemonly noinline
define internal fastcc void @copy_back([100 x %"struct.ap_int<128>"]* noalias "unpacked"="0", [100 x i128]* noalias nocapture readonly align 512 "unpacked"="1.0", [100 x %"struct.ap_int<128>"]* noalias "unpacked"="2", [100 x i128]* noalias nocapture readonly align 512 "unpacked"="3.0", %"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="4", i128* noalias nocapture align 512 "unpacked"="5.0", %"class.hls::stream<ap_int<128>, 0>"* noalias "unpacked"="6", i128* noalias nocapture align 512 "unpacked"="7.0") unnamed_addr #4 {
entry:
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* %4, i128* align 512 %5)
  call fastcc void @"onebyonecpy_hls.p0class.hls::stream<ap_int<128>, 0>"(%"class.hls::stream<ap_int<128>, 0>"* %6, i128* align 512 %7)
  ret void
}

define void @mm2s_hw_stub_wrapper(i32, [100 x i128]*, [100 x i128]*, i128*, i128*) #8 {
entry:
  %5 = alloca [100 x %"struct.ap_int<128>"]
  %6 = alloca [100 x %"struct.ap_int<128>"]
  %7 = alloca %"class.hls::stream<ap_int<128>, 0>"
  %8 = alloca %"class.hls::stream<ap_int<128>, 0>"
  call void @copy_out([100 x %"struct.ap_int<128>"]* %5, [100 x i128]* %1, [100 x %"struct.ap_int<128>"]* %6, [100 x i128]* %2, %"class.hls::stream<ap_int<128>, 0>"* %7, i128* %3, %"class.hls::stream<ap_int<128>, 0>"* %8, i128* %4)
  %9 = bitcast [100 x %"struct.ap_int<128>"]* %5 to %"struct.ap_int<128>"*
  %10 = bitcast [100 x %"struct.ap_int<128>"]* %6 to %"struct.ap_int<128>"*
  call void @mm2s_hw_stub(i32 %0, %"struct.ap_int<128>"* %9, %"struct.ap_int<128>"* %10, %"class.hls::stream<ap_int<128>, 0>"* %7, %"class.hls::stream<ap_int<128>, 0>"* %8)
  call void @copy_in([100 x %"struct.ap_int<128>"]* %5, [100 x i128]* %1, [100 x %"struct.ap_int<128>"]* %6, [100 x i128]* %2, %"class.hls::stream<ap_int<128>, 0>"* %7, i128* %3, %"class.hls::stream<ap_int<128>, 0>"* %8, i128* %4)
  ret void
}

declare void @mm2s_hw_stub(i32, %"struct.ap_int<128>"*, %"struct.ap_int<128>"*, %"class.hls::stream<ap_int<128>, 0>"*, %"class.hls::stream<ap_int<128>, 0>"*)

declare i1 @fpga_fifo_not_empty_16(i8*)

declare void @fpga_fifo_pop_16(i8*, i8*)

declare void @fpga_fifo_push_16(i8*, i8*)

attributes #0 = { inaccessiblememonly nounwind }
attributes #1 = { inaccessiblemem_or_argmemonly noinline "fpga.wrapper.func"="wrapper" }
attributes #2 = { argmemonly noinline "fpga.wrapper.func"="copyin" }
attributes #3 = { argmemonly noinline norecurse "fpga.wrapper.func"="arraycpy_hls" }
attributes #4 = { argmemonly noinline "fpga.wrapper.func"="copyout" }
attributes #5 = { argmemonly noinline "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #6 = { argmemonly noinline "fpga.wrapper.func"="streamcpy_hls" }
attributes #7 = { argmemonly noinline norecurse "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #8 = { "fpga.wrapper.func"="stub" }
attributes #9 = { inaccessiblememonly nounwind "xlx.port.bitwidth"="128" "xlx.source"="user" }

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
!7 = distinct !{!7, !6}
