// Configuration options:

// Increment for any major change
`define HWVERSION 32'd3
// Use external clock as acquisition clocksource
`define USE_EXT_CLK
// Acquisition clockrate: Make sure you account for PLL parameters as well
`define CLOCKRATE 32'd128_000_000 // Hertz
// Sequencer clockrate
`define SEQ_CLOCKRATE 32'd30_000_000 // Hertz

