//
// This file was auto-generated using the following command:
//
// jai ./generate.jai
//

// MinHook Error Codes.
MH_STATUS :: enum s32 {
    UNKNOWN                    :: -1;

    OK                         :: 0;

    ERROR_ALREADY_INITIALIZED  :: 1;

    ERROR_NOT_INITIALIZED      :: 2;

    ERROR_ALREADY_CREATED      :: 3;

    ERROR_NOT_CREATED          :: 4;

    ERROR_ENABLED              :: 5;

    ERROR_DISABLED             :: 6;

    ERROR_NOT_EXECUTABLE       :: 7;

    ERROR_UNSUPPORTED_FUNCTION :: 8;

    ERROR_MEMORY_ALLOC         :: 9;

    ERROR_MEMORY_PROTECT       :: 10;

    ERROR_MODULE_NOT_FOUND     :: 11;

    ERROR_FUNCTION_NOT_FOUND   :: 12;

    MH_UNKNOWN                    :: UNKNOWN;

    MH_OK                         :: OK;

    MH_ERROR_ALREADY_INITIALIZED  :: ERROR_ALREADY_INITIALIZED;

    MH_ERROR_NOT_INITIALIZED      :: ERROR_NOT_INITIALIZED;

    MH_ERROR_ALREADY_CREATED      :: ERROR_ALREADY_CREATED;

    MH_ERROR_NOT_CREATED          :: ERROR_NOT_CREATED;

    MH_ERROR_ENABLED              :: ERROR_ENABLED;

    MH_ERROR_DISABLED             :: ERROR_DISABLED;

    MH_ERROR_NOT_EXECUTABLE       :: ERROR_NOT_EXECUTABLE;

    MH_ERROR_UNSUPPORTED_FUNCTION :: ERROR_UNSUPPORTED_FUNCTION;

    MH_ERROR_MEMORY_ALLOC         :: ERROR_MEMORY_ALLOC;

    MH_ERROR_MEMORY_PROTECT       :: ERROR_MEMORY_PROTECT;

    MH_ERROR_MODULE_NOT_FOUND     :: ERROR_MODULE_NOT_FOUND;

    MH_ERROR_FUNCTION_NOT_FOUND   :: ERROR_FUNCTION_NOT_FOUND;
}

// Initialize the MinHook library. You must call this function EXACTLY ONCE
// at the beginning of your program.
MH_Initialize :: () -> MH_STATUS #foreign minhook;

// Uninitialize the MinHook library. You must call this function EXACTLY
// ONCE at the end of your program.
MH_Uninitialize :: () -> MH_STATUS #foreign minhook;

// Creates a hook for the specified target function, in disabled state.
// Parameters:
//   pTarget     [in]  A pointer to the target function, which will be
//                     overridden by the detour function.
//   pDetour     [in]  A pointer to the detour function, which will override
//                     the target function.
//   ppOriginal  [out] A pointer to the trampoline function, which will be
//                     used to call the original target function.
//                     This parameter can be NULL.
MH_CreateHook :: (pTarget: *void, pDetour: *void, ppOriginal: **void) -> MH_STATUS #foreign minhook;

// Creates a hook for the specified API function, in disabled state.
// Parameters:
//   pszModule   [in]  A pointer to the loaded module name which contains the
//                     target function.
//   pszProcName [in]  A pointer to the target function name, which will be
//                     overridden by the detour function.
//   pDetour     [in]  A pointer to the detour function, which will override
//                     the target function.
//   ppOriginal  [out] A pointer to the trampoline function, which will be
//                     used to call the original target function.
//                     This parameter can be NULL.
MH_CreateHookApi :: (pszModule: *wchar_t, pszProcName: *u8, pDetour: *void, ppOriginal: **void) -> MH_STATUS #foreign minhook;

// Creates a hook for the specified API function, in disabled state.
// Parameters:
//   pszModule   [in]  A pointer to the loaded module name which contains the
//                     target function.
//   pszProcName [in]  A pointer to the target function name, which will be
//                     overridden by the detour function.
//   pDetour     [in]  A pointer to the detour function, which will override
//                     the target function.
//   ppOriginal  [out] A pointer to the trampoline function, which will be
//                     used to call the original target function.
//                     This parameter can be NULL.
//   ppTarget    [out] A pointer to the target function, which will be used
//                     with other functions.
//                     This parameter can be NULL.
MH_CreateHookApiEx :: (pszModule: *wchar_t, pszProcName: *u8, pDetour: *void, ppOriginal: **void, ppTarget: **void) -> MH_STATUS #foreign minhook;

// Removes an already created hook.
// Parameters:
//   pTarget [in] A pointer to the target function.
MH_RemoveHook :: (pTarget: *void) -> MH_STATUS #foreign minhook;

// Enables an already created hook.
// Parameters:
//   pTarget [in] A pointer to the target function.
//                If this parameter is MH_ALL_HOOKS, all created hooks are
//                enabled in one go.
MH_EnableHook :: (pTarget: *void) -> MH_STATUS #foreign minhook;

// Disables an already created hook.
// Parameters:
//   pTarget [in] A pointer to the target function.
//                If this parameter is MH_ALL_HOOKS, all created hooks are
//                disabled in one go.
MH_DisableHook :: (pTarget: *void) -> MH_STATUS #foreign minhook;

// Queues to enable an already created hook.
// Parameters:
//   pTarget [in] A pointer to the target function.
//                If this parameter is MH_ALL_HOOKS, all created hooks are
//                queued to be enabled.
MH_QueueEnableHook :: (pTarget: *void) -> MH_STATUS #foreign minhook;

// Queues to disable an already created hook.
// Parameters:
//   pTarget [in] A pointer to the target function.
//                If this parameter is MH_ALL_HOOKS, all created hooks are
//                queued to be disabled.
MH_QueueDisableHook :: (pTarget: *void) -> MH_STATUS #foreign minhook;

// Applies all queued changes in one go.
MH_ApplyQueued :: () -> MH_STATUS #foreign minhook;

// Translates the MH_STATUS to its name as a string.
MH_StatusToString :: (status: MH_STATUS) -> *u8 #foreign minhook;

#scope_file

#import "Basic"; // For assert

minhook :: #library,no_dll "windows/minhook";
