---------------------------------------------------------------------------
-- The AVR-Ada Library is free software;  you can redistribute it and/or --
-- modify it under terms of the  GNU General Public License as published --
-- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
-- option) any later version.  The AVR-Ada Library is distributed in the --
-- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
-- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
-- PURPOSE. See the GNU General Public License for more details.         --
---------------------------------------------------------------------------
-- ************************************************************************
--   Title:    Walking LEDs using timer interrupt
--   Author:   Peter Fleury <pfleury@gmx.ch> http://jump.to/fleury
--   Date:     December 2003
--   Software: AVR-GCC 3.3
--   Hardware: Tested with AT90S8515 at 4 Mhz and ATmega8 at 1 Mhz
--
--   Description:
--   Demonstrates use of timer/counter interrupts.
--   Turns on one LED on port B which walks from bit 0 to bit 7 in
--   intervals of 0.5 sec
--   Uses AVR Timer/Counter1 interrupt to generate the 0.5 sec delay.
--
--   See also Atmel AVR Application Note AVR130
-- ************************************************************************


with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.MCU;
with AVR.Interrupts;
with AVR.Timer0;

package body Walking_LED is

   --
   --  constant definitions
   --
   XTAL        : constant := 8_000_000;  -- Crystal frequency in Hz
   Timer_Clock : constant :=         2;  -- LED flashing frequency in 1Hz

   Count_Cmp   : constant := XTAL / 1024 / 256 / Timer_Clock - 1;


   --
   -- use volatile if variable is accessed from interrupts and in the
   -- main program.  No volatile if accessed in interrupt only.
   LED : Unsigned_8;

   Count : Unsigned_8;


   procedure Sig_Compare;
   pragma Machine_Attribute (Entity         => SIG_Compare,
                             Attribute_Name => "signal");
   pragma Export (C, Sig_Compare, Timer0.Signal_Compare);


   procedure Sig_Compare is
   begin
      Count := Count + 1;

      if Count > Count_Cmp then
         -- invert the output since a zero means: LED on
         MCU.PORTB := not LED;

         -- move to next LED
         LED := Rotate_Left (LED, 1);

         Count := 0;
      end if;
   end Sig_Compare;


   procedure Main is
   begin
      -- use all pins on PortB for output
      MCU.DDRB_Bits := (others => DD_Output);
      -- and turn off all LEDs
      MCU.PORTB := 16#FF#;

      -- use CLK/1024 prescale value, clear timer/counter on compareA match
      Timer0.Init_CTC (Prescaler => Timer0.Scale_By_1024);

      -- enable Output Compare 1 overflow interrupt
      Timer0.Enable_Interrupt_Compare;

      -- init variable representing the LED state
      LED := 1;

      -- generally enable interrupts
      AVR.Interrupts.Enable;

      -- loop forever
      loop null; end loop;
   end Main;

end Walking_Led;
