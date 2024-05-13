#scope_export

//------------------------------------------------------------------------
// Types
//------------------------------------------------------------------------
wchar_t :: s16;

VOID    :: void;
LPVOID  :: *void;
LPCVOID :: *void;
LPDWORD :: *DWORD;
DWORD32 :: DWORD;
PCWSTR  :: *u16;
LPTSTR  :: LPSTR;
PCSTR   :: *u8;
PSTR    :: *u8;
PUCHAR  :: *u8;
ULONG   :: u32;
UCHAR   :: u8;
BYTE    :: u8;
INT     :: s32;
ULONGLONG :: u64;
LPWSTR  :: *wchar_t;
PDWORD  :: *DWORD;
DLL_DIRECTORY_COOKIE :: *void;

LPTHREAD_START_ROUTINE :: #type (parameter: LPVOID) -> DWORD #c_call;

//------------------------------------------------------------------------
// Structures
//------------------------------------------------------------------------
MODULEINFO :: struct {
    lpBaseOfDll: LPVOID;
    SizeOfImage: DWORD;
    EntryPoint: LPVOID;
};

IMAGE_SECTION_HEADER :: struct {
  Name: [8]BYTE;
  Misc :: union {
    PhysicalAddress: DWORD;
    VirtualSize: DWORD;
  };
  VirtualAddress: DWORD;
  SizeOfRawData: DWORD;
  PointerToRawData: DWORD;
  PointerToRelocations: DWORD;
  PointerToLinenumbers: DWORD;
  NumberOfRelocations: WORD;
  NumberOfLinenumbers: WORD;
  Characteristics: DWORD;
} PIMAGE_SECTION_HEADER :: *IMAGE_SECTION_HEADER;

IMAGE_DATA_DIRECTORY :: struct {
  VirtualAddress: DWORD;
  Size: DWORD;
} PIMAGE_DATA_DIRECTORY :: *IMAGE_DATA_DIRECTORY;

IMAGE_OPTIONAL_HEADER64 :: struct {
    Magic: WORD;
    MajorLinkerVersion: BYTE;
    MinorLinkerVersion: BYTE;
    SizeOfCode: DWORD;
    SizeOfInitializedData: DWORD;
    SizeOfUninitializedData: DWORD;
    AddressOfEntryPoint: DWORD;
    BaseOfCode: DWORD;
    ImageBase: ULONGLONG;
    SectionAlignment: DWORD;
    FileAlignment: DWORD;
    MajorOperatingSystemVersion: WORD;
    MinorOperatingSystemVersion: WORD;
    MajorImageVersion: WORD;
    MinorImageVersion: WORD;
    MajorSubsystemVersion: WORD;
    MinorSubsystemVersion: WORD;
    Win32VersionValue: DWORD;
    SizeOfImage: DWORD;
    SizeOfHeaders: DWORD;
    CheckSum: DWORD;
    Subsystem: WORD;
    DllCharacteristics: WORD;
    SizeOfStackReserve: ULONGLONG;
    SizeOfStackCommit: ULONGLONG;
    SizeOfHeapReserve: ULONGLONG;
    SizeOfHeapCommit: ULONGLONG;
    LoaderFlags: DWORD;
    NumberOfRvaAndSizes: DWORD;
    DataDirectory: [16]IMAGE_DATA_DIRECTORY;
} PIMAGE_OPTIONAL_HEADER64 :: *IMAGE_OPTIONAL_HEADER64;

IMAGE_FILE_HEADER :: struct {
  Machine: WORD;
  NumberOfSections: WORD;
  TimeDateStamp: DWORD;
  PointerToSymbolTable: DWORD;
  NumberOfSymbols: DWORD;
  SizeOfOptionalHeader: WORD;
  Characteristics: WORD;
} PIMAGE_FILE_HEADER :: *IMAGE_FILE_HEADER;

IMAGE_NT_HEADERS64 :: struct {
    Signature: DWORD;
    FileHeader: IMAGE_FILE_HEADER;
    OptionalHeader: IMAGE_OPTIONAL_HEADER64;
} PIMAGE_NT_HEADERS64 :: *IMAGE_NT_HEADERS64;

