# Copyright (c) 2025 Can Joshua Lehmann

import argparse, os

parser = argparse.ArgumentParser()
parser.add_argument("elf_file", help="Path to the ELF file to load")
parser.add_argument("output_file", help="Path to the output Verilog file")
args = parser.parse_args()

from elftools.elf.elffile import ELFFile
from elftools.elf.constants import P_FLAGS

with open(args.elf_file, "rb") as f:
    elf = ELFFile(f)
    reset_vector = elf.header["e_entry"]
    data_memory = {}
    inst_memory = {}
    for segment in elf.iter_segments():
        mem = data_memory
        if segment["p_flags"] & P_FLAGS.PF_X:
            mem = inst_memory

        addr = segment["p_vaddr"]
        data = segment.data()
        for it in range(segment["p_memsz"]):
            if it < len(data):
                byte = int(data[it])
            else:
                byte = 0
            
            index = addr // 4
            if index not in mem:
                mem[index] = 0
            mem[index] |= byte << ((addr % 4) * 8)

            addr += 1

def init_memory(path, width, data):
    with open(path, "w") as f:
        for index in range(max(data.keys()) + 1):
            value = 0
            if index in data:
                value = data[index]
            f.write(f"{value:0{width // 4}x}\n")

i_ram_preload_path = os.path.abspath(args.output_file.replace(".v", "_i_ram_preload.hex"))
d_ram_preload_path = os.path.abspath(args.output_file.replace(".v", "_d_ram_preload.hex"))

init_memory(i_ram_preload_path, 32, inst_memory)
init_memory(d_ram_preload_path, 32, data_memory)

with open("soc.tmpl.v", "r") as f:
    template = f.read()

code = template
code = code.replace("${reset_vector}", str(reset_vector))
code = code.replace("${i_ram_preload}", i_ram_preload_path)
code = code.replace("${d_ram_preload}", d_ram_preload_path)

with open(args.output_file, "w") as f:
    f.write(code)

