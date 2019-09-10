
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/dpu_eu_v2_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Arch [ipgui::add_page $IPINST -name "Arch"]
  ipgui::add_param $IPINST -name "VER_DPU_NUM" -parent ${Arch} -widget comboBox
  ipgui::add_param $IPINST -name "ARCH" -parent ${Arch} -widget comboBox
  set IBGRP_N [ipgui::add_param $IPINST -name "IBGRP_N" -parent ${Arch} -widget comboBox]
  set_property tooltip {Select whether more on-chip RAMs are used} ${IBGRP_N}
  set DWCV_ENA [ipgui::add_param $IPINST -name "DWCV_ENA" -parent ${Arch} -widget comboBox]
  set_property tooltip {Enablement of DepthWiseConv} ${DWCV_ENA}
  set POOL_AVG_EN [ipgui::add_param $IPINST -name "POOL_AVG_EN" -parent ${Arch} -widget comboBox]
  set_property tooltip {Enablement of AveragePool} ${POOL_AVG_EN}
  #Adding Group
  set CONV [ipgui::add_group $IPINST -name "CONV" -parent ${Arch} -display_name {Conv}]
  set CONV_RELU_ADDON [ipgui::add_param $IPINST -name "CONV_RELU_ADDON" -parent ${CONV} -widget comboBox]
  set_property tooltip {Select the ReLU Type of Conv.
                                                                        } ${CONV_RELU_ADDON}

  #Adding Group
  set SFM [ipgui::add_group $IPINST -name "SFM" -parent ${Arch} -display_name {Softmax}]
  ipgui::add_param $IPINST -name "SFM_ENA" -parent ${SFM} -widget comboBox


  #Adding Page
  set Advanced [ipgui::add_page $IPINST -name "Advanced"]
  ipgui::add_param $IPINST -name "S_AXI_CLK_INDEPENDENT" -parent ${Advanced} -layout horizontal
  #Adding Group
  set IMPL [ipgui::add_group $IPINST -name "IMPL" -parent ${Advanced} -display_name {Implementation}]
  set CONV_DSP_CASC_MAX [ipgui::add_param $IPINST -name "CONV_DSP_CASC_MAX" -parent ${IMPL}]
  set_property tooltip {Select maximal length of DSP48 slice cascade chain} ${CONV_DSP_CASC_MAX}
  set CONV_DSP_ACCU_ENA [ipgui::add_param $IPINST -name "CONV_DSP_ACCU_ENA" -parent ${IMPL} -widget comboBox]
  set_property tooltip {Select whether more DSP Slices are used} ${CONV_DSP_ACCU_ENA}
  set URAM_N_USER [ipgui::add_param $IPINST -name "URAM_N_USER" -parent ${IMPL} -show_range false]
  set_property tooltip {Select utilization of Ultra-RAM per DPU} ${URAM_N_USER}

  #Adding Group
  set TMSTP [ipgui::add_group $IPINST -name "TMSTP" -parent ${Advanced} -display_name {TIMESTAMP}]
  set TIMESTAMP_ENA [ipgui::add_param $IPINST -name "TIMESTAMP_ENA" -parent ${TMSTP} -widget comboBox]
  set_property tooltip {Select whether the timestamp will be auto-update} ${TIMESTAMP_ENA}


  #Adding Page
  set Summary [ipgui::add_page $IPINST -name "Summary"]
  ipgui::add_param $IPINST -name "VER_INSTR_VER" -parent ${Summary}
  ipgui::add_param $IPINST -name "AXI_PROTOCOL_SUM" -parent ${Summary} -widget comboBox
  ipgui::add_param $IPINST -name "S_AXI_DATA_BW" -parent ${Summary}
  ipgui::add_param $IPINST -name "GP_DATA_BW" -parent ${Summary}
  ipgui::add_param $IPINST -name "HP_DATA_BW_SUM" -parent ${Summary} -widget comboBox
  ipgui::add_param $IPINST -name "SFM_HP_DATA_BW_SUM" -parent ${Summary} -widget comboBox
  ipgui::add_param $IPINST -name "GP_ID_BW" -parent ${Summary} -show_range false
  ipgui::add_param $IPINST -name "DSP_NUM" -parent ${Summary}
  ipgui::add_param $IPINST -name "URAM_N" -parent ${Summary}
  ipgui::add_param $IPINST -name "BRAM_N" -parent ${Summary}
  ipgui::add_static_text $IPINST -name "text_timer" -parent ${Summary} -text {NOTICE: THIS IP IS AVAILABLE FOR 8 HOURS !}


}

proc update_PARAM_VALUE.AWRLEN_BW { PARAM_VALUE.AWRLEN_BW PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to update AWRLEN_BW when any of the dependent parameters in the arguments change
	
	set AWRLEN_BW ${PARAM_VALUE.AWRLEN_BW}
	set AXI_PROTOCOL ${PARAM_VALUE.AXI_PROTOCOL}
	set values(AXI_PROTOCOL) [get_property value $AXI_PROTOCOL]
	set_property value [gen_USERPARAMETER_AWRLEN_BW_VALUE $values(AXI_PROTOCOL)] $AWRLEN_BW
}

proc validate_PARAM_VALUE.AWRLEN_BW { PARAM_VALUE.AWRLEN_BW } {
	# Procedure called to validate AWRLEN_BW
	return true
}

proc update_PARAM_VALUE.AWRLOCK_BW { PARAM_VALUE.AWRLOCK_BW PARAM_VALUE.AWRLEN_BW } {
	# Procedure called to update AWRLOCK_BW when any of the dependent parameters in the arguments change
	
	set AWRLOCK_BW ${PARAM_VALUE.AWRLOCK_BW}
	set AWRLEN_BW ${PARAM_VALUE.AWRLEN_BW}
	set values(AWRLEN_BW) [get_property value $AWRLEN_BW]
	set_property value [gen_USERPARAMETER_AWRLOCK_BW_VALUE $values(AWRLEN_BW)] $AWRLOCK_BW
}

proc validate_PARAM_VALUE.AWRLOCK_BW { PARAM_VALUE.AWRLOCK_BW } {
	# Procedure called to validate AWRLOCK_BW
	return true
}

proc update_PARAM_VALUE.AXI_PROTOCOL_SUM { PARAM_VALUE.AXI_PROTOCOL_SUM PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to update AXI_PROTOCOL_SUM when any of the dependent parameters in the arguments change
	
	set AXI_PROTOCOL_SUM ${PARAM_VALUE.AXI_PROTOCOL_SUM}
	set AXI_PROTOCOL ${PARAM_VALUE.AXI_PROTOCOL}
	set values(AXI_PROTOCOL) [get_property value $AXI_PROTOCOL]
	set_property value [gen_USERPARAMETER_AXI_PROTOCOL_SUM_VALUE $values(AXI_PROTOCOL)] $AXI_PROTOCOL_SUM
}

proc validate_PARAM_VALUE.AXI_PROTOCOL_SUM { PARAM_VALUE.AXI_PROTOCOL_SUM } {
	# Procedure called to validate AXI_PROTOCOL_SUM
	return true
}

proc update_PARAM_VALUE.BANK_IMG_N { PARAM_VALUE.BANK_IMG_N PARAM_VALUE.IBGRP_N PARAM_VALUE.PP } {
	# Procedure called to update BANK_IMG_N when any of the dependent parameters in the arguments change
	
	set BANK_IMG_N ${PARAM_VALUE.BANK_IMG_N}
	set IBGRP_N ${PARAM_VALUE.IBGRP_N}
	set PP ${PARAM_VALUE.PP}
	set values(IBGRP_N) [get_property value $IBGRP_N]
	set values(PP) [get_property value $PP]
	set_property value [gen_USERPARAMETER_BANK_IMG_N_VALUE $values(IBGRP_N) $values(PP)] $BANK_IMG_N
}

proc validate_PARAM_VALUE.BANK_IMG_N { PARAM_VALUE.BANK_IMG_N } {
	# Procedure called to validate BANK_IMG_N
	return true
}

proc update_PARAM_VALUE.BANK_WGT_N { PARAM_VALUE.BANK_WGT_N PARAM_VALUE.CP PARAM_VALUE.DWCV_ENA } {
	# Procedure called to update BANK_WGT_N when any of the dependent parameters in the arguments change
	
	set BANK_WGT_N ${PARAM_VALUE.BANK_WGT_N}
	set CP ${PARAM_VALUE.CP}
	set DWCV_ENA ${PARAM_VALUE.DWCV_ENA}
	set values(CP) [get_property value $CP]
	set values(DWCV_ENA) [get_property value $DWCV_ENA]
	set_property value [gen_USERPARAMETER_BANK_WGT_N_VALUE $values(CP) $values(DWCV_ENA)] $BANK_WGT_N
}

proc validate_PARAM_VALUE.BANK_WGT_N { PARAM_VALUE.BANK_WGT_N } {
	# Procedure called to validate BANK_WGT_N
	return true
}

proc update_PARAM_VALUE.BBANK_BIAS { PARAM_VALUE.BBANK_BIAS PARAM_VALUE.BANK_BIAS PARAM_VALUE.UBANK_BIAS PARAM_VALUE.DBANK_BIAS } {
	# Procedure called to update BBANK_BIAS when any of the dependent parameters in the arguments change
	
	set BBANK_BIAS ${PARAM_VALUE.BBANK_BIAS}
	set BANK_BIAS ${PARAM_VALUE.BANK_BIAS}
	set UBANK_BIAS ${PARAM_VALUE.UBANK_BIAS}
	set DBANK_BIAS ${PARAM_VALUE.DBANK_BIAS}
	set values(BANK_BIAS) [get_property value $BANK_BIAS]
	set values(UBANK_BIAS) [get_property value $UBANK_BIAS]
	set values(DBANK_BIAS) [get_property value $DBANK_BIAS]
	set_property value [gen_USERPARAMETER_BBANK_BIAS_VALUE $values(BANK_BIAS) $values(UBANK_BIAS) $values(DBANK_BIAS)] $BBANK_BIAS
}

proc validate_PARAM_VALUE.BBANK_BIAS { PARAM_VALUE.BBANK_BIAS } {
	# Procedure called to validate BBANK_BIAS
	return true
}

proc update_PARAM_VALUE.BBANK_IMG_N { PARAM_VALUE.BBANK_IMG_N PARAM_VALUE.BANK_IMG_N PARAM_VALUE.UBANK_IMG_N PARAM_VALUE.DBANK_IMG_N } {
	# Procedure called to update BBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set BBANK_IMG_N ${PARAM_VALUE.BBANK_IMG_N}
	set BANK_IMG_N ${PARAM_VALUE.BANK_IMG_N}
	set UBANK_IMG_N ${PARAM_VALUE.UBANK_IMG_N}
	set DBANK_IMG_N ${PARAM_VALUE.DBANK_IMG_N}
	set values(BANK_IMG_N) [get_property value $BANK_IMG_N]
	set values(UBANK_IMG_N) [get_property value $UBANK_IMG_N]
	set values(DBANK_IMG_N) [get_property value $DBANK_IMG_N]
	set_property value [gen_USERPARAMETER_BBANK_IMG_N_VALUE $values(BANK_IMG_N) $values(UBANK_IMG_N) $values(DBANK_IMG_N)] $BBANK_IMG_N
}

proc validate_PARAM_VALUE.BBANK_IMG_N { PARAM_VALUE.BBANK_IMG_N } {
	# Procedure called to validate BBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.BBANK_WGT_N { PARAM_VALUE.BBANK_WGT_N PARAM_VALUE.BANK_WGT_N PARAM_VALUE.UBANK_WGT_N PARAM_VALUE.DBANK_WGT_N } {
	# Procedure called to update BBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set BBANK_WGT_N ${PARAM_VALUE.BBANK_WGT_N}
	set BANK_WGT_N ${PARAM_VALUE.BANK_WGT_N}
	set UBANK_WGT_N ${PARAM_VALUE.UBANK_WGT_N}
	set DBANK_WGT_N ${PARAM_VALUE.DBANK_WGT_N}
	set values(BANK_WGT_N) [get_property value $BANK_WGT_N]
	set values(UBANK_WGT_N) [get_property value $UBANK_WGT_N]
	set values(DBANK_WGT_N) [get_property value $DBANK_WGT_N]
	set_property value [gen_USERPARAMETER_BBANK_WGT_N_VALUE $values(BANK_WGT_N) $values(UBANK_WGT_N) $values(DBANK_WGT_N)] $BBANK_WGT_N
}

