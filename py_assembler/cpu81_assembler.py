import sys

# Check if the correct number of arguments is provided
if(len(sys.argv) != 2):
    print("Usage: python cpu81_assembler.py <filename>")
    sys.exit(1)
# Get the filename from command line arguments
filename = sys.argv[1]
print(f"Processing file: {filename}")

# Read the contents of the file
with open(filename, 'r') as file:
    lines = file.readlines()

# Process each line
out = []
for line in lines:
    line = line.split(";")[0].strip()  # Remove comments and whitespace
    if line:  # Only process non-empty lines
      line_parts = line.split()
      instruction = line_parts[0]
      condition = None
      operands = None
      byteout = 0
      if("." in instruction):
        instruction, condition = instruction.split(".")
        if("z" in condition.lower()):
          byteout |= 0x01
        if("m" in condition.lower()):
          byteout |= 0x02
        if("c" in condition.lower()):
          byteout |= 0x04
        if("i" in condition.lower()):
          byteout |= 0x08
      else:
        operands = line_parts[1:] if len(line_parts) > 1 else []
        if(operands):
          value = int(operands[0], 0)
        else:
          value = 0
        if(value < 0 or value > 15):
          print(f"Operand out of range (0-15): {value}")
          continue
        byteout |= value & 0x0F
      
      match instruction.lower():
        case "tab":byteout |= 0x00
        case "sax":byteout |= 0x10
        case "sta":byteout |= 0x20
        case "lda":byteout |= 0x30
        case "jmp":byteout |= 0x40
        case "pha":byteout |= 0x50
        case "out":byteout |= 0x60
        case "inp":byteout |= 0x70
        case "add":byteout |= 0x80
        case "sub":byteout |= 0x90
        case "inc":byteout |= 0xA0
        case "dec":byteout |= 0xB0
        case "and":byteout |= 0xC0
        case "ora":byteout |= 0xD0
        case "xor":byteout |= 0xE0
        case "not":byteout |= 0xF0
        case _: 
          print(f"Unknown instruction: {instruction}")
          continue
      out.append(byteout)

# Output the assembled bytes in hexadecimal format
with open("a.out", 'wb') as outfile:
    for byte in out:
        outfile.write(bytes([byte]))

# Output the assembled bytes in hexadecimal format
with open("out.mem", 'w') as outfile:
    for byte in out:
        outfile.write(f"{byte:02X}\n")