LOADED_IMAGE :: struct {
    ModuleName: PSTR;
    hFile: HANDLE;
    MappedAddress: PUCHAR;
    FileHeader: PIMAGE_NT_HEADERS64;
    LastRvaSection: PIMAGE_SECTION_HEADER;
    NumberOfSections: ULONG;
    Sections: PIMAGE_SECTION_HEADER;
    Characteristics: ULONG;
    fSystemImage: BOOLEAN;
    fDOSImage: BOOLEAN;
    fReadOnly: BOOLEAN;
    Version: UCHAR;
    Links: LIST_ENTRY;
    SizeOfImage: ULONG;
} PLOADED_IMAGE :: *LOADED_IMAGE;

SHELLEXECUTEINFOA :: struct {
     cbSize: DWORD;
     fMask: ULONG;
     hwnd: HWND;
     lpVerb: LPCSTR;
     lpFile: LPCSTR;
     lpParameters: LPCSTR;
     lpDirectory: LPCSTR;
     nShow: int;
     hInstApp: HINSTANCE;
     lpIDList: *void;
     lpClass: LPCSTR;
     hkeyClass: HKEY;
     dwHotKey: DWORD;
     DUMMYUNIONNAME :: union {
       hIcon: HANDLE;
       hMonitor: HANDLE;
     };
     hProcess: HANDLE;
} LPSHELLEXECUTEINFOA :: *SHELLEXECUTEINFOA;

//------------------------------------------------------------------------
// Enums
//------------------------------------------------------------------------
TOKEN_INFORMATION_CLASS :: enum int {
    TokenUser :: 1;
    TokenGroups;
    TokenPrivileges;
    TokenOwner;
    TokenPrimaryGroup;
    TokenDefaultDacl;
    TokenSource;
    TokenType;
    TokenImpersonationLevel;
    TokenStatistics;
    TokenRestrictedSids;
    TokenSessionId;
    TokenGroupsAndPrivileges;
    TokenSessionReference;
    TokenSandBoxInert;
    TokenAuditPolicy;
    TokenOrigin;
    TokenElevationType;
    TokenLinkedToken;
    TokenElevation;
    TokenHasRestrictions;
    TokenAccessInformation;
    TokenVirtualizationAllowed;
    TokenVirtualizationEnabled;
    TokenIntegrityLevel;
    TokenUIAccess;
    TokenMandatoryPolicy;
    TokenLogonSid;
    TokenIsAppContainer;
    TokenCapabilities;
    TokenAppContainerSid;
    TokenAppContainerNumber;
    TokenUserClaimAttributes;
    TokenDeviceClaimAttributes;
    TokenRestrictedUserClaimAttributes;
    TokenRestrictedDeviceClaimAttributes;
    TokenDeviceGroups;
    TokenRestrictedDeviceGroups;
    TokenSecurityAttributes;
    TokenIsRestricted;
    TokenProcessTrustLevel;
    TokenPrivateNameSpace;
    TokenSingletonAttributes;
    TokenBnoIsolation;
    TokenChildProcessFlags;
    TokenIsLessPrivilegedAppContainer;
    TokenIsSandboxed;
    TokenIsAppSilo;
    MaxTokenInfoClass;
};

// Maybe I should start automating this.

//------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------
VirtualAllocEx :: (
    hProcess: HANDLE,
    lpAddres: LPVOID,
    dwSize: SIZE_T,
    flAllocationType: DWORD,
    flProtect: DWORD
) -> LPVOID #foreign kernel32;

VirtualFreeEx :: (
    hProcess: HANDLE,
    lpAddress: LPVOID,
    dwSize: SIZE_T,
    dwFreeType: DWORD 
) -> BOOL #foreign kernel32;

CreateRemoteThread :: (
    hProcess: HANDLE,
    lpThreadAttributes: *SECURITY_ATTRIBUTES,
    dwStackSize: SIZE_T,
    lpStartAddress: LPTHREAD_START_ROUTINE,
    lpParameter: LPVOID,
    dwCreationFlags: DWORD,
    lpThreadId: LPDWORD
) -> HANDLE #foreign kernel32;

WriteProcessMemory :: (
    hProcess: HANDLE,
    lpBaseAddress: LPVOID,
    lpBuffer: LPCVOID,
    nSize: SIZE_T,
    lpNumberOfBytesWritten: *SIZE_T
) -> BOOL #foreign kernel32;

SetEnvironmentVariableA :: (
    lpName: LPCSTR,
    lpValue: LPCSTR
) -> BOOL #foreign kernel32;

