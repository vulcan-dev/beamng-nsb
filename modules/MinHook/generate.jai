COMPILE :: true;

#run {
    set_build_options_dc(.{do_output=false});
    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
    }
}

compile_minhook :: () -> bool {
    mhook_sources: [..]string;
    // array_add(*mhook_sources, ..enum_files("src", "c", true));
    array_add(*mhook_sources, ..string.[
        "src/buffer.c",
        "src/hook.c",
        "src/trampoline.c",
        "src/hde/hde64.c",
    ]);
    
    // array_add(*mhook_sources, "dll_resources/MinHook.def");

    // If you're doing a static build, replace all instances of "WINAPI" with "__declspec(dllexport)" in MinHook.h

    success := true;
    #if COMPILE {
        #import "BuildCpp";
        if OS == .WINDOWS {
            make_directory_if_it_does_not_exist("windows");
            success &&= build_cpp_static_lib("windows/minhook", ..mhook_sources, extra = .[
                "-Isrc", "-Iinclude"
            ]);
        }
    }

    return success;
}

generate_bindings :: () -> bool {
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        #if COMPILE {
            compile_minhook();
        }

        array_add(*include_paths, "include");
        
        array_add(*libpaths, "windows");
        array_add(*libnames, "minhook");

        array_add(*source_files, "include/MinHook.h");

        array_add(*extra_clang_arguments,
            "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN", "-Isrc"
        );

        if OS == .WINDOWS {
            output_filename = "windows.jai";
        } else {
            make_directory_if_it_does_not_exist("linux_mac");
            output_filename = "linux_mac.jai"; 
        }
    }

    return generate_bindings(opts, output_filename);
}

enum_files :: (path: string, file_extension: string, recursive: bool = false) -> [..]string {
    files: [..] string;
    array_add(*files, file_extension); // Just to get the extension in the visitor easier

    visitor :: (info: *File_Visit_Info, files: *[..] string) {
        extension := path_extension(info.full_name);
        if extension == (files.*)[0] {
            array_add(files, copy_string(info.full_name));
            print("%\n", info.full_name);
        }
    }

    visit_files(path, recursive=recursive, *files, visitor);
    array_ordered_remove_by_index(*files, 0);

    return files;
}

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File_Utilities";
#import "File";
#import "Hash_Table";
#import "String";