proc validate_PARAM_VALUE.BBANK_WGT_N { PARAM_VALUE.BBANK_WGT_N } {
	# Procedure called to validate BBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.BRAM_N { PARAM_VALUE.BRAM_N PARAM_VALUE.VER_DPU_NUM PARAM_VALUE.BBANK_IMG_N PARAM_VALUE.BBANK_WGT_N PARAM_VALUE.BBANK_BIAS PARAM_VALUE.CP PARAM_VALUE.SFM_ENA } {
	# Procedure called to update BRAM_N when any of the dependent parameters in the arguments change
	
	set BRAM_N ${PARAM_VALUE.BRAM_N}
	set VER_DPU_NUM ${PARAM_VALUE.VER_DPU_NUM}
	set BBANK_IMG_N ${PARAM_VALUE.BBANK_IMG_N}
	set BBANK_WGT_N ${PARAM_VALUE.BBANK_WGT_N}
	set BBANK_BIAS ${PARAM_VALUE.BBANK_BIAS}
	set CP ${PARAM_VALUE.CP}
	set SFM_ENA ${PARAM_VALUE.SFM_ENA}
	set values(VER_DPU_NUM) [get_property value $VER_DPU_NUM]
	set values(BBANK_IMG_N) [get_property value $BBANK_IMG_N]
	set values(BBANK_WGT_N) [get_property value $BBANK_WGT_N]
	set values(BBANK_BIAS) [get_property value $BBANK_BIAS]
	set values(CP) [get_property value $CP]
	set values(SFM_ENA) [get_property value $SFM_ENA]
	set_property value [gen_USERPARAMETER_BRAM_N_VALUE $values(VER_DPU_NUM) $values(BBANK_IMG_N) $values(BBANK_WGT_N) $values(BBANK_BIAS) $values(CP) $values(SFM_ENA)] $BRAM_N
}

proc validate_PARAM_VALUE.BRAM_N { PARAM_VALUE.BRAM_N } {
	# Procedure called to validate BRAM_N
	return true
}

proc update_PARAM_VALUE.CONV_DSP_NUM { PARAM_VALUE.CONV_DSP_NUM PARAM_VALUE.PP PARAM_VALUE.CP PARAM_VALUE.CONV_DSP_ACCU_ENA } {
	# Procedure called to update CONV_DSP_NUM when any of the dependent parameters in the arguments change
	
	set CONV_DSP_NUM ${PARAM_VALUE.CONV_DSP_NUM}
	set PP ${PARAM_VALUE.PP}
	set CP ${PARAM_VALUE.CP}
	set CONV_DSP_ACCU_ENA ${PARAM_VALUE.CONV_DSP_ACCU_ENA}
	set values(PP) [get_property value $PP]
	set values(CP) [get_property value $CP]
	set values(CONV_DSP_ACCU_ENA) [get_property value $CONV_DSP_ACCU_ENA]
	set_property value [gen_USERPARAMETER_CONV_DSP_NUM_VALUE $values(PP) $values(CP) $values(CONV_DSP_ACCU_ENA)] $CONV_DSP_NUM
}

proc validate_PARAM_VALUE.CONV_DSP_NUM { PARAM_VALUE.CONV_DSP_NUM } {
	# Procedure called to validate CONV_DSP_NUM
	return true
}

proc update_PARAM_VALUE.CP { PARAM_VALUE.CP PARAM_VALUE.ARCH } {
	# Procedure called to update CP when any of the dependent parameters in the arguments change
	
	set CP ${PARAM_VALUE.CP}
	set ARCH ${PARAM_VALUE.ARCH}
	set values(ARCH) [get_property value $ARCH]
	set_property value [gen_USERPARAMETER_CP_VALUE $values(ARCH)] $CP
}

proc validate_PARAM_VALUE.CP { PARAM_VALUE.CP } {
	# Procedure called to validate CP
	return true
}

proc update_PARAM_VALUE.DPU1_DBANK_BIAS { PARAM_VALUE.DPU1_DBANK_BIAS PARAM_VALUE.DBANK_BIAS } {
	# Procedure called to update DPU1_DBANK_BIAS when any of the dependent parameters in the arguments change
	
	set DPU1_DBANK_BIAS ${PARAM_VALUE.DPU1_DBANK_BIAS}
	set DBANK_BIAS ${PARAM_VALUE.DBANK_BIAS}
	set values(DBANK_BIAS) [get_property value $DBANK_BIAS]
	set_property value [gen_USERPARAMETER_DPU1_DBANK_BIAS_VALUE $values(DBANK_BIAS)] $DPU1_DBANK_BIAS
}

proc validate_PARAM_VALUE.DPU1_DBANK_BIAS { PARAM_VALUE.DPU1_DBANK_BIAS } {
	# Procedure called to validate DPU1_DBANK_BIAS
	return true
}

proc update_PARAM_VALUE.DPU1_DBANK_IMG_N { PARAM_VALUE.DPU1_DBANK_IMG_N PARAM_VALUE.DBANK_IMG_N } {
	# Procedure called to update DPU1_DBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set DPU1_DBANK_IMG_N ${PARAM_VALUE.DPU1_DBANK_IMG_N}
	set DBANK_IMG_N ${PARAM_VALUE.DBANK_IMG_N}
	set values(DBANK_IMG_N) [get_property value $DBANK_IMG_N]
	set_property value [gen_USERPARAMETER_DPU1_DBANK_IMG_N_VALUE $values(DBANK_IMG_N)] $DPU1_DBANK_IMG_N
}

proc validate_PARAM_VALUE.DPU1_DBANK_IMG_N { PARAM_VALUE.DPU1_DBANK_IMG_N } {
	# Procedure called to validate DPU1_DBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.DPU1_DBANK_WGT_N { PARAM_VALUE.DPU1_DBANK_WGT_N PARAM_VALUE.DBANK_WGT_N } {
	# Procedure called to update DPU1_DBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set DPU1_DBANK_WGT_N ${PARAM_VALUE.DPU1_DBANK_WGT_N}
	set DBANK_WGT_N ${PARAM_VALUE.DBANK_WGT_N}
	set values(DBANK_WGT_N) [get_property value $DBANK_WGT_N]
	set_property value [gen_USERPARAMETER_DPU1_DBANK_WGT_N_VALUE $values(DBANK_WGT_N)] $DPU1_DBANK_WGT_N
}

proc validate_PARAM_VALUE.DPU1_DBANK_WGT_N { PARAM_VALUE.DPU1_DBANK_WGT_N } {
	# Procedure called to validate DPU1_DBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.DPU1_GP_ID_BW { PARAM_VALUE.DPU1_GP_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU1_GP_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU1_GP_ID_BW ${PARAM_VALUE.DPU1_GP_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU1_GP_ID_BW_VALUE $values(GP_ID_BW)] $DPU1_GP_ID_BW
}

proc validate_PARAM_VALUE.DPU1_GP_ID_BW { PARAM_VALUE.DPU1_GP_ID_BW } {
	# Procedure called to validate DPU1_GP_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU1_HP0_ID_BW { PARAM_VALUE.DPU1_HP0_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU1_HP0_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU1_HP0_ID_BW ${PARAM_VALUE.DPU1_HP0_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU1_HP0_ID_BW_VALUE $values(GP_ID_BW)] $DPU1_HP0_ID_BW
}

proc validate_PARAM_VALUE.DPU1_HP0_ID_BW { PARAM_VALUE.DPU1_HP0_ID_BW } {
	# Procedure called to validate DPU1_HP0_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU1_HP1_ID_BW { PARAM_VALUE.DPU1_HP1_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU1_HP1_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU1_HP1_ID_BW ${PARAM_VALUE.DPU1_HP1_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU1_HP1_ID_BW_VALUE $values(GP_ID_BW)] $DPU1_HP1_ID_BW
}

proc validate_PARAM_VALUE.DPU1_HP1_ID_BW { PARAM_VALUE.DPU1_HP1_ID_BW } {
	# Procedure called to validate DPU1_HP1_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU1_HP2_ID_BW { PARAM_VALUE.DPU1_HP2_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU1_HP2_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU1_HP2_ID_BW ${PARAM_VALUE.DPU1_HP2_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU1_HP2_ID_BW_VALUE $values(GP_ID_BW)] $DPU1_HP2_ID_BW
}

proc validate_PARAM_VALUE.DPU1_HP2_ID_BW { PARAM_VALUE.DPU1_HP2_ID_BW } {
	# Procedure called to validate DPU1_HP2_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU1_HP3_ID_BW { PARAM_VALUE.DPU1_HP3_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU1_HP3_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU1_HP3_ID_BW ${PARAM_VALUE.DPU1_HP3_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU1_HP3_ID_BW_VALUE $values(GP_ID_BW)] $DPU1_HP3_ID_BW
}

proc validate_PARAM_VALUE.DPU1_HP3_ID_BW { PARAM_VALUE.DPU1_HP3_ID_BW } {
	# Procedure called to validate DPU1_HP3_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU1_UBANK_BIAS { PARAM_VALUE.DPU1_UBANK_BIAS PARAM_VALUE.UBANK_BIAS_USER } {
	# Procedure called to update DPU1_UBANK_BIAS when any of the dependent parameters in the arguments change
	
	set DPU1_UBANK_BIAS ${PARAM_VALUE.DPU1_UBANK_BIAS}
	set UBANK_BIAS_USER ${PARAM_VALUE.UBANK_BIAS_USER}
	set values(UBANK_BIAS_USER) [get_property value $UBANK_BIAS_USER]
	set_property value [gen_USERPARAMETER_DPU1_UBANK_BIAS_VALUE $values(UBANK_BIAS_USER)] $DPU1_UBANK_BIAS
}

proc validate_PARAM_VALUE.DPU1_UBANK_BIAS { PARAM_VALUE.DPU1_UBANK_BIAS } {
	# Procedure called to validate DPU1_UBANK_BIAS
	return true
}

proc update_PARAM_VALUE.DPU1_UBANK_IMG_N { PARAM_VALUE.DPU1_UBANK_IMG_N PARAM_VALUE.UBANK_IMG_N_USER } {
	# Procedure called to update DPU1_UBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set DPU1_UBANK_IMG_N ${PARAM_VALUE.DPU1_UBANK_IMG_N}
	set UBANK_IMG_N_USER ${PARAM_VALUE.UBANK_IMG_N_USER}
	set values(UBANK_IMG_N_USER) [get_property value $UBANK_IMG_N_USER]
	set_property value [gen_USERPARAMETER_DPU1_UBANK_IMG_N_VALUE $values(UBANK_IMG_N_USER)] $DPU1_UBANK_IMG_N
}

proc validate_PARAM_VALUE.DPU1_UBANK_IMG_N { PARAM_VALUE.DPU1_UBANK_IMG_N } {
	# Procedure called to validate DPU1_UBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.DPU1_UBANK_WGT_N { PARAM_VALUE.DPU1_UBANK_WGT_N PARAM_VALUE.UBANK_WGT_N_USER } {
	# Procedure called to update DPU1_UBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set DPU1_UBANK_WGT_N ${PARAM_VALUE.DPU1_UBANK_WGT_N}
	set UBANK_WGT_N_USER ${PARAM_VALUE.UBANK_WGT_N_USER}
	set values(UBANK_WGT_N_USER) [get_property value $UBANK_WGT_N_USER]
	set_property value [gen_USERPARAMETER_DPU1_UBANK_WGT_N_VALUE $values(UBANK_WGT_N_USER)] $DPU1_UBANK_WGT_N
}

proc validate_PARAM_VALUE.DPU1_UBANK_WGT_N { PARAM_VALUE.DPU1_UBANK_WGT_N } {
	# Procedure called to validate DPU1_UBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.DPU2_DBANK_BIAS { PARAM_VALUE.DPU2_DBANK_BIAS PARAM_VALUE.DBANK_BIAS } {
	# Procedure called to update DPU2_DBANK_BIAS when any of the dependent parameters in the arguments change
	
	set DPU2_DBANK_BIAS ${PARAM_VALUE.DPU2_DBANK_BIAS}
	set DBANK_BIAS ${PARAM_VALUE.DBANK_BIAS}
	set values(DBANK_BIAS) [get_property value $DBANK_BIAS]
	set_property value [gen_USERPARAMETER_DPU2_DBANK_BIAS_VALUE $values(DBANK_BIAS)] $DPU2_DBANK_BIAS
}

proc validate_PARAM_VALUE.DPU2_DBANK_BIAS { PARAM_VALUE.DPU2_DBANK_BIAS } {
	# Procedure called to validate DPU2_DBANK_BIAS
	return true
}

