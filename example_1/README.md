Example No 1
============

This is a simple example aimed at learning basic usage of the Verilog HDL.
(At it's heart, it tries to emulate the classic KITT headlights.)

The circuit is as follows:
- There are 4 RGB LED's. Each LED should run only one color at a time.
- You can choose the color pressing a dedicated button for each color.
- There are two modes of operation: Either flash all LEDs or sequentially turn them on.
	+ You can toggle between this two modes pressing a button.
- You should choose the *direction* of the sequence with a switch.
- You should be able to choose between 4 possible speeds for the sequence.
	+ This can be accomplished using a counter and changing a max-range value with switches
- There should be a global ENABLE switch.
- There should be a global RESET switch, which takes precedence to everything else.


TODO: Add block-diagram of the circuit.
TODO: Refactor code for a more modular approach
TODO: add a waveform file to read with GTKWave
TODO: Maybe add the synthesized schematic or block diagram
TODO: Magic
