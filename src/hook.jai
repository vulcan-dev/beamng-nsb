#scope_export
Hook :: struct {
    name: string;
    target: *void;
    enabled: bool;
}

hook_create :: (name: string, target: $T, detour: $D, original: *$O, enabled := true) -> bool {
    result := MH_CreateHook(cast(*void)target, cast(*void)detour, cast(**void)original);
    if result != .OK {
        log_error("hook_create failed: %\n", to_string(result));
        return false;
    }

    log("Created hook for % -> 0x%\n", name, formatInt((cast(s64)target), 16));
    table_set(*hooks, name, .{
        target = cast(*void)target,
        name = name,
        enabled = enabled
    });

    if !enabled return true;

    result = MH_EnableHook(cast(*void)target);
    if result != .OK {
        log_error("hook_create failed: %\n", to_string(result));
        return false;
    }

    return true;
}

hook_destroy :: (name: string) -> bool {
    hook := table_find_pointer(*hooks, name);
    if !hook {
        log_error("could not disable hook \"%\", it does not exist!\n", name);
        return false;
    }

    result := MH_RemoveHook(cast(*void)hook.target);
    if result != .OK {
        log_error("hook_destroy failed: %\n", to_string(result));
        return false;
    }

    hook.enabled = false;
    table_remove(*hooks, name);

    log("Destroyed Hook for %\n", name);

    return true;
}

hook_set_enabled :: (name: string, enabled: bool) -> bool {
    hook := table_find_pointer(*hooks, name);
    if !hook {
        log_error("could not disable hook \"%\", it does not exist!\n", name);
        return false;
    }

    if hook.enabled == enabled {
        log_error("hook_set_enabled failed on %, it's already %\n", name, ifx enabled "enabled" else "disabled");
        return false;
    }

    result := ifx enabled MH_EnableHook(cast(*void)hook.target) else MH_DisableHook(cast(*void)hook.target);
    if result != .OK {
        log_error("MH_DisableHook failed: %\n", to_string(result));
        return false;
    }

    print("% Hook for %\n", ifx enabled "Enabled" else "Disabled", name);

    hook.enabled = enabled;
    return true;
}

#scope_file
hooks: Table(string, Hook);

#scope_file
#import "MinHook";
#import "Hash_Table";