proc update_PARAM_VALUE.DPU2_DBANK_IMG_N { PARAM_VALUE.DPU2_DBANK_IMG_N PARAM_VALUE.DBANK_IMG_N } {
	# Procedure called to update DPU2_DBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set DPU2_DBANK_IMG_N ${PARAM_VALUE.DPU2_DBANK_IMG_N}
	set DBANK_IMG_N ${PARAM_VALUE.DBANK_IMG_N}
	set values(DBANK_IMG_N) [get_property value $DBANK_IMG_N]
	set_property value [gen_USERPARAMETER_DPU2_DBANK_IMG_N_VALUE $values(DBANK_IMG_N)] $DPU2_DBANK_IMG_N
}

proc validate_PARAM_VALUE.DPU2_DBANK_IMG_N { PARAM_VALUE.DPU2_DBANK_IMG_N } {
	# Procedure called to validate DPU2_DBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.DPU2_DBANK_WGT_N { PARAM_VALUE.DPU2_DBANK_WGT_N PARAM_VALUE.DBANK_WGT_N } {
	# Procedure called to update DPU2_DBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set DPU2_DBANK_WGT_N ${PARAM_VALUE.DPU2_DBANK_WGT_N}
	set DBANK_WGT_N ${PARAM_VALUE.DBANK_WGT_N}
	set values(DBANK_WGT_N) [get_property value $DBANK_WGT_N]
	set_property value [gen_USERPARAMETER_DPU2_DBANK_WGT_N_VALUE $values(DBANK_WGT_N)] $DPU2_DBANK_WGT_N
}

proc validate_PARAM_VALUE.DPU2_DBANK_WGT_N { PARAM_VALUE.DPU2_DBANK_WGT_N } {
	# Procedure called to validate DPU2_DBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.DPU2_GP_ID_BW { PARAM_VALUE.DPU2_GP_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU2_GP_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU2_GP_ID_BW ${PARAM_VALUE.DPU2_GP_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU2_GP_ID_BW_VALUE $values(GP_ID_BW)] $DPU2_GP_ID_BW
}

proc validate_PARAM_VALUE.DPU2_GP_ID_BW { PARAM_VALUE.DPU2_GP_ID_BW } {
	# Procedure called to validate DPU2_GP_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU2_HP0_ID_BW { PARAM_VALUE.DPU2_HP0_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU2_HP0_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU2_HP0_ID_BW ${PARAM_VALUE.DPU2_HP0_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU2_HP0_ID_BW_VALUE $values(GP_ID_BW)] $DPU2_HP0_ID_BW
}

proc validate_PARAM_VALUE.DPU2_HP0_ID_BW { PARAM_VALUE.DPU2_HP0_ID_BW } {
	# Procedure called to validate DPU2_HP0_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU2_HP1_ID_BW { PARAM_VALUE.DPU2_HP1_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU2_HP1_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU2_HP1_ID_BW ${PARAM_VALUE.DPU2_HP1_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU2_HP1_ID_BW_VALUE $values(GP_ID_BW)] $DPU2_HP1_ID_BW
}

proc validate_PARAM_VALUE.DPU2_HP1_ID_BW { PARAM_VALUE.DPU2_HP1_ID_BW } {
	# Procedure called to validate DPU2_HP1_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU2_HP2_ID_BW { PARAM_VALUE.DPU2_HP2_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU2_HP2_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU2_HP2_ID_BW ${PARAM_VALUE.DPU2_HP2_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU2_HP2_ID_BW_VALUE $values(GP_ID_BW)] $DPU2_HP2_ID_BW
}

proc validate_PARAM_VALUE.DPU2_HP2_ID_BW { PARAM_VALUE.DPU2_HP2_ID_BW } {
	# Procedure called to validate DPU2_HP2_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU2_HP3_ID_BW { PARAM_VALUE.DPU2_HP3_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU2_HP3_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU2_HP3_ID_BW ${PARAM_VALUE.DPU2_HP3_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU2_HP3_ID_BW_VALUE $values(GP_ID_BW)] $DPU2_HP3_ID_BW
}

proc validate_PARAM_VALUE.DPU2_HP3_ID_BW { PARAM_VALUE.DPU2_HP3_ID_BW } {
	# Procedure called to validate DPU2_HP3_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU2_UBANK_BIAS { PARAM_VALUE.DPU2_UBANK_BIAS PARAM_VALUE.UBANK_BIAS_USER } {
	# Procedure called to update DPU2_UBANK_BIAS when any of the dependent parameters in the arguments change
	
	set DPU2_UBANK_BIAS ${PARAM_VALUE.DPU2_UBANK_BIAS}
	set UBANK_BIAS_USER ${PARAM_VALUE.UBANK_BIAS_USER}
	set values(UBANK_BIAS_USER) [get_property value $UBANK_BIAS_USER]
	set_property value [gen_USERPARAMETER_DPU2_UBANK_BIAS_VALUE $values(UBANK_BIAS_USER)] $DPU2_UBANK_BIAS
}

proc validate_PARAM_VALUE.DPU2_UBANK_BIAS { PARAM_VALUE.DPU2_UBANK_BIAS } {
	# Procedure called to validate DPU2_UBANK_BIAS
	return true
}

proc update_PARAM_VALUE.DPU2_UBANK_IMG_N { PARAM_VALUE.DPU2_UBANK_IMG_N PARAM_VALUE.UBANK_IMG_N_USER } {
	# Procedure called to update DPU2_UBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set DPU2_UBANK_IMG_N ${PARAM_VALUE.DPU2_UBANK_IMG_N}
	set UBANK_IMG_N_USER ${PARAM_VALUE.UBANK_IMG_N_USER}
	set values(UBANK_IMG_N_USER) [get_property value $UBANK_IMG_N_USER]
	set_property value [gen_USERPARAMETER_DPU2_UBANK_IMG_N_VALUE $values(UBANK_IMG_N_USER)] $DPU2_UBANK_IMG_N
}

proc validate_PARAM_VALUE.DPU2_UBANK_IMG_N { PARAM_VALUE.DPU2_UBANK_IMG_N } {
	# Procedure called to validate DPU2_UBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.DPU2_UBANK_WGT_N { PARAM_VALUE.DPU2_UBANK_WGT_N PARAM_VALUE.UBANK_WGT_N_USER } {
	# Procedure called to update DPU2_UBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set DPU2_UBANK_WGT_N ${PARAM_VALUE.DPU2_UBANK_WGT_N}
	set UBANK_WGT_N_USER ${PARAM_VALUE.UBANK_WGT_N_USER}
	set values(UBANK_WGT_N_USER) [get_property value $UBANK_WGT_N_USER]
	set_property value [gen_USERPARAMETER_DPU2_UBANK_WGT_N_VALUE $values(UBANK_WGT_N_USER)] $DPU2_UBANK_WGT_N
}

proc validate_PARAM_VALUE.DPU2_UBANK_WGT_N { PARAM_VALUE.DPU2_UBANK_WGT_N } {
	# Procedure called to validate DPU2_UBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.DPU3_DBANK_BIAS { PARAM_VALUE.DPU3_DBANK_BIAS PARAM_VALUE.DBANK_BIAS } {
	# Procedure called to update DPU3_DBANK_BIAS when any of the dependent parameters in the arguments change
	
	set DPU3_DBANK_BIAS ${PARAM_VALUE.DPU3_DBANK_BIAS}
	set DBANK_BIAS ${PARAM_VALUE.DBANK_BIAS}
	set values(DBANK_BIAS) [get_property value $DBANK_BIAS]
	set_property value [gen_USERPARAMETER_DPU3_DBANK_BIAS_VALUE $values(DBANK_BIAS)] $DPU3_DBANK_BIAS
}

proc validate_PARAM_VALUE.DPU3_DBANK_BIAS { PARAM_VALUE.DPU3_DBANK_BIAS } {
	# Procedure called to validate DPU3_DBANK_BIAS
	return true
}

proc update_PARAM_VALUE.DPU3_DBANK_IMG_N { PARAM_VALUE.DPU3_DBANK_IMG_N PARAM_VALUE.DBANK_IMG_N } {
	# Procedure called to update DPU3_DBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set DPU3_DBANK_IMG_N ${PARAM_VALUE.DPU3_DBANK_IMG_N}
	set DBANK_IMG_N ${PARAM_VALUE.DBANK_IMG_N}
	set values(DBANK_IMG_N) [get_property value $DBANK_IMG_N]
	set_property value [gen_USERPARAMETER_DPU3_DBANK_IMG_N_VALUE $values(DBANK_IMG_N)] $DPU3_DBANK_IMG_N
}

proc validate_PARAM_VALUE.DPU3_DBANK_IMG_N { PARAM_VALUE.DPU3_DBANK_IMG_N } {
	# Procedure called to validate DPU3_DBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.DPU3_DBANK_WGT_N { PARAM_VALUE.DPU3_DBANK_WGT_N PARAM_VALUE.DBANK_WGT_N } {
	# Procedure called to update DPU3_DBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set DPU3_DBANK_WGT_N ${PARAM_VALUE.DPU3_DBANK_WGT_N}
	set DBANK_WGT_N ${PARAM_VALUE.DBANK_WGT_N}
	set values(DBANK_WGT_N) [get_property value $DBANK_WGT_N]
	set_property value [gen_USERPARAMETER_DPU3_DBANK_WGT_N_VALUE $values(DBANK_WGT_N)] $DPU3_DBANK_WGT_N
}

proc validate_PARAM_VALUE.DPU3_DBANK_WGT_N { PARAM_VALUE.DPU3_DBANK_WGT_N } {
	# Procedure called to validate DPU3_DBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.DPU3_GP_ID_BW { PARAM_VALUE.DPU3_GP_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU3_GP_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU3_GP_ID_BW ${PARAM_VALUE.DPU3_GP_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU3_GP_ID_BW_VALUE $values(GP_ID_BW)] $DPU3_GP_ID_BW
}

proc validate_PARAM_VALUE.DPU3_GP_ID_BW { PARAM_VALUE.DPU3_GP_ID_BW } {
	# Procedure called to validate DPU3_GP_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU3_HP0_ID_BW { PARAM_VALUE.DPU3_HP0_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU3_HP0_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU3_HP0_ID_BW ${PARAM_VALUE.DPU3_HP0_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU3_HP0_ID_BW_VALUE $values(GP_ID_BW)] $DPU3_HP0_ID_BW
}

proc validate_PARAM_VALUE.DPU3_HP0_ID_BW { PARAM_VALUE.DPU3_HP0_ID_BW } {
	# Procedure called to validate DPU3_HP0_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU3_HP1_ID_BW { PARAM_VALUE.DPU3_HP1_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU3_HP1_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU3_HP1_ID_BW ${PARAM_VALUE.DPU3_HP1_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU3_HP1_ID_BW_VALUE $values(GP_ID_BW)] $DPU3_HP1_ID_BW
}

proc validate_PARAM_VALUE.DPU3_HP1_ID_BW { PARAM_VALUE.DPU3_HP1_ID_BW } {
	# Procedure called to validate DPU3_HP1_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU3_HP2_ID_BW { PARAM_VALUE.DPU3_HP2_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU3_HP2_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU3_HP2_ID_BW ${PARAM_VALUE.DPU3_HP2_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU3_HP2_ID_BW_VALUE $values(GP_ID_BW)] $DPU3_HP2_ID_BW
}

proc validate_PARAM_VALUE.DPU3_HP2_ID_BW { PARAM_VALUE.DPU3_HP2_ID_BW } {
	# Procedure called to validate DPU3_HP2_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU3_HP3_ID_BW { PARAM_VALUE.DPU3_HP3_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update DPU3_HP3_ID_BW when any of the dependent parameters in the arguments change
	
	set DPU3_HP3_ID_BW ${PARAM_VALUE.DPU3_HP3_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_DPU3_HP3_ID_BW_VALUE $values(GP_ID_BW)] $DPU3_HP3_ID_BW
}

proc validate_PARAM_VALUE.DPU3_HP3_ID_BW { PARAM_VALUE.DPU3_HP3_ID_BW } {
	# Procedure called to validate DPU3_HP3_ID_BW
	return true
}

proc update_PARAM_VALUE.DPU3_UBANK_BIAS { PARAM_VALUE.DPU3_UBANK_BIAS PARAM_VALUE.UBANK_BIAS_USER } {
	# Procedure called to update DPU3_UBANK_BIAS when any of the dependent parameters in the arguments change
	
	set DPU3_UBANK_BIAS ${PARAM_VALUE.DPU3_UBANK_BIAS}
	set UBANK_BIAS_USER ${PARAM_VALUE.UBANK_BIAS_USER}
	set values(UBANK_BIAS_USER) [get_property value $UBANK_BIAS_USER]
	set_property value [gen_USERPARAMETER_DPU3_UBANK_BIAS_VALUE $values(UBANK_BIAS_USER)] $DPU3_UBANK_BIAS
}

