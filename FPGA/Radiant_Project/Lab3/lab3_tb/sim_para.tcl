lappend auto_path "C:/lscc/radiant/2026.1/scripts/tcl/simulation"
package require simulation_generation
set ::bali::simulation::Para(DEVICEPM) {ice40tp}
set ::bali::simulation::Para(DEVICEFAMILYNAME) {iCE40UP}
set ::bali::simulation::Para(PROJECT) {lab3_tb}
set ::bali::simulation::Para(MDOFILE) {}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/lab3_tb}
set ::bali::simulation::Para(FILELIST) {"C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab1_ta_hex_seg_decoder.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab2_ta_counter.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_scanner.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_sync.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_keypad_decoder.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_keypad_builder.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_digit_sr.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_controller.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_scanner_tb.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_sync_tb.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_digit_sr_tb.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_keypad_builder_tb.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_keypad_decoder_tb.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_savedkey_sr.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_savedkey_sr_tb.sv" "C:/Users/thanderson/Documents/GitHub/E155-Lab3/FPGA/Radiant_Project/Lab3/source/impl_1/lab3_ta_controller_tb.sv" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(LANGSTDLIST) {"System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" "System Verilog" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ice40up}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {lab3_ta_controller_tb}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/radiant/2026.1}
set ::bali::simulation::Para(MEMPATH) {}
set ::bali::simulation::Para(UDOLIST) {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(SIMULATIONTIME)  {0}
set ::bali::simulation::Para(SIMULATIONTIMEUNIT)  {ns}
set ::bali::simulation::Para(SIMULATION_RESOLUTION)  {default}
set ::bali::simulation::Para(NOGUI) {0}
set ::bali::simulation::Para(ISRTL)  {1}
set ::bali::simulation::Para(ISQRUNCLEAN)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(AUTOORDER)  {1}
set ::bali::simulation::Para(PERMISSIVE)  {0}
set ::bali::simulation::Para(OPTIMIZATION_DEBUG)  {1}
::bali::simulation::QuestaSim_Q_Run
