#scope_export
to_string :: (status: MH_STATUS) -> string {
    return to_string(MH_StatusToString(status));
}

#scope_module
#if OS == .WINDOWS {
    wchar_t :: *u16;
    #load "windows.jai";
}