proc validate_PARAM_VALUE.DPU3_UBANK_BIAS { PARAM_VALUE.DPU3_UBANK_BIAS } {
	# Procedure called to validate DPU3_UBANK_BIAS
	return true
}

proc update_PARAM_VALUE.DPU3_UBANK_IMG_N { PARAM_VALUE.DPU3_UBANK_IMG_N PARAM_VALUE.UBANK_IMG_N_USER } {
	# Procedure called to update DPU3_UBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set DPU3_UBANK_IMG_N ${PARAM_VALUE.DPU3_UBANK_IMG_N}
	set UBANK_IMG_N_USER ${PARAM_VALUE.UBANK_IMG_N_USER}
	set values(UBANK_IMG_N_USER) [get_property value $UBANK_IMG_N_USER]
	set_property value [gen_USERPARAMETER_DPU3_UBANK_IMG_N_VALUE $values(UBANK_IMG_N_USER)] $DPU3_UBANK_IMG_N
}

proc validate_PARAM_VALUE.DPU3_UBANK_IMG_N { PARAM_VALUE.DPU3_UBANK_IMG_N } {
	# Procedure called to validate DPU3_UBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.DPU3_UBANK_WGT_N { PARAM_VALUE.DPU3_UBANK_WGT_N PARAM_VALUE.UBANK_WGT_N_USER } {
	# Procedure called to update DPU3_UBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set DPU3_UBANK_WGT_N ${PARAM_VALUE.DPU3_UBANK_WGT_N}
	set UBANK_WGT_N_USER ${PARAM_VALUE.UBANK_WGT_N_USER}
	set values(UBANK_WGT_N_USER) [get_property value $UBANK_WGT_N_USER]
	set_property value [gen_USERPARAMETER_DPU3_UBANK_WGT_N_VALUE $values(UBANK_WGT_N_USER)] $DPU3_UBANK_WGT_N
}

proc validate_PARAM_VALUE.DPU3_UBANK_WGT_N { PARAM_VALUE.DPU3_UBANK_WGT_N } {
	# Procedure called to validate DPU3_UBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.DSP_NUM { PARAM_VALUE.DSP_NUM PARAM_VALUE.LOAD_DSP_NUM PARAM_VALUE.CONV_DSP_NUM PARAM_VALUE.DWCV_DSP_NUM PARAM_VALUE.VER_DPU_NUM PARAM_VALUE.SFM_ENA PARAM_VALUE.SFM_DSP_NUM } {
	# Procedure called to update DSP_NUM when any of the dependent parameters in the arguments change
	
	set DSP_NUM ${PARAM_VALUE.DSP_NUM}
	set LOAD_DSP_NUM ${PARAM_VALUE.LOAD_DSP_NUM}
	set CONV_DSP_NUM ${PARAM_VALUE.CONV_DSP_NUM}
	set DWCV_DSP_NUM ${PARAM_VALUE.DWCV_DSP_NUM}
	set VER_DPU_NUM ${PARAM_VALUE.VER_DPU_NUM}
	set SFM_ENA ${PARAM_VALUE.SFM_ENA}
	set SFM_DSP_NUM ${PARAM_VALUE.SFM_DSP_NUM}
	set values(LOAD_DSP_NUM) [get_property value $LOAD_DSP_NUM]
	set values(CONV_DSP_NUM) [get_property value $CONV_DSP_NUM]
	set values(DWCV_DSP_NUM) [get_property value $DWCV_DSP_NUM]
	set values(VER_DPU_NUM) [get_property value $VER_DPU_NUM]
	set values(SFM_ENA) [get_property value $SFM_ENA]
	set values(SFM_DSP_NUM) [get_property value $SFM_DSP_NUM]
	set_property value [gen_USERPARAMETER_DSP_NUM_VALUE $values(LOAD_DSP_NUM) $values(CONV_DSP_NUM) $values(DWCV_DSP_NUM) $values(VER_DPU_NUM) $values(SFM_ENA) $values(SFM_DSP_NUM)] $DSP_NUM
}

proc validate_PARAM_VALUE.DSP_NUM { PARAM_VALUE.DSP_NUM } {
	# Procedure called to validate DSP_NUM
	return true
}

proc update_PARAM_VALUE.DWCV_DSP_NUM { PARAM_VALUE.DWCV_DSP_NUM PARAM_VALUE.PP PARAM_VALUE.CP PARAM_VALUE.DWCV_ENA } {
	# Procedure called to update DWCV_DSP_NUM when any of the dependent parameters in the arguments change
	
	set DWCV_DSP_NUM ${PARAM_VALUE.DWCV_DSP_NUM}
	set PP ${PARAM_VALUE.PP}
	set CP ${PARAM_VALUE.CP}
	set DWCV_ENA ${PARAM_VALUE.DWCV_ENA}
	set values(PP) [get_property value $PP]
	set values(CP) [get_property value $CP]
	set values(DWCV_ENA) [get_property value $DWCV_ENA]
	set_property value [gen_USERPARAMETER_DWCV_DSP_NUM_VALUE $values(PP) $values(CP) $values(DWCV_ENA)] $DWCV_DSP_NUM
}

proc validate_PARAM_VALUE.DWCV_DSP_NUM { PARAM_VALUE.DWCV_DSP_NUM } {
	# Procedure called to validate DWCV_DSP_NUM
	return true
}

proc update_PARAM_VALUE.HP0_ID_BW { PARAM_VALUE.HP0_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update HP0_ID_BW when any of the dependent parameters in the arguments change
	
	set HP0_ID_BW ${PARAM_VALUE.HP0_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_HP0_ID_BW_VALUE $values(GP_ID_BW)] $HP0_ID_BW
}

proc validate_PARAM_VALUE.HP0_ID_BW { PARAM_VALUE.HP0_ID_BW } {
	# Procedure called to validate HP0_ID_BW
	return true
}

proc update_PARAM_VALUE.HP1_ID_BW { PARAM_VALUE.HP1_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update HP1_ID_BW when any of the dependent parameters in the arguments change
	
	set HP1_ID_BW ${PARAM_VALUE.HP1_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_HP1_ID_BW_VALUE $values(GP_ID_BW)] $HP1_ID_BW
}

proc validate_PARAM_VALUE.HP1_ID_BW { PARAM_VALUE.HP1_ID_BW } {
	# Procedure called to validate HP1_ID_BW
	return true
}

proc update_PARAM_VALUE.HP2_ID_BW { PARAM_VALUE.HP2_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update HP2_ID_BW when any of the dependent parameters in the arguments change
	
	set HP2_ID_BW ${PARAM_VALUE.HP2_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_HP2_ID_BW_VALUE $values(GP_ID_BW)] $HP2_ID_BW
}

proc validate_PARAM_VALUE.HP2_ID_BW { PARAM_VALUE.HP2_ID_BW } {
	# Procedure called to validate HP2_ID_BW
	return true
}

proc update_PARAM_VALUE.HP3_ID_BW { PARAM_VALUE.HP3_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update HP3_ID_BW when any of the dependent parameters in the arguments change
	
	set HP3_ID_BW ${PARAM_VALUE.HP3_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_HP3_ID_BW_VALUE $values(GP_ID_BW)] $HP3_ID_BW
}

proc validate_PARAM_VALUE.HP3_ID_BW { PARAM_VALUE.HP3_ID_BW } {
	# Procedure called to validate HP3_ID_BW
	return true
}

proc update_PARAM_VALUE.HP_DATA_BW_SUM { PARAM_VALUE.HP_DATA_BW_SUM PARAM_VALUE.HP_DATA_BW } {
	# Procedure called to update HP_DATA_BW_SUM when any of the dependent parameters in the arguments change
	
	set HP_DATA_BW_SUM ${PARAM_VALUE.HP_DATA_BW_SUM}
	set HP_DATA_BW ${PARAM_VALUE.HP_DATA_BW}
	set values(HP_DATA_BW) [get_property value $HP_DATA_BW]
	set_property value [gen_USERPARAMETER_HP_DATA_BW_SUM_VALUE $values(HP_DATA_BW)] $HP_DATA_BW_SUM
}

proc validate_PARAM_VALUE.HP_DATA_BW_SUM { PARAM_VALUE.HP_DATA_BW_SUM } {
	# Procedure called to validate HP_DATA_BW_SUM
	return true
}

proc update_PARAM_VALUE.IRQ_SUM { PARAM_VALUE.IRQ_SUM PARAM_VALUE.AWRLEN_BW PARAM_VALUE.VER_DPU_NUM } {
	# Procedure called to update IRQ_SUM when any of the dependent parameters in the arguments change
	
	set IRQ_SUM ${PARAM_VALUE.IRQ_SUM}
	set AWRLEN_BW ${PARAM_VALUE.AWRLEN_BW}
	set VER_DPU_NUM ${PARAM_VALUE.VER_DPU_NUM}
	set values(AWRLEN_BW) [get_property value $AWRLEN_BW]
	set values(VER_DPU_NUM) [get_property value $VER_DPU_NUM]
	set_property value [gen_USERPARAMETER_IRQ_SUM_VALUE $values(AWRLEN_BW) $values(VER_DPU_NUM)] $IRQ_SUM
}

proc validate_PARAM_VALUE.IRQ_SUM { PARAM_VALUE.IRQ_SUM } {
	# Procedure called to validate IRQ_SUM
	return true
}

proc update_PARAM_VALUE.POOL_AVG_22 { PARAM_VALUE.POOL_AVG_22 PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_22 when any of the dependent parameters in the arguments change
	
	set POOL_AVG_22 ${PARAM_VALUE.POOL_AVG_22}
	set POOL_AVG_EN ${PARAM_VALUE.POOL_AVG_EN}
	set values(POOL_AVG_EN) [get_property value $POOL_AVG_EN]
	set_property value [gen_USERPARAMETER_POOL_AVG_22_VALUE $values(POOL_AVG_EN)] $POOL_AVG_22
}

proc validate_PARAM_VALUE.POOL_AVG_22 { PARAM_VALUE.POOL_AVG_22 } {
	# Procedure called to validate POOL_AVG_22
	return true
}

proc update_PARAM_VALUE.POOL_AVG_33 { PARAM_VALUE.POOL_AVG_33 PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_33 when any of the dependent parameters in the arguments change
	
	set POOL_AVG_33 ${PARAM_VALUE.POOL_AVG_33}
	set POOL_AVG_EN ${PARAM_VALUE.POOL_AVG_EN}
	set values(POOL_AVG_EN) [get_property value $POOL_AVG_EN]
	set_property value [gen_USERPARAMETER_POOL_AVG_33_VALUE $values(POOL_AVG_EN)] $POOL_AVG_33
}

proc validate_PARAM_VALUE.POOL_AVG_33 { PARAM_VALUE.POOL_AVG_33 } {
	# Procedure called to validate POOL_AVG_33
	return true
}

proc update_PARAM_VALUE.POOL_AVG_44 { PARAM_VALUE.POOL_AVG_44 PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_44 when any of the dependent parameters in the arguments change
	
	set POOL_AVG_44 ${PARAM_VALUE.POOL_AVG_44}
	set POOL_AVG_EN ${PARAM_VALUE.POOL_AVG_EN}
	set values(POOL_AVG_EN) [get_property value $POOL_AVG_EN]
	set_property value [gen_USERPARAMETER_POOL_AVG_44_VALUE $values(POOL_AVG_EN)] $POOL_AVG_44
}

proc validate_PARAM_VALUE.POOL_AVG_44 { PARAM_VALUE.POOL_AVG_44 } {
	# Procedure called to validate POOL_AVG_44
	return true
}

proc update_PARAM_VALUE.POOL_AVG_55 { PARAM_VALUE.POOL_AVG_55 PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_55 when any of the dependent parameters in the arguments change
	
	set POOL_AVG_55 ${PARAM_VALUE.POOL_AVG_55}
	set POOL_AVG_EN ${PARAM_VALUE.POOL_AVG_EN}
	set values(POOL_AVG_EN) [get_property value $POOL_AVG_EN]
	set_property value [gen_USERPARAMETER_POOL_AVG_55_VALUE $values(POOL_AVG_EN)] $POOL_AVG_55
}

proc validate_PARAM_VALUE.POOL_AVG_55 { PARAM_VALUE.POOL_AVG_55 } {
	# Procedure called to validate POOL_AVG_55
	return true
}

