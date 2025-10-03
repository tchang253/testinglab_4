module calc_top (
    input  logic [9:0] SW,
    input  logic [1:0] KEY,
    output logic [9:0] LEDR,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // turning off all the unused HEX displays
  assign HEX4 = 7'b1111111;
  assign HEX2 = 7'b1111111;

  // mirroring the LEDRs to the SW (swtich ON -> LEDR ON)
  assign LEDR = SW;

  // creating the registers to hold values
  logic [3:0] registerA;
  logic [3:0] registerB;

  logic [4:0] sum;  // creating the register to hold the sum (increased the bit width to 5)

  always_ff @(posedge KEY[1]) begin  // loading data into the registers

    if (KEY[0] == 0 && KEY[1] == 0) begin  // when KEY[0] is pressed (1 -> 0)
      registerA <= 4'b0000;  // clearing registers with binary literals
      registerB <= 4'b0000;
    end else begin  // loading the registers with the values
      if (SW[9] == 1) begin
        registerA <= SW[3:0];
      end

      if (SW[8] == 1) begin
        registerB <= SW[3:0];
      end

    end

  end

  assign sum = registerA + registerB;

  // begin creating instances of the included sevenseg.sv file
  // to produce the proper HEX displays

  sevenseg regA (
      .data(registerA),
      .segments(HEX5)
  );
  sevenseg regB (
      .data(registerB),
      .segments(HEX3)
  );

  // need to split the sum into two
  // because the largest number that can be represented with 4 bits is 15
  // the largest value that can be produced here is 1E = 30
  // therefor we need an extra bit to make it 5 bits then max value -> 31
  // display the extra bit value on HEX1 and the lower sum on HEX0
  sevenseg sumCarry (
      .data({3'b000, sum[4]}),
      .segments(HEX1)
  );  // pad the extra carry bit (000x)
  sevenseg sumSum (
      .data(sum[3:0]),
      .segments(HEX0)
  );  // the lower half of the sum

endmodule