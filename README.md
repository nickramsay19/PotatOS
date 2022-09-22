# PotatOS | A simple CLI Operating System
> Developed by Nicholas Ramsay

## Usage
### Build and run using QEMU
```
make
qemu-system-i386 bin/potatos.bin
```

### Build an ISO Image
```
make iso
```

### Running in QEMU Emulator
#### From binary
```
qemu-system-i386 bin/potatos.bin
```
#### From ISO
```
qemu-system-i386 -cdrom dist/potatos.iso
```