proc update_PARAM_VALUE.POOL_AVG_66 { PARAM_VALUE.POOL_AVG_66 PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_66 when any of the dependent parameters in the arguments change
	
	set POOL_AVG_66 ${PARAM_VALUE.POOL_AVG_66}
	set POOL_AVG_EN ${PARAM_VALUE.POOL_AVG_EN}
	set values(POOL_AVG_EN) [get_property value $POOL_AVG_EN]
	set_property value [gen_USERPARAMETER_POOL_AVG_66_VALUE $values(POOL_AVG_EN)] $POOL_AVG_66
}

proc validate_PARAM_VALUE.POOL_AVG_66 { PARAM_VALUE.POOL_AVG_66 } {
	# Procedure called to validate POOL_AVG_66
	return true
}

proc update_PARAM_VALUE.POOL_AVG_77 { PARAM_VALUE.POOL_AVG_77 PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_77 when any of the dependent parameters in the arguments change
	
	set POOL_AVG_77 ${PARAM_VALUE.POOL_AVG_77}
	set POOL_AVG_EN ${PARAM_VALUE.POOL_AVG_EN}
	set values(POOL_AVG_EN) [get_property value $POOL_AVG_EN]
	set_property value [gen_USERPARAMETER_POOL_AVG_77_VALUE $values(POOL_AVG_EN)] $POOL_AVG_77
}

proc validate_PARAM_VALUE.POOL_AVG_77 { PARAM_VALUE.POOL_AVG_77 } {
	# Procedure called to validate POOL_AVG_77
	return true
}

proc update_PARAM_VALUE.POOL_AVG_88 { PARAM_VALUE.POOL_AVG_88 PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_88 when any of the dependent parameters in the arguments change
	
	set POOL_AVG_88 ${PARAM_VALUE.POOL_AVG_88}
	set POOL_AVG_EN ${PARAM_VALUE.POOL_AVG_EN}
	set values(POOL_AVG_EN) [get_property value $POOL_AVG_EN]
	set_property value [gen_USERPARAMETER_POOL_AVG_88_VALUE $values(POOL_AVG_EN)] $POOL_AVG_88
}

proc validate_PARAM_VALUE.POOL_AVG_88 { PARAM_VALUE.POOL_AVG_88 } {
	# Procedure called to validate POOL_AVG_88
	return true
}

proc update_PARAM_VALUE.PP { PARAM_VALUE.PP PARAM_VALUE.ARCH } {
	# Procedure called to update PP when any of the dependent parameters in the arguments change
	
	set PP ${PARAM_VALUE.PP}
	set ARCH ${PARAM_VALUE.ARCH}
	set values(ARCH) [get_property value $ARCH]
	set_property value [gen_USERPARAMETER_PP_VALUE $values(ARCH)] $PP
}

proc validate_PARAM_VALUE.PP { PARAM_VALUE.PP } {
	# Procedure called to validate PP
	return true
}

proc update_PARAM_VALUE.SFM_ENA { PARAM_VALUE.SFM_ENA PARAM_VALUE.AWRLEN_BW } {
	# Procedure called to update SFM_ENA when any of the dependent parameters in the arguments change
	
	set SFM_ENA ${PARAM_VALUE.SFM_ENA}
	set AWRLEN_BW ${PARAM_VALUE.AWRLEN_BW}
	set values(AWRLEN_BW) [get_property value $AWRLEN_BW]
	if { [gen_USERPARAMETER_SFM_ENA_ENABLEMENT $values(AWRLEN_BW)] } {
		set_property enabled true $SFM_ENA
	} else {
		set_property enabled false $SFM_ENA
	}
}

proc validate_PARAM_VALUE.SFM_ENA { PARAM_VALUE.SFM_ENA } {
	# Procedure called to validate SFM_ENA
	return true
}

proc update_PARAM_VALUE.SFM_HP0_ID_BW { PARAM_VALUE.SFM_HP0_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update SFM_HP0_ID_BW when any of the dependent parameters in the arguments change
	
	set SFM_HP0_ID_BW ${PARAM_VALUE.SFM_HP0_ID_BW}
	set GP_ID_BW ${PARAM_VALUE.GP_ID_BW}
	set values(GP_ID_BW) [get_property value $GP_ID_BW]
	set_property value [gen_USERPARAMETER_SFM_HP0_ID_BW_VALUE $values(GP_ID_BW)] $SFM_HP0_ID_BW
}

proc validate_PARAM_VALUE.SFM_HP0_ID_BW { PARAM_VALUE.SFM_HP0_ID_BW } {
	# Procedure called to validate SFM_HP0_ID_BW
	return true
}

proc update_PARAM_VALUE.SFM_HP_DATA_BW_SUM { PARAM_VALUE.SFM_HP_DATA_BW_SUM PARAM_VALUE.SFM_HP_DATA_BW } {
	# Procedure called to update SFM_HP_DATA_BW_SUM when any of the dependent parameters in the arguments change
	
	set SFM_HP_DATA_BW_SUM ${PARAM_VALUE.SFM_HP_DATA_BW_SUM}
	set SFM_HP_DATA_BW ${PARAM_VALUE.SFM_HP_DATA_BW}
	set values(SFM_HP_DATA_BW) [get_property value $SFM_HP_DATA_BW]
	set_property value [gen_USERPARAMETER_SFM_HP_DATA_BW_SUM_VALUE $values(SFM_HP_DATA_BW)] $SFM_HP_DATA_BW_SUM
}

proc validate_PARAM_VALUE.SFM_HP_DATA_BW_SUM { PARAM_VALUE.SFM_HP_DATA_BW_SUM } {
	# Procedure called to validate SFM_HP_DATA_BW_SUM
	return true
}

proc update_PARAM_VALUE.SFM_IRQ_SUM { PARAM_VALUE.SFM_IRQ_SUM PARAM_VALUE.AWRLEN_BW PARAM_VALUE.SFM_ENA } {
	# Procedure called to update SFM_IRQ_SUM when any of the dependent parameters in the arguments change
	
	set SFM_IRQ_SUM ${PARAM_VALUE.SFM_IRQ_SUM}
	set AWRLEN_BW ${PARAM_VALUE.AWRLEN_BW}
	set SFM_ENA ${PARAM_VALUE.SFM_ENA}
	set values(AWRLEN_BW) [get_property value $AWRLEN_BW]
	set values(SFM_ENA) [get_property value $SFM_ENA]
	set_property value [gen_USERPARAMETER_SFM_IRQ_SUM_VALUE $values(AWRLEN_BW) $values(SFM_ENA)] $SFM_IRQ_SUM
}

proc validate_PARAM_VALUE.SFM_IRQ_SUM { PARAM_VALUE.SFM_IRQ_SUM } {
	# Procedure called to validate SFM_IRQ_SUM
	return true
}

proc update_PARAM_VALUE.S_AXI_AWRLEN_BW { PARAM_VALUE.S_AXI_AWRLEN_BW PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to update S_AXI_AWRLEN_BW when any of the dependent parameters in the arguments change
	
	set S_AXI_AWRLEN_BW ${PARAM_VALUE.S_AXI_AWRLEN_BW}
	set AXI_PROTOCOL ${PARAM_VALUE.AXI_PROTOCOL}
	set values(AXI_PROTOCOL) [get_property value $AXI_PROTOCOL]
	set_property value [gen_USERPARAMETER_S_AXI_AWRLEN_BW_VALUE $values(AXI_PROTOCOL)] $S_AXI_AWRLEN_BW
}

proc validate_PARAM_VALUE.S_AXI_AWRLEN_BW { PARAM_VALUE.S_AXI_AWRLEN_BW } {
	# Procedure called to validate S_AXI_AWRLEN_BW
	return true
}

proc update_PARAM_VALUE.S_AXI_ID_BW { PARAM_VALUE.S_AXI_ID_BW PARAM_VALUE.AWRLEN_BW } {
	# Procedure called to update S_AXI_ID_BW when any of the dependent parameters in the arguments change
	
	set S_AXI_ID_BW ${PARAM_VALUE.S_AXI_ID_BW}
	set AWRLEN_BW ${PARAM_VALUE.AWRLEN_BW}
	set values(AWRLEN_BW) [get_property value $AWRLEN_BW]
	set_property value [gen_USERPARAMETER_S_AXI_ID_BW_VALUE $values(AWRLEN_BW)] $S_AXI_ID_BW
}

proc validate_PARAM_VALUE.S_AXI_ID_BW { PARAM_VALUE.S_AXI_ID_BW } {
	# Procedure called to validate S_AXI_ID_BW
	return true
}

proc update_PARAM_VALUE.UBANK_BIAS { PARAM_VALUE.UBANK_BIAS PARAM_VALUE.UBANK_BIAS_USER } {
	# Procedure called to update UBANK_BIAS when any of the dependent parameters in the arguments change
	
	set UBANK_BIAS ${PARAM_VALUE.UBANK_BIAS}
	set UBANK_BIAS_USER ${PARAM_VALUE.UBANK_BIAS_USER}
	set values(UBANK_BIAS_USER) [get_property value $UBANK_BIAS_USER]
	set_property value [gen_USERPARAMETER_UBANK_BIAS_VALUE $values(UBANK_BIAS_USER)] $UBANK_BIAS
}

proc validate_PARAM_VALUE.UBANK_BIAS { PARAM_VALUE.UBANK_BIAS } {
	# Procedure called to validate UBANK_BIAS
	return true
}

proc update_PARAM_VALUE.UBANK_BIAS_USER { PARAM_VALUE.UBANK_BIAS_USER PARAM_VALUE.URAM_N_USER PARAM_VALUE.CP } {
	# Procedure called to update UBANK_BIAS_USER when any of the dependent parameters in the arguments change
	
	set UBANK_BIAS_USER ${PARAM_VALUE.UBANK_BIAS_USER}
	set URAM_N_USER ${PARAM_VALUE.URAM_N_USER}
	set CP ${PARAM_VALUE.CP}
	set values(URAM_N_USER) [get_property value $URAM_N_USER]
	set values(CP) [get_property value $CP]
	set_property value [gen_USERPARAMETER_UBANK_BIAS_USER_VALUE $values(URAM_N_USER) $values(CP)] $UBANK_BIAS_USER
}

proc validate_PARAM_VALUE.UBANK_BIAS_USER { PARAM_VALUE.UBANK_BIAS_USER } {
	# Procedure called to validate UBANK_BIAS_USER
	return true
}

proc update_PARAM_VALUE.UBANK_IMG_N { PARAM_VALUE.UBANK_IMG_N PARAM_VALUE.UBANK_IMG_N_USER } {
	# Procedure called to update UBANK_IMG_N when any of the dependent parameters in the arguments change
	
	set UBANK_IMG_N ${PARAM_VALUE.UBANK_IMG_N}
	set UBANK_IMG_N_USER ${PARAM_VALUE.UBANK_IMG_N_USER}
	set values(UBANK_IMG_N_USER) [get_property value $UBANK_IMG_N_USER]
	set_property value [gen_USERPARAMETER_UBANK_IMG_N_VALUE $values(UBANK_IMG_N_USER)] $UBANK_IMG_N
}

proc validate_PARAM_VALUE.UBANK_IMG_N { PARAM_VALUE.UBANK_IMG_N } {
	# Procedure called to validate UBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.UBANK_IMG_N_USER { PARAM_VALUE.UBANK_IMG_N_USER PARAM_VALUE.URAM_N_USER PARAM_VALUE.CP PARAM_VALUE.PP PARAM_VALUE.IBGRP_N } {
	# Procedure called to update UBANK_IMG_N_USER when any of the dependent parameters in the arguments change
	
	set UBANK_IMG_N_USER ${PARAM_VALUE.UBANK_IMG_N_USER}
	set URAM_N_USER ${PARAM_VALUE.URAM_N_USER}
	set CP ${PARAM_VALUE.CP}
	set PP ${PARAM_VALUE.PP}
	set IBGRP_N ${PARAM_VALUE.IBGRP_N}
	set values(URAM_N_USER) [get_property value $URAM_N_USER]
	set values(CP) [get_property value $CP]
	set values(PP) [get_property value $PP]
	set values(IBGRP_N) [get_property value $IBGRP_N]
	set_property value [gen_USERPARAMETER_UBANK_IMG_N_USER_VALUE $values(URAM_N_USER) $values(CP) $values(PP) $values(IBGRP_N)] $UBANK_IMG_N_USER
}

proc validate_PARAM_VALUE.UBANK_IMG_N_USER { PARAM_VALUE.UBANK_IMG_N_USER } {
	# Procedure called to validate UBANK_IMG_N_USER
	return true
}

