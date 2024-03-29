#
# Makefile for DK-AVR @DrimAES Inc.
#
# Usage :
#	 $ make
#	 $ sudo make upload
#	 $ make clean
#

CC = avr-gcc
AR = avr-ar

MCU:=atmega328
F_CPU:=16000000

AVRDUDE_PROGRAMMER := avrisp2
AVRDUDE_PORT := /dev/ttyUSB0

TARGETNAME = arduino_streaming
SRC = $(TARGETNAME).c

# Flags for the linker and the compiler
COMMON_FLAGS = -DF_CPU=$(F_CPU) -mmcu=$(MCU) $(DOGDEFS)
COMMON_FLAGS += -I$(WORKDIR) -I$(U8GM2DIR)
COMMON_FLAGS += -g -Os -Wall -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
COMMON_FLAGS += -ffunction-sections -fdata-sections -Wl,--gc-sections
COMMON_FLAGS += -Wl,--relax -mcall-prologues
CFLAGS = $(COMMON_FLAGS) -std=gnu99 -Wstrict-prototypes

OBJ = $(SRC:.c=.o)

.SUFFIXES: .elf .hex .dis

.PHONY: all
all: $(TARGETNAME).dis $(TARGETNAME).hex
	avr-size $(TARGETNAME).elf
 
.PHONY: upload
upload: $(TARGETNAME).dis $(TARGETNAME).hex
	sudo avrdude -F -p $(MCU) -P $(AVRDUDE_PORT) -c $(AVRDUDE_PROGRAMMER) -v -v -U flash:w:$(TARGETNAME).hex
	avr-size $(TARGETNAME).elf
 
.PHONY: clean
clean:
	$(RM) $(TARGETNAME).hex $(TARGETNAME).elf $(TARGETNAME).a $(TARGETNAME).dis $(OBJ)
 
# implicit rules
.elf.hex:
	avr-objcopy -O ihex -R .eeprom $< $@
 
# explicit rules
$(TARGETNAME).elf: $(TARGETNAME).a($(OBJ))
	$(LINK.o) $(COMMON_FLAGS) $(TARGETNAME).a $(LOADLIBES) $(LDLIBS) -o $@
 
$(TARGETNAME).dis: $(TARGETNAME).elf
	avr-objdump -S $< > $@

