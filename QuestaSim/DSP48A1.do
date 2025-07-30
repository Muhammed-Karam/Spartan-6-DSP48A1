vlib work
vlog DFF.v 
vlog MUX.v 
vlog DSP48A1.v 
vlog DSP48A1_tb.v
vsim -voptargs=+acc work.DSP48A1_tb
add wave *
run -all
#quit -sim