proc update_PARAM_VALUE.UBANK_WGT_N { PARAM_VALUE.UBANK_WGT_N PARAM_VALUE.UBANK_WGT_N_USER } {
	# Procedure called to update UBANK_WGT_N when any of the dependent parameters in the arguments change
	
	set UBANK_WGT_N ${PARAM_VALUE.UBANK_WGT_N}
	set UBANK_WGT_N_USER ${PARAM_VALUE.UBANK_WGT_N_USER}
	set values(UBANK_WGT_N_USER) [get_property value $UBANK_WGT_N_USER]
	set_property value [gen_USERPARAMETER_UBANK_WGT_N_VALUE $values(UBANK_WGT_N_USER)] $UBANK_WGT_N
}

proc validate_PARAM_VALUE.UBANK_WGT_N { PARAM_VALUE.UBANK_WGT_N } {
	# Procedure called to validate UBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.UBANK_WGT_N_USER { PARAM_VALUE.UBANK_WGT_N_USER PARAM_VALUE.URAM_N_USER PARAM_VALUE.CP } {
	# Procedure called to update UBANK_WGT_N_USER when any of the dependent parameters in the arguments change
	
	set UBANK_WGT_N_USER ${PARAM_VALUE.UBANK_WGT_N_USER}
	set URAM_N_USER ${PARAM_VALUE.URAM_N_USER}
	set CP ${PARAM_VALUE.CP}
	set values(URAM_N_USER) [get_property value $URAM_N_USER]
	set values(CP) [get_property value $CP]
	set_property value [gen_USERPARAMETER_UBANK_WGT_N_USER_VALUE $values(URAM_N_USER) $values(CP)] $UBANK_WGT_N_USER
}

proc validate_PARAM_VALUE.UBANK_WGT_N_USER { PARAM_VALUE.UBANK_WGT_N_USER } {
	# Procedure called to validate UBANK_WGT_N_USER
	return true
}

proc update_PARAM_VALUE.URAM_N { PARAM_VALUE.URAM_N PARAM_VALUE.VER_DPU_NUM PARAM_VALUE.UBANK_IMG_N PARAM_VALUE.UBANK_WGT_N PARAM_VALUE.UBANK_BIAS PARAM_VALUE.CP } {
	# Procedure called to update URAM_N when any of the dependent parameters in the arguments change
	
	set URAM_N ${PARAM_VALUE.URAM_N}
	set VER_DPU_NUM ${PARAM_VALUE.VER_DPU_NUM}
	set UBANK_IMG_N ${PARAM_VALUE.UBANK_IMG_N}
	set UBANK_WGT_N ${PARAM_VALUE.UBANK_WGT_N}
	set UBANK_BIAS ${PARAM_VALUE.UBANK_BIAS}
	set CP ${PARAM_VALUE.CP}
	set values(VER_DPU_NUM) [get_property value $VER_DPU_NUM]
	set values(UBANK_IMG_N) [get_property value $UBANK_IMG_N]
	set values(UBANK_WGT_N) [get_property value $UBANK_WGT_N]
	set values(UBANK_BIAS) [get_property value $UBANK_BIAS]
	set values(CP) [get_property value $CP]
	set_property value [gen_USERPARAMETER_URAM_N_VALUE $values(VER_DPU_NUM) $values(UBANK_IMG_N) $values(UBANK_WGT_N) $values(UBANK_BIAS) $values(CP)] $URAM_N
}

proc validate_PARAM_VALUE.URAM_N { PARAM_VALUE.URAM_N } {
	# Procedure called to validate URAM_N
	return true
}

proc update_PARAM_VALUE.ARCH { PARAM_VALUE.ARCH } {
	# Procedure called to update ARCH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ARCH { PARAM_VALUE.ARCH } {
	# Procedure called to validate ARCH
	return true
}

proc update_PARAM_VALUE.AWRUSER_BW { PARAM_VALUE.AWRUSER_BW } {
	# Procedure called to update AWRUSER_BW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AWRUSER_BW { PARAM_VALUE.AWRUSER_BW } {
	# Procedure called to validate AWRUSER_BW
	return true
}

proc update_PARAM_VALUE.AXI_PROTOCOL { PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to update AXI_PROTOCOL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_PROTOCOL { PARAM_VALUE.AXI_PROTOCOL } {
	# Procedure called to validate AXI_PROTOCOL
	return true
}

proc update_PARAM_VALUE.BANK_BIAS { PARAM_VALUE.BANK_BIAS } {
	# Procedure called to update BANK_BIAS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BANK_BIAS { PARAM_VALUE.BANK_BIAS } {
	# Procedure called to validate BANK_BIAS
	return true
}

proc update_PARAM_VALUE.CONV_DSP_ACCU_ENA { PARAM_VALUE.CONV_DSP_ACCU_ENA } {
	# Procedure called to update CONV_DSP_ACCU_ENA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CONV_DSP_ACCU_ENA { PARAM_VALUE.CONV_DSP_ACCU_ENA } {
	# Procedure called to validate CONV_DSP_ACCU_ENA
	return true
}

proc update_PARAM_VALUE.CONV_DSP_CASC_MAX { PARAM_VALUE.CONV_DSP_CASC_MAX } {
	# Procedure called to update CONV_DSP_CASC_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CONV_DSP_CASC_MAX { PARAM_VALUE.CONV_DSP_CASC_MAX } {
	# Procedure called to validate CONV_DSP_CASC_MAX
	return true
}

proc update_PARAM_VALUE.CONV_RELU_ADDON { PARAM_VALUE.CONV_RELU_ADDON } {
	# Procedure called to update CONV_RELU_ADDON when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CONV_RELU_ADDON { PARAM_VALUE.CONV_RELU_ADDON } {
	# Procedure called to validate CONV_RELU_ADDON
	return true
}

proc update_PARAM_VALUE.DBANK_BIAS { PARAM_VALUE.DBANK_BIAS } {
	# Procedure called to update DBANK_BIAS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DBANK_BIAS { PARAM_VALUE.DBANK_BIAS } {
	# Procedure called to validate DBANK_BIAS
	return true
}

proc update_PARAM_VALUE.DBANK_IMG_N { PARAM_VALUE.DBANK_IMG_N } {
	# Procedure called to update DBANK_IMG_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DBANK_IMG_N { PARAM_VALUE.DBANK_IMG_N } {
	# Procedure called to validate DBANK_IMG_N
	return true
}

proc update_PARAM_VALUE.DBANK_WGT_N { PARAM_VALUE.DBANK_WGT_N } {
	# Procedure called to update DBANK_WGT_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DBANK_WGT_N { PARAM_VALUE.DBANK_WGT_N } {
	# Procedure called to validate DBANK_WGT_N
	return true
}

proc update_PARAM_VALUE.DSP48_VER { PARAM_VALUE.DSP48_VER } {
	# Procedure called to update DSP48_VER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DSP48_VER { PARAM_VALUE.DSP48_VER } {
	# Procedure called to validate DSP48_VER
	return true
}

proc update_PARAM_VALUE.DWCV_ENA { PARAM_VALUE.DWCV_ENA } {
	# Procedure called to update DWCV_ENA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DWCV_ENA { PARAM_VALUE.DWCV_ENA } {
	# Procedure called to validate DWCV_ENA
	return true
}

proc update_PARAM_VALUE.GIT_COMMIT_ID { PARAM_VALUE.GIT_COMMIT_ID } {
	# Procedure called to update GIT_COMMIT_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GIT_COMMIT_ID { PARAM_VALUE.GIT_COMMIT_ID } {
	# Procedure called to validate GIT_COMMIT_ID
	return true
}

proc update_PARAM_VALUE.GP_ID_BW { PARAM_VALUE.GP_ID_BW } {
	# Procedure called to update GP_ID_BW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GP_ID_BW { PARAM_VALUE.GP_ID_BW } {
	# Procedure called to validate GP_ID_BW
	return true
}

proc update_PARAM_VALUE.HP_DATA_BW { PARAM_VALUE.HP_DATA_BW } {
	# Procedure called to update HP_DATA_BW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HP_DATA_BW { PARAM_VALUE.HP_DATA_BW } {
	# Procedure called to validate HP_DATA_BW
	return true
}

proc update_PARAM_VALUE.IBGRP_N { PARAM_VALUE.IBGRP_N } {
	# Procedure called to update IBGRP_N when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IBGRP_N { PARAM_VALUE.IBGRP_N } {
	# Procedure called to validate IBGRP_N
	return true
}

proc update_PARAM_VALUE.LOAD_AUGM_EN { PARAM_VALUE.LOAD_AUGM_EN } {
	# Procedure called to update LOAD_AUGM_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOAD_AUGM_EN { PARAM_VALUE.LOAD_AUGM_EN } {
	# Procedure called to validate LOAD_AUGM_EN
	return true
}

proc update_PARAM_VALUE.LOAD_DSP_NUM { PARAM_VALUE.LOAD_DSP_NUM } {
	# Procedure called to update LOAD_DSP_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOAD_DSP_NUM { PARAM_VALUE.LOAD_DSP_NUM } {
	# Procedure called to validate LOAD_DSP_NUM
	return true
}

proc update_PARAM_VALUE.LOAD_IMG_MEAN_EN { PARAM_VALUE.LOAD_IMG_MEAN_EN } {
	# Procedure called to update LOAD_IMG_MEAN_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOAD_IMG_MEAN_EN { PARAM_VALUE.LOAD_IMG_MEAN_EN } {
	# Procedure called to validate LOAD_IMG_MEAN_EN
	return true
}

proc update_PARAM_VALUE.LOAD_PARALLEL { PARAM_VALUE.LOAD_PARALLEL } {
	# Procedure called to update LOAD_PARALLEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LOAD_PARALLEL { PARAM_VALUE.LOAD_PARALLEL } {
	# Procedure called to validate LOAD_PARALLEL
	return true
}

proc update_PARAM_VALUE.POOL_AVG_EN { PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to update POOL_AVG_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.POOL_AVG_EN { PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to validate POOL_AVG_EN
	return true
}

proc update_PARAM_VALUE.SAVE_PARALLEL { PARAM_VALUE.SAVE_PARALLEL } {
	# Procedure called to update SAVE_PARALLEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SAVE_PARALLEL { PARAM_VALUE.SAVE_PARALLEL } {
	# Procedure called to validate SAVE_PARALLEL
	return true
}

proc update_PARAM_VALUE.SFM_DSP_NUM { PARAM_VALUE.SFM_DSP_NUM } {
	# Procedure called to update SFM_DSP_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SFM_DSP_NUM { PARAM_VALUE.SFM_DSP_NUM } {
	# Procedure called to validate SFM_DSP_NUM
	return true
}

proc update_PARAM_VALUE.SFM_HP_DATA_BW { PARAM_VALUE.SFM_HP_DATA_BW } {
	# Procedure called to update SFM_HP_DATA_BW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SFM_HP_DATA_BW { PARAM_VALUE.SFM_HP_DATA_BW } {
	# Procedure called to validate SFM_HP_DATA_BW
	return true
}

proc update_PARAM_VALUE.S_AXI_CLK_INDEPENDENT { PARAM_VALUE.S_AXI_CLK_INDEPENDENT } {
	# Procedure called to update S_AXI_CLK_INDEPENDENT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_CLK_INDEPENDENT { PARAM_VALUE.S_AXI_CLK_INDEPENDENT } {
	# Procedure called to validate S_AXI_CLK_INDEPENDENT
	return true
}

proc update_PARAM_VALUE.S_AXI_SLAVES_BASE_ADDR { PARAM_VALUE.S_AXI_SLAVES_BASE_ADDR } {
	# Procedure called to update S_AXI_SLAVES_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_SLAVES_BASE_ADDR { PARAM_VALUE.S_AXI_SLAVES_BASE_ADDR } {
	# Procedure called to validate S_AXI_SLAVES_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.TIMESTAMP_ENA { PARAM_VALUE.TIMESTAMP_ENA } {
	# Procedure called to update TIMESTAMP_ENA when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TIMESTAMP_ENA { PARAM_VALUE.TIMESTAMP_ENA } {
	# Procedure called to validate TIMESTAMP_ENA
	return true
}

proc update_PARAM_VALUE.URAM_N_USER { PARAM_VALUE.URAM_N_USER } {
	# Procedure called to update URAM_N_USER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.URAM_N_USER { PARAM_VALUE.URAM_N_USER } {
	# Procedure called to validate URAM_N_USER
	return true
}

proc update_PARAM_VALUE.VER_CHIP_PART { PARAM_VALUE.VER_CHIP_PART } {
	# Procedure called to update VER_CHIP_PART when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_CHIP_PART { PARAM_VALUE.VER_CHIP_PART } {
	# Procedure called to validate VER_CHIP_PART
	return true
}

proc update_PARAM_VALUE.VER_DPU_NUM { PARAM_VALUE.VER_DPU_NUM } {
	# Procedure called to update VER_DPU_NUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_DPU_NUM { PARAM_VALUE.VER_DPU_NUM } {
	# Procedure called to validate VER_DPU_NUM
	return true
}

proc update_PARAM_VALUE.VER_FREQ_MHZ { PARAM_VALUE.VER_FREQ_MHZ } {
	# Procedure called to update VER_FREQ_MHZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_FREQ_MHZ { PARAM_VALUE.VER_FREQ_MHZ } {
	# Procedure called to validate VER_FREQ_MHZ
	return true
}

proc update_PARAM_VALUE.VER_INSTR_VER { PARAM_VALUE.VER_INSTR_VER } {
	# Procedure called to update VER_INSTR_VER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_INSTR_VER { PARAM_VALUE.VER_INSTR_VER } {
	# Procedure called to validate VER_INSTR_VER
	return true
}

proc update_PARAM_VALUE.VER_TIME_DAY { PARAM_VALUE.VER_TIME_DAY } {
	# Procedure called to update VER_TIME_DAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_TIME_DAY { PARAM_VALUE.VER_TIME_DAY } {
	# Procedure called to validate VER_TIME_DAY
	return true
}

proc update_PARAM_VALUE.VER_TIME_HOUR { PARAM_VALUE.VER_TIME_HOUR } {
	# Procedure called to update VER_TIME_HOUR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_TIME_HOUR { PARAM_VALUE.VER_TIME_HOUR } {
	# Procedure called to validate VER_TIME_HOUR
	return true
}

proc update_PARAM_VALUE.VER_TIME_MONTH { PARAM_VALUE.VER_TIME_MONTH } {
	# Procedure called to update VER_TIME_MONTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_TIME_MONTH { PARAM_VALUE.VER_TIME_MONTH } {
	# Procedure called to validate VER_TIME_MONTH
	return true
}

proc update_PARAM_VALUE.VER_TIME_QUARTER { PARAM_VALUE.VER_TIME_QUARTER } {
	# Procedure called to update VER_TIME_QUARTER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_TIME_QUARTER { PARAM_VALUE.VER_TIME_QUARTER } {
	# Procedure called to validate VER_TIME_QUARTER
	return true
}

proc update_PARAM_VALUE.VER_TIME_YEAR { PARAM_VALUE.VER_TIME_YEAR } {
	# Procedure called to update VER_TIME_YEAR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VER_TIME_YEAR { PARAM_VALUE.VER_TIME_YEAR } {
	# Procedure called to validate VER_TIME_YEAR
	return true
}


proc update_MODELPARAM_VALUE.GIT_COMMIT_ID { MODELPARAM_VALUE.GIT_COMMIT_ID PARAM_VALUE.GIT_COMMIT_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GIT_COMMIT_ID}] ${MODELPARAM_VALUE.GIT_COMMIT_ID}
}