WriteConsoleA :: (
    hConsoleOutput: HANDLE,
    lpBuffer: *VOID,
    nNumberOfCharsToWrite: DWORD,
    lpNumberOfCharsWritten: LPDWORD,
    lpReserved: LPVOID
) -> BOOL #foreign kernel32;

DisableThreadLibraryCalls :: (
  hLibModule: HMODULE
) -> BOOL #foreign kernel32;

AddDllDirectory :: (
  NewDirectory: PCWSTR
) -> DLL_DIRECTORY_COOKIE #foreign kernel32;

GetModuleInformation :: (
    hProcess: HANDLE,
    hModule: HMODULE,
    lpmodinfo: *MODULEINFO,
    cb: DWORD
) -> BOOL #foreign psapi;

MapAndLoad :: (
    ImageName: PCSTR,
    DllPath: PCSTR,
    LoadedImage: PLOADED_IMAGE,
    DotDll: BOOL,
    ReadOnly: BOOL
) -> bool #foreign imagehlp;

UnMapAndLoad :: (
    LoadedImage: PLOADED_IMAGE
) -> bool #foreign imagehlp;

GetWindowThreadProcessId :: (
    hWnd: HWND,
    lpdwProcessId: LPDWORD
) -> DWORD #foreign user32;

FindWindowExA :: (
    hWndParent: HWND,
    hWndChildAfter: HWND,
    lpszClass: LPCSTR,
    lpszWindow: LPCSTR
) -> HWND #foreign user32;

SetDefaultDllDirectories :: (
    DirectoryFlags: DWORD
) -> BOOL #foreign kernel32;

SetDllDirectoryA :: (
    lpPathName: LPCSTR
) -> BOOL #foreign kernel32;

FreeLibraryAndExitThread :: (hLibModule: HMODULE, dwExitCode: DWORD) -> BOOL #foreign kernel32;

SetConsoleTitleA :: (lpConsoleTitle: *u8) -> BOOL #foreign kernel32;

GetConsoleTitleA :: (
  lpConsoleTitle: LPTSTR,
  nSize: DWORD
) -> DWORD #foreign kernel32;

GetFinalPathNameByHandleA :: (
    hFile: HANDLE,
    lpszFilePath: LPSTR,
    cchFilePath: DWORD,
    dwFlags: DWORD
) -> DWORD #foreign kernel32;

CreateSymbolicLinkA :: (
    lpSymlinkFileName: LPCSTR,
    lpTargetFileName: LPCSTR,
    dwFlags: DWORD
) -> BOOLEAN #foreign kernel32;

ShellExecuteExA :: (
    pExecInfo: *SHELLEXECUTEINFOA
) -> BOOL #foreign shell32;

ShellExecuteA :: (
    hwnd: HWND,
    lpOperation: LPCSTR,
    lpFile: LPCSTR,
    lpParameters: LPCSTR,
    lpDirectory: LPCSTR,
    nShowCmd: INT
) -> HINSTANCE #foreign shell32;

GetTokenInformation :: (
    TokenHandle: HANDLE,
    TokenInformationClass: s32,
    TokenInformation: LPVOID,
    TokenInformationLength: DWORD,
    ReturnLength: PDWORD
) -> BOOL #foreign advapi32;

OpenProcessToken :: (ProcessHandle: *void, DesiredAccess: u32, TokenHandle: **void) -> s32 #foreign kernel32;

GetConsoleWindow :: () -> HWND #foreign kernel32;
AllocConsole :: () -> BOOL #foreign kernel32;
FreeConsole :: () -> BOOL #foreign kernel32;

GetCommandLineA :: () -> LPSTR #foreign kernel32;
GetCommandLineW :: () -> *u16 #foreign kernel32;

CommandLineToArgvW :: (lpCmdLine: *u16, pNumArgs: *s32) -> **u16 #foreign shell32;

// LocalFree :: (mem : *void) -> *void #foreign kernel32;
GetProcessHeap :: () -> *void #foreign kernel32;
HeapAlloc :: (heap : *void, flags : u32, size : u64) -> *void #foreign kernel32;
AttachConsole :: (pid: s32) -> BOOL #foreign kernel32;

#scope_file
advapi32 :: #system_library "Advapi32";
shell32  :: #system_library "Shell32";
kernel32 :: #system_library "kernel32";
user32   :: #system_library "user32";
psapi    :: #system_library "Psapi";
crt      :: #system_library "msvcrt";
imagehlp :: #system_library "Imagehlp";