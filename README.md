# Windows x86 Buffer Overflow PoC for Beginners

This is a simple, self-contained tutorial on stack-based buffer overflow exploits for 32-bit Windows.
No external guides required—everything you need is here.

## What is this repository?
- `vulnerable.c`: A simple program with an unsafe `gets()` function.
- `messageBox.asm`: A small assembly payload that would execute after the overflow.
- `exploit.c`: An example of how the overflow might be triggered.

This project teaches one core idea: unsafe input reading can let an attacker overwrite the return address and redirect execution.

## The Vulnerability: `gets()` has no size limit

In `vulnerable.c`, the program does this:

```c
char buffer[32];
gets(buffer);
```

The program reserves 32 bytes for `buffer`, then calls `gets()` to read input.
The problem: `gets()` does not check the buffer size.
It keeps reading characters until it encounters a newline.
If the user types 40 or 50 characters, the extra characters overflow past the 32-byte buffer.

## How memory is laid out on the stack

When a C function runs, the stack (a region of memory) stores:

1. Local variables (like `buffer`)
2. The saved `EBP` (base pointer from the calling function)
3. The saved return address (where the CPU should jump when the function returns)

Picture it like this:

```
Lower addresses (top of stack as drawn)
[  buffer (32 bytes)  ]
[    saved EBP (4 bytes)     ]
[  return address (4 bytes)  ]
Higher addresses (bottom)
```

When `gets()` overflows `buffer` with too much input, the extra bytes overwrite the saved `EBP` and then the return address.

If we carefully craft the overflow to place a specific address in the return address field, the CPU will jump to that address when the function tries to return.

## How the exploit works: Step by step

1. The program starts and allocates `buffer[32]` on the stack.
2. It calls `gets(buffer)` to read a line of user input.
3. We send a string that is longer than 32 bytes (say, 50 bytes).
4. `gets()` has no size check, so it writes all 50 bytes into the buffer.
5. The extra 18 bytes overflow past `buffer` and overwrite the saved `EBP` and return address.
6. We carefully construct the overflow so the return address points to shellcode on the stack.
7. When the function returns, the CPU reads the overwritten return address.
8. The CPU jumps to the shellcode.
9. The shellcode runs under the program's permissions.

This is the simplest form of code execution through a buffer overflow.

## What happens in the shellcode: The payload

`messageBox.asm` is a small piece of code designed to run after the overflow.

It does the following:

1. **Load USER32.DLL**: Calls `LoadLibraryA` with the string "USER32.DLL" to ensure the library is in memory.
2. **Prepare arguments for MessageBoxA**: Pushes four arguments onto the stack (window handle, message text, caption, button type).
3. **Call MessageBoxA**: Calls the Windows API function to display a message box with the text "CAN I HACK THE PC?".
4. **Exit cleanly**: Calls `ExitProcess` to safely terminate the program.

The key point: this is executable code that runs after the overflow redirects execution to it.
When the message box appears on screen, it proves three things:
1. The buffer overflow worked and rewrote the return address.
2. Execution jumped to the shellcode on the stack.
3. The shellcode ran successfully and made Windows API calls.

In a real attack, this payload could do anything: steal data, create a user, download malware, etc.
The message box is just a visible, safe way to demonstrate that arbitrary code execution happened.

This specific payload uses hardcoded memory addresses for `MessageBoxA` (0x751D8830) and `ExitProcess` (0x7437ADB0).
These addresses are specific to one system. The payload would need to be adjusted for a different Windows version or system.

## How to build and run the demo

### Step 1: Disable protections
Modern Windows has multiple security features that prevent this exploit:
- **Stack Canaries** (GS flag): detects stack overwrites.
- **ASLR** (DYNAMICBASE): randomizes memory addresses so hardcoded addresses don't work.
- **DEP/NX** (NXCOMPAT): marks the stack as non-executable to prevent code execution there.

For this learning exercise, we disable all of them.

### Step 2: Compile on Windows
Use MSVC (Microsoft Visual C++) with specific flags:

```batch
cl /c /GS- /W3 /Zl vulnerable.c
link /SUBSYSTEM:CONSOLE /DYNAMICBASE:NO /NXCOMPAT:NO vulnerable.obj /OUT:vulnerable.exe
```

Flag meanings:
- `/GS-` disables stack buffer overrun protection.
- `/DYNAMICBASE:NO` disables Address Space Layout Randomization (ASLR).
- `/NXCOMPAT:NO` disables DEP, allowing code on the stack to execute.

If you already have the executable, you can disable protections with `editbin`:

```batch
editbin /NXCOMPAT:NO /DYNAMICBASE:NO vulnerable.exe
```

### Step 3: Run it
1. Start `vulnerable.exe`.
2. When prompted, enter a long string (more than 32 characters).
3. If the overflow works, the saved return address is overwritten.
4. The program may crash, jump to random memory, or (in a real exploit with proper shellcode) execute the payload.

## Why the README is complete

This README explains:
1. What `gets()` is and why it is unsafe (no size limit).
2. How the stack stores local variables, saved registers, and return addresses.
3. How an overflow can overwrite the return address.
4. How the CPU uses the return address when a function returns.
5. How shellcode can execute when the return address points to it.
6. What protections exist and why we disable them.
7. How to build and run the example.

You now understand the entire buffer overflow exploit flow.
Read the code files and compare them to this explanation to solidify your understanding.

## Important safety notice
This example is for learning only.
Do not use this technique against systems you do not own or have explicit permission to test.
Unauthorized access to computer systems is illegal.
