#scope_export
memory_init :: () {
    mem_info.initialized = true;

    { // Get Module Information
        mi: MODULEINFO;
        if !GetModuleInformation(GetCurrentProcess(), GetModuleHandleA(null), *mi, size_of(MODULEINFO)) {
            MessageBoxA(null, "GetModuleInformation Failed", "JAIMP", MB_OK | MB_ICONERROR);
            return;
        }
    
        mem_info.base_address = cast(u64)mi.lpBaseOfDll;
        mem_info.module_size = mi.SizeOfImage;   
    }
}

memory_get_info :: () -> Memory_Information {
    return mem_info;
}

memory_find_pattern :: (pattern_u8: *u8, relative: bool = false) -> u64 #no_abc {
    assert(mem_info.initialized == true);

    pattern_str := to_string(pattern_u8);
    pattern, mask := parse_ida_pattern(pattern_str);
    defer array_free(pattern);
    defer array_free(mask);

    is_relative := relative || (pattern_str[0] == #char "E" && pattern_str[1] == #char "8");

    // Start scanning/comparing
    pattern_compare :: (data: *u8, pattern: *u8, mask: *u8) -> bool {
        while mask.* {
            if mask.* == #char "x" && data.* != pattern.* then return false;
            data += 1;
            pattern += 1;
            mask += 1;
        }
        return true;
    }
    
    read_ptr :: (addr: u64, offset: u32) -> s64 #no_abc  {
        rel_offset := (cast(*s32)(addr + offset)).*;
        return (cast(s64)(addr) + rel_offset + size_of(s32)) + cast(s64)offset;
    }

    for 0..mem_info.module_size - 1 {
        if pattern_compare(cast(*u8)(mem_info.base_address + it), pattern.data, mask.data) {
            if is_relative {
                return xx read_ptr(xx(mem_info.base_address + it), 1);
            }
            return mem_info.base_address + it;
        }
    }
    
    return 0;
}

parse_ida_pattern :: (pattern_str: string) -> (pattern: [..]u8, mask: [..]u8) #no_abc {
    pattern: [..]u8;
    mask: [..]u8;

    array_reserve(*pattern, pattern_str.count / 3); // Rough estimate for reserve
    array_reserve(*mask, pattern_str.count / 3);

    i := 0;
    while i < pattern_str.count {
        if pattern_str.data[i] == #char " " {
            i += 1;
            continue;
        }
        
        if pattern_str.data[i] == #char "?" {
            array_add(*pattern, 0);
            array_add(*mask, #char "?");
            if i + 1 < pattern_str.count && pattern_str.data[i + 1] == #char "?" {
                i += 2;
            } else {
                i += 1;
            }
        } else {
            hex := slice(pattern_str, i, 2);
            escaped_char := xx string_to_int(hex, 16);
            array_add(*pattern, xx escaped_char);
            array_add(*mask, #char "x");
            i += 2;
        }
    }

    return pattern, mask;
}

byte_to_hex_char :: (nibble: u8) -> u8 {
    return ifx nibble < 10 then #char "0" + nibble else #char "A" + nibble - 10;
}

bytes_to_str :: (bytes: []u8, skip_first_sep := true, separator := " ") -> string {
    builder: String_Builder;
    init_string_builder(*builder, buffer_size = bytes.count * 3);  // 2 hex digits + space per byte

    for b: bytes {
        if it_index != 0 || !skip_first_sep {
            append(*builder, separator);
        }

        append(*builder, byte_to_hex_char((b >> 4) & 0xF));  // High nibble
        append(*builder, byte_to_hex_char(b & 0xF));         // Low nibble
    }

    return builder_to_string(*builder);
}

// Memory Functions
//-----------------------------------------------------------
memory_protect :: (addr: *void, size: s32, code: Code, protect_type: u32 = PAGE_EXECUTE_READWRITE) -> bool #expand {
    old_protection: u32;
    if !VirtualProtect(addr, xx size, protect_type, *old_protection) then return false;
    #insert code;
    if !VirtualProtect(addr, xx size, old_protection, *old_protection) then return false;
    return true;
}

memory_write :: (addr: *void, value: string) -> bool #expand {
    return memory_protect(addr, xx value.count, #code {
        memcpy(addr, xx value.data, xx value.count);
    });
}

memory_read_bytes :: (addr: *void, count: s32) -> (success: bool, bytes: []u8) {
    result := NewArray(count, u8);
    success := memory_protect(addr, xx count, #code {
        for 0..count-1 {
            result[it] = (cast(*u8)addr)[it];
        }
    }, PAGE_READONLY);
    
    return success, result;
}

memory_print_bytes :: (addr: *void, size: s32, text: string = "") {
    success, bytes := memory_read_bytes(addr, size);
    defer array_free(bytes);
    
    if !success {
        return;
    }

    if text.count != 0 {
        print(text);
    }
    
    str := bytes_to_str(bytes, skip_first_sep=false, separator="\\x");
    defer free(str);
    
    print("%\n", str);
}

memory_scan :: (start: *void, end: *void, instruction_size: s32 = 16) -> (bool, Table(*void, []u8)) {
    address_byte_map: Table(*void, []u8);
    current_addr := start;
    
    while current_addr < end {
        success, bytes := memory_read_bytes(current_addr, instruction_size);
        if success {
            table_add(*address_byte_map, current_addr, bytes);
        } else {
            value, s := get_error_value_and_string();
            log("Failed reading bytes at address(current=0x%, start=0x%, end=0x%): %, %", formatInt(cast(s64)current_addr, 16), formatInt(cast(s64)start, 16), formatInt(cast(s64)end, 16), value, s);
            return false, address_byte_map;
        }
        
        current_addr += instruction_size;
    }
    
    return true, address_byte_map;
}

#scope_export
Memory_Information :: struct {
    base_address: u64;
    module_size:  u32;
    initialized:  bool;
}

#scope_file
mem_info: Memory_Information;