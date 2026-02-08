set SynModuleInfo {
  {SRCNAME mm2s_Pipeline_VITIS_LOOP_47_1 MODELNAME mm2s_Pipeline_VITIS_LOOP_47_1 RTLNAME mm2s_mm2s_Pipeline_VITIS_LOOP_47_1
    SUBMODULES {
      {MODELNAME mm2s_flow_control_loop_pipe_sequential_init RTLNAME mm2s_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME mm2s_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME mm2s MODELNAME mm2s RTLNAME mm2s IS_TOP 1
    SUBMODULES {
      {MODELNAME mm2s_gmem1_m_axi RTLNAME mm2s_gmem1_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME mm2s_gmem2_m_axi RTLNAME mm2s_gmem2_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME mm2s_control_s_axi RTLNAME mm2s_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
      {MODELNAME mm2s_regslice_both RTLNAME mm2s_regslice_both BINDTYPE interface TYPE interface_regslice INSTNAME mm2s_regslice_both_U}
    }
  }
}
