TARGET := i686-elf
CC     := $(TARGET)-gcc
AS     := nasm

BUILD   := build
ISO_DIR := $(BUILD)/isofiles
KERNEL  := $(BUILD)/kernel.elf
ISO     := $(BUILD)/kernel.iso

# Sources C
C_SOURCES := $(shell find src -type f -name '*.c' 2>/dev/null)

# Sources assembleur NASM dans boot/ et src/
ASM_SOURCES := $(shell find boot src -type f \
	\( -name '*.s' -o -name '*.asm' \) 2>/dev/null)

# Objets C
C_OBJECTS := $(patsubst src/%.c,$(BUILD)/src/%.o,$(C_SOURCES))

# Objets assembleur
ASM_OBJECTS := $(patsubst %.s,$(BUILD)/%.o,$(filter %.s,$(ASM_SOURCES))) \
               $(patsubst %.asm,$(BUILD)/%.o,$(filter %.asm,$(ASM_SOURCES)))

OBJECTS := $(ASM_OBJECTS) $(C_OBJECTS)

CFLAGS := -std=gnu11 -ffreestanding -O2 -Wall -Wextra \
          -fno-builtin -fno-exceptions -fno-stack-protector \
          -fno-pic -fno-pie \
          -m32 -march=i686

LDFLAGS := -T linker.ld -nostdlib -nodefaultlibs \
           -m32 -ffreestanding -no-pie

.PHONY: all iso run clean check build

all: iso

# Compilation C
$(BUILD)/src/%.o: src/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -Iinclude -c $< -o $@

# Compilation assembleur NASM (.s)
$(BUILD)/%.o: %.s
	mkdir -p $(dir $@)
	$(AS) -f elf32 $< -o $@

# Compilation assembleur NASM (.asm)
$(BUILD)/%.o: %.asm
	mkdir -p $(dir $@)
	$(AS) -f elf32 $< -o $@

# Édition de liens du noyau
$(KERNEL): $(OBJECTS) linker.ld
	mkdir -p $(BUILD)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) -lgcc

# Vérification Multiboot
check: $(KERNEL)
	grub-file --is-x86-multiboot $(KERNEL)

# Construction avec Docker
build:
	docker build -t kernel-dev .
	docker run --rm -v "$(CURDIR):/workspace" \
		-w /workspace kernel-dev make

# Création de l'ISO
iso: $(KERNEL) check
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL) $(ISO_DIR)/boot/kernel.elf
	cp grub/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(ISO_DIR)

# Lancement dans QEMU
run: iso
	qemu-system-i386 -cdrom $(ISO)

# Nettoyage
clean:
	rm -rf $(BUILD)