proc update_MODELPARAM_VALUE.DSP48_VER { MODELPARAM_VALUE.DSP48_VER PARAM_VALUE.DSP48_VER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DSP48_VER}] ${MODELPARAM_VALUE.DSP48_VER}
}

proc update_MODELPARAM_VALUE.VER_CHIP_PART { MODELPARAM_VALUE.VER_CHIP_PART PARAM_VALUE.VER_CHIP_PART } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_CHIP_PART}] ${MODELPARAM_VALUE.VER_CHIP_PART}
}

proc update_MODELPARAM_VALUE.VER_TIME_YEAR { MODELPARAM_VALUE.VER_TIME_YEAR PARAM_VALUE.VER_TIME_YEAR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_TIME_YEAR}] ${MODELPARAM_VALUE.VER_TIME_YEAR}
}

proc update_MODELPARAM_VALUE.VER_TIME_MONTH { MODELPARAM_VALUE.VER_TIME_MONTH PARAM_VALUE.VER_TIME_MONTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_TIME_MONTH}] ${MODELPARAM_VALUE.VER_TIME_MONTH}
}

proc update_MODELPARAM_VALUE.VER_TIME_DAY { MODELPARAM_VALUE.VER_TIME_DAY PARAM_VALUE.VER_TIME_DAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_TIME_DAY}] ${MODELPARAM_VALUE.VER_TIME_DAY}
}

proc update_MODELPARAM_VALUE.VER_TIME_HOUR { MODELPARAM_VALUE.VER_TIME_HOUR PARAM_VALUE.VER_TIME_HOUR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_TIME_HOUR}] ${MODELPARAM_VALUE.VER_TIME_HOUR}
}

proc update_MODELPARAM_VALUE.VER_TIME_QUARTER { MODELPARAM_VALUE.VER_TIME_QUARTER PARAM_VALUE.VER_TIME_QUARTER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_TIME_QUARTER}] ${MODELPARAM_VALUE.VER_TIME_QUARTER}
}

proc update_MODELPARAM_VALUE.VER_FREQ_MHZ { MODELPARAM_VALUE.VER_FREQ_MHZ PARAM_VALUE.VER_FREQ_MHZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_FREQ_MHZ}] ${MODELPARAM_VALUE.VER_FREQ_MHZ}
}

proc update_MODELPARAM_VALUE.VER_INSTR_VER { MODELPARAM_VALUE.VER_INSTR_VER PARAM_VALUE.VER_INSTR_VER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_INSTR_VER}] ${MODELPARAM_VALUE.VER_INSTR_VER}
}

proc update_MODELPARAM_VALUE.VER_DPU_NUM { MODELPARAM_VALUE.VER_DPU_NUM PARAM_VALUE.VER_DPU_NUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VER_DPU_NUM}] ${MODELPARAM_VALUE.VER_DPU_NUM}
}

proc update_MODELPARAM_VALUE.S_AXI_ID_BW { MODELPARAM_VALUE.S_AXI_ID_BW PARAM_VALUE.S_AXI_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_ID_BW}] ${MODELPARAM_VALUE.S_AXI_ID_BW}
}

proc update_MODELPARAM_VALUE.S_AXI_AWRLEN_BW { MODELPARAM_VALUE.S_AXI_AWRLEN_BW PARAM_VALUE.S_AXI_AWRLEN_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_AWRLEN_BW}] ${MODELPARAM_VALUE.S_AXI_AWRLEN_BW}
}

proc update_MODELPARAM_VALUE.S_AXI_SLAVES_BASE_ADDR { MODELPARAM_VALUE.S_AXI_SLAVES_BASE_ADDR PARAM_VALUE.S_AXI_SLAVES_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_SLAVES_BASE_ADDR}] ${MODELPARAM_VALUE.S_AXI_SLAVES_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.S_AXI_CLK_INDEPENDENT { MODELPARAM_VALUE.S_AXI_CLK_INDEPENDENT PARAM_VALUE.S_AXI_CLK_INDEPENDENT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_CLK_INDEPENDENT}] ${MODELPARAM_VALUE.S_AXI_CLK_INDEPENDENT}
}

proc update_MODELPARAM_VALUE.AWRLEN_BW { MODELPARAM_VALUE.AWRLEN_BW PARAM_VALUE.AWRLEN_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWRLEN_BW}] ${MODELPARAM_VALUE.AWRLEN_BW}
}

proc update_MODELPARAM_VALUE.AWRUSER_BW { MODELPARAM_VALUE.AWRUSER_BW PARAM_VALUE.AWRUSER_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWRUSER_BW}] ${MODELPARAM_VALUE.AWRUSER_BW}
}

proc update_MODELPARAM_VALUE.AWRLOCK_BW { MODELPARAM_VALUE.AWRLOCK_BW PARAM_VALUE.AWRLOCK_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AWRLOCK_BW}] ${MODELPARAM_VALUE.AWRLOCK_BW}
}

proc update_MODELPARAM_VALUE.GP_ID_BW { MODELPARAM_VALUE.GP_ID_BW PARAM_VALUE.GP_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GP_ID_BW}] ${MODELPARAM_VALUE.GP_ID_BW}
}

proc update_MODELPARAM_VALUE.HP0_ID_BW { MODELPARAM_VALUE.HP0_ID_BW PARAM_VALUE.HP0_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HP0_ID_BW}] ${MODELPARAM_VALUE.HP0_ID_BW}
}

proc update_MODELPARAM_VALUE.HP1_ID_BW { MODELPARAM_VALUE.HP1_ID_BW PARAM_VALUE.HP1_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HP1_ID_BW}] ${MODELPARAM_VALUE.HP1_ID_BW}
}

proc update_MODELPARAM_VALUE.HP2_ID_BW { MODELPARAM_VALUE.HP2_ID_BW PARAM_VALUE.HP2_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HP2_ID_BW}] ${MODELPARAM_VALUE.HP2_ID_BW}
}

proc update_MODELPARAM_VALUE.HP3_ID_BW { MODELPARAM_VALUE.HP3_ID_BW PARAM_VALUE.HP3_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HP3_ID_BW}] ${MODELPARAM_VALUE.HP3_ID_BW}
}

proc update_MODELPARAM_VALUE.HP_DATA_BW { MODELPARAM_VALUE.HP_DATA_BW PARAM_VALUE.HP_DATA_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HP_DATA_BW}] ${MODELPARAM_VALUE.HP_DATA_BW}
}

proc update_MODELPARAM_VALUE.PP { MODELPARAM_VALUE.PP PARAM_VALUE.PP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PP}] ${MODELPARAM_VALUE.PP}
}

proc update_MODELPARAM_VALUE.CP { MODELPARAM_VALUE.CP PARAM_VALUE.CP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CP}] ${MODELPARAM_VALUE.CP}
}

proc update_MODELPARAM_VALUE.UBANK_IMG_N { MODELPARAM_VALUE.UBANK_IMG_N PARAM_VALUE.UBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UBANK_IMG_N}] ${MODELPARAM_VALUE.UBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.UBANK_WGT_N { MODELPARAM_VALUE.UBANK_WGT_N PARAM_VALUE.UBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UBANK_WGT_N}] ${MODELPARAM_VALUE.UBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.UBANK_BIAS { MODELPARAM_VALUE.UBANK_BIAS PARAM_VALUE.UBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UBANK_BIAS}] ${MODELPARAM_VALUE.UBANK_BIAS}
}

proc update_MODELPARAM_VALUE.DBANK_IMG_N { MODELPARAM_VALUE.DBANK_IMG_N PARAM_VALUE.DBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DBANK_IMG_N}] ${MODELPARAM_VALUE.DBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.DBANK_WGT_N { MODELPARAM_VALUE.DBANK_WGT_N PARAM_VALUE.DBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DBANK_WGT_N}] ${MODELPARAM_VALUE.DBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.DBANK_BIAS { MODELPARAM_VALUE.DBANK_BIAS PARAM_VALUE.DBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DBANK_BIAS}] ${MODELPARAM_VALUE.DBANK_BIAS}
}

proc update_MODELPARAM_VALUE.IBGRP_N { MODELPARAM_VALUE.IBGRP_N PARAM_VALUE.IBGRP_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IBGRP_N}] ${MODELPARAM_VALUE.IBGRP_N}
}

proc update_MODELPARAM_VALUE.LOAD_PARALLEL { MODELPARAM_VALUE.LOAD_PARALLEL PARAM_VALUE.LOAD_PARALLEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOAD_PARALLEL}] ${MODELPARAM_VALUE.LOAD_PARALLEL}
}

proc update_MODELPARAM_VALUE.LOAD_IMG_MEAN_EN { MODELPARAM_VALUE.LOAD_IMG_MEAN_EN PARAM_VALUE.LOAD_IMG_MEAN_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOAD_IMG_MEAN_EN}] ${MODELPARAM_VALUE.LOAD_IMG_MEAN_EN}
}

proc update_MODELPARAM_VALUE.LOAD_AUGM_EN { MODELPARAM_VALUE.LOAD_AUGM_EN PARAM_VALUE.LOAD_AUGM_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LOAD_AUGM_EN}] ${MODELPARAM_VALUE.LOAD_AUGM_EN}
}

proc update_MODELPARAM_VALUE.CONV_DSP_CASC_MAX { MODELPARAM_VALUE.CONV_DSP_CASC_MAX PARAM_VALUE.CONV_DSP_CASC_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CONV_DSP_CASC_MAX}] ${MODELPARAM_VALUE.CONV_DSP_CASC_MAX}
}

