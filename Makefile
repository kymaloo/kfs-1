
TARGET := i686-elf
CC     := $(TARGET)-gcc
AS     := nasm

BUILD   := build
ISO_DIR := $(BUILD)/isofiles
KERNEL  := $(BUILD)/kernel.elf
ISO     := $(BUILD)/kernel.iso

C_SOURCES := $(shell find src -type f -name '*.c' 2>/dev/null)
ASM_SOURCES := $(shell find boot -type f -name '*.s' 2>/dev/null)

C_OBJECTS := $(patsubst src/%.c,$(BUILD)/src/%.o,$(C_SOURCES))
ASM_OBJECTS := $(patsubst boot/%.s,$(BUILD)/boot/%.o,$(ASM_SOURCES))
OBJECTS := $(ASM_OBJECTS) $(C_OBJECTS)

CFLAGS := -std=gnu11 -ffreestanding -O2 -Wall -Wextra \
          -fno-builtin -fno-exceptions -fno-stack-protector \
          -m32 -march=i686

LDFLAGS := -T linker.ld -nostdlib -nodefaultlibs

.PHONY: all iso run clean check build

all: iso

$(BUILD)/src/%.o: src/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/boot/%.o: boot/%.s
	mkdir -p $(dir $@)
	$(AS) -f elf32 $< -o $@

$(KERNEL): $(OBJECTS) linker.ld
	mkdir -p $(BUILD)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) -lgcc

check: $(KERNEL)
	grub-file --is-x86-multiboot $(KERNEL)

build:
	docker build -t kernel-dev .
	docker run --rm -v "$(CURDIR):/workspace" \
		-w /workspace kernel-dev make

iso: $(KERNEL) check
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL) $(ISO_DIR)/boot/kernel.elf
	cp grub/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(ISO_DIR)

run: iso
	qemu-system-i386 -cdrom $(ISO)

clean:
	rm -rf $(BUILD)