proc update_MODELPARAM_VALUE.CONV_DSP_ACCU_ENA { MODELPARAM_VALUE.CONV_DSP_ACCU_ENA PARAM_VALUE.CONV_DSP_ACCU_ENA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CONV_DSP_ACCU_ENA}] ${MODELPARAM_VALUE.CONV_DSP_ACCU_ENA}
}

proc update_MODELPARAM_VALUE.CONV_RELU_ADDON { MODELPARAM_VALUE.CONV_RELU_ADDON PARAM_VALUE.CONV_RELU_ADDON } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CONV_RELU_ADDON}] ${MODELPARAM_VALUE.CONV_RELU_ADDON}
}

proc update_MODELPARAM_VALUE.DWCV_ENA { MODELPARAM_VALUE.DWCV_ENA PARAM_VALUE.DWCV_ENA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DWCV_ENA}] ${MODELPARAM_VALUE.DWCV_ENA}
}

proc update_MODELPARAM_VALUE.POOL_AVG_EN { MODELPARAM_VALUE.POOL_AVG_EN PARAM_VALUE.POOL_AVG_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_EN}] ${MODELPARAM_VALUE.POOL_AVG_EN}
}

proc update_MODELPARAM_VALUE.POOL_AVG_22 { MODELPARAM_VALUE.POOL_AVG_22 PARAM_VALUE.POOL_AVG_22 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_22}] ${MODELPARAM_VALUE.POOL_AVG_22}
}

proc update_MODELPARAM_VALUE.POOL_AVG_33 { MODELPARAM_VALUE.POOL_AVG_33 PARAM_VALUE.POOL_AVG_33 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_33}] ${MODELPARAM_VALUE.POOL_AVG_33}
}

proc update_MODELPARAM_VALUE.POOL_AVG_44 { MODELPARAM_VALUE.POOL_AVG_44 PARAM_VALUE.POOL_AVG_44 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_44}] ${MODELPARAM_VALUE.POOL_AVG_44}
}

proc update_MODELPARAM_VALUE.POOL_AVG_55 { MODELPARAM_VALUE.POOL_AVG_55 PARAM_VALUE.POOL_AVG_55 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_55}] ${MODELPARAM_VALUE.POOL_AVG_55}
}

proc update_MODELPARAM_VALUE.POOL_AVG_66 { MODELPARAM_VALUE.POOL_AVG_66 PARAM_VALUE.POOL_AVG_66 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_66}] ${MODELPARAM_VALUE.POOL_AVG_66}
}

proc update_MODELPARAM_VALUE.POOL_AVG_77 { MODELPARAM_VALUE.POOL_AVG_77 PARAM_VALUE.POOL_AVG_77 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_77}] ${MODELPARAM_VALUE.POOL_AVG_77}
}

proc update_MODELPARAM_VALUE.POOL_AVG_88 { MODELPARAM_VALUE.POOL_AVG_88 PARAM_VALUE.POOL_AVG_88 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POOL_AVG_88}] ${MODELPARAM_VALUE.POOL_AVG_88}
}

proc update_MODELPARAM_VALUE.SAVE_PARALLEL { MODELPARAM_VALUE.SAVE_PARALLEL PARAM_VALUE.SAVE_PARALLEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SAVE_PARALLEL}] ${MODELPARAM_VALUE.SAVE_PARALLEL}
}

proc update_MODELPARAM_VALUE.DPU1_GP_ID_BW { MODELPARAM_VALUE.DPU1_GP_ID_BW PARAM_VALUE.DPU1_GP_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_GP_ID_BW}] ${MODELPARAM_VALUE.DPU1_GP_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU1_HP0_ID_BW { MODELPARAM_VALUE.DPU1_HP0_ID_BW PARAM_VALUE.DPU1_HP0_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_HP0_ID_BW}] ${MODELPARAM_VALUE.DPU1_HP0_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU1_HP1_ID_BW { MODELPARAM_VALUE.DPU1_HP1_ID_BW PARAM_VALUE.DPU1_HP1_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_HP1_ID_BW}] ${MODELPARAM_VALUE.DPU1_HP1_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU1_HP2_ID_BW { MODELPARAM_VALUE.DPU1_HP2_ID_BW PARAM_VALUE.DPU1_HP2_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_HP2_ID_BW}] ${MODELPARAM_VALUE.DPU1_HP2_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU1_HP3_ID_BW { MODELPARAM_VALUE.DPU1_HP3_ID_BW PARAM_VALUE.DPU1_HP3_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_HP3_ID_BW}] ${MODELPARAM_VALUE.DPU1_HP3_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU1_UBANK_IMG_N { MODELPARAM_VALUE.DPU1_UBANK_IMG_N PARAM_VALUE.DPU1_UBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_UBANK_IMG_N}] ${MODELPARAM_VALUE.DPU1_UBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.DPU1_UBANK_WGT_N { MODELPARAM_VALUE.DPU1_UBANK_WGT_N PARAM_VALUE.DPU1_UBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_UBANK_WGT_N}] ${MODELPARAM_VALUE.DPU1_UBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.DPU1_UBANK_BIAS { MODELPARAM_VALUE.DPU1_UBANK_BIAS PARAM_VALUE.DPU1_UBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_UBANK_BIAS}] ${MODELPARAM_VALUE.DPU1_UBANK_BIAS}
}

proc update_MODELPARAM_VALUE.DPU1_DBANK_IMG_N { MODELPARAM_VALUE.DPU1_DBANK_IMG_N PARAM_VALUE.DPU1_DBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_DBANK_IMG_N}] ${MODELPARAM_VALUE.DPU1_DBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.DPU1_DBANK_WGT_N { MODELPARAM_VALUE.DPU1_DBANK_WGT_N PARAM_VALUE.DPU1_DBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_DBANK_WGT_N}] ${MODELPARAM_VALUE.DPU1_DBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.DPU1_DBANK_BIAS { MODELPARAM_VALUE.DPU1_DBANK_BIAS PARAM_VALUE.DPU1_DBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU1_DBANK_BIAS}] ${MODELPARAM_VALUE.DPU1_DBANK_BIAS}
}

proc update_MODELPARAM_VALUE.DPU2_GP_ID_BW { MODELPARAM_VALUE.DPU2_GP_ID_BW PARAM_VALUE.DPU2_GP_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_GP_ID_BW}] ${MODELPARAM_VALUE.DPU2_GP_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU2_HP0_ID_BW { MODELPARAM_VALUE.DPU2_HP0_ID_BW PARAM_VALUE.DPU2_HP0_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_HP0_ID_BW}] ${MODELPARAM_VALUE.DPU2_HP0_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU2_HP1_ID_BW { MODELPARAM_VALUE.DPU2_HP1_ID_BW PARAM_VALUE.DPU2_HP1_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_HP1_ID_BW}] ${MODELPARAM_VALUE.DPU2_HP1_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU2_HP2_ID_BW { MODELPARAM_VALUE.DPU2_HP2_ID_BW PARAM_VALUE.DPU2_HP2_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_HP2_ID_BW}] ${MODELPARAM_VALUE.DPU2_HP2_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU2_HP3_ID_BW { MODELPARAM_VALUE.DPU2_HP3_ID_BW PARAM_VALUE.DPU2_HP3_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_HP3_ID_BW}] ${MODELPARAM_VALUE.DPU2_HP3_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU2_UBANK_IMG_N { MODELPARAM_VALUE.DPU2_UBANK_IMG_N PARAM_VALUE.DPU2_UBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_UBANK_IMG_N}] ${MODELPARAM_VALUE.DPU2_UBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.DPU2_UBANK_WGT_N { MODELPARAM_VALUE.DPU2_UBANK_WGT_N PARAM_VALUE.DPU2_UBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_UBANK_WGT_N}] ${MODELPARAM_VALUE.DPU2_UBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.DPU2_UBANK_BIAS { MODELPARAM_VALUE.DPU2_UBANK_BIAS PARAM_VALUE.DPU2_UBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_UBANK_BIAS}] ${MODELPARAM_VALUE.DPU2_UBANK_BIAS}
}

proc update_MODELPARAM_VALUE.DPU2_DBANK_IMG_N { MODELPARAM_VALUE.DPU2_DBANK_IMG_N PARAM_VALUE.DPU2_DBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_DBANK_IMG_N}] ${MODELPARAM_VALUE.DPU2_DBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.DPU2_DBANK_WGT_N { MODELPARAM_VALUE.DPU2_DBANK_WGT_N PARAM_VALUE.DPU2_DBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_DBANK_WGT_N}] ${MODELPARAM_VALUE.DPU2_DBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.DPU2_DBANK_BIAS { MODELPARAM_VALUE.DPU2_DBANK_BIAS PARAM_VALUE.DPU2_DBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU2_DBANK_BIAS}] ${MODELPARAM_VALUE.DPU2_DBANK_BIAS}
}

proc update_MODELPARAM_VALUE.DPU3_GP_ID_BW { MODELPARAM_VALUE.DPU3_GP_ID_BW PARAM_VALUE.DPU3_GP_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_GP_ID_BW}] ${MODELPARAM_VALUE.DPU3_GP_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU3_HP0_ID_BW { MODELPARAM_VALUE.DPU3_HP0_ID_BW PARAM_VALUE.DPU3_HP0_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_HP0_ID_BW}] ${MODELPARAM_VALUE.DPU3_HP0_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU3_HP1_ID_BW { MODELPARAM_VALUE.DPU3_HP1_ID_BW PARAM_VALUE.DPU3_HP1_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_HP1_ID_BW}] ${MODELPARAM_VALUE.DPU3_HP1_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU3_HP2_ID_BW { MODELPARAM_VALUE.DPU3_HP2_ID_BW PARAM_VALUE.DPU3_HP2_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_HP2_ID_BW}] ${MODELPARAM_VALUE.DPU3_HP2_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU3_HP3_ID_BW { MODELPARAM_VALUE.DPU3_HP3_ID_BW PARAM_VALUE.DPU3_HP3_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_HP3_ID_BW}] ${MODELPARAM_VALUE.DPU3_HP3_ID_BW}
}

proc update_MODELPARAM_VALUE.DPU3_UBANK_IMG_N { MODELPARAM_VALUE.DPU3_UBANK_IMG_N PARAM_VALUE.DPU3_UBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_UBANK_IMG_N}] ${MODELPARAM_VALUE.DPU3_UBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.DPU3_UBANK_WGT_N { MODELPARAM_VALUE.DPU3_UBANK_WGT_N PARAM_VALUE.DPU3_UBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_UBANK_WGT_N}] ${MODELPARAM_VALUE.DPU3_UBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.DPU3_UBANK_BIAS { MODELPARAM_VALUE.DPU3_UBANK_BIAS PARAM_VALUE.DPU3_UBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_UBANK_BIAS}] ${MODELPARAM_VALUE.DPU3_UBANK_BIAS}
}

proc update_MODELPARAM_VALUE.DPU3_DBANK_IMG_N { MODELPARAM_VALUE.DPU3_DBANK_IMG_N PARAM_VALUE.DPU3_DBANK_IMG_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_DBANK_IMG_N}] ${MODELPARAM_VALUE.DPU3_DBANK_IMG_N}
}

proc update_MODELPARAM_VALUE.DPU3_DBANK_WGT_N { MODELPARAM_VALUE.DPU3_DBANK_WGT_N PARAM_VALUE.DPU3_DBANK_WGT_N } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_DBANK_WGT_N}] ${MODELPARAM_VALUE.DPU3_DBANK_WGT_N}
}

proc update_MODELPARAM_VALUE.DPU3_DBANK_BIAS { MODELPARAM_VALUE.DPU3_DBANK_BIAS PARAM_VALUE.DPU3_DBANK_BIAS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DPU3_DBANK_BIAS}] ${MODELPARAM_VALUE.DPU3_DBANK_BIAS}
}

proc update_MODELPARAM_VALUE.SFM_ENA { MODELPARAM_VALUE.SFM_ENA PARAM_VALUE.SFM_ENA } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SFM_ENA}] ${MODELPARAM_VALUE.SFM_ENA}
}

proc update_MODELPARAM_VALUE.SFM_HP0_ID_BW { MODELPARAM_VALUE.SFM_HP0_ID_BW PARAM_VALUE.SFM_HP0_ID_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SFM_HP0_ID_BW}] ${MODELPARAM_VALUE.SFM_HP0_ID_BW}
}

proc update_MODELPARAM_VALUE.SFM_HP_DATA_BW { MODELPARAM_VALUE.SFM_HP_DATA_BW PARAM_VALUE.SFM_HP_DATA_BW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SFM_HP_DATA_BW}] ${MODELPARAM_VALUE.SFM_HP_DATA_BW}
}

