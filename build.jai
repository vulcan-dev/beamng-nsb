#scope_file
BUILD_DIR :: "build";
MODULE_DIR :: "modules";
APP_NAME :: "winmm";

build :: () {
    set_build_options_dc(.{do_output=false});
    make_directory_if_it_does_not_exist(BUILD_DIR);

    root_options := get_build_options();
    args := root_options.compile_time_command_line;
    release := array_find(args, "release");

    import_path: [..] string;
    array_add(*import_path, .. root_options.import_path);
    array_add(*import_path, MODULE_DIR);

    {
        w := compiler_create_workspace(APP_NAME);
        
        options := get_build_options(w);
        options.output_executable_name = APP_NAME;
        options.output_path = BUILD_DIR;
        options.import_path = import_path;
        options.output_type = .DYNAMIC_LIBRARY;
        options.additional_linker_arguments = .["/def:winmm.def", "winmm.lib"];
        
        if release {
            log("Release build");
            set_optimization(*options, .OPTIMIZED);
        }
        
        set_build_options(options, w);

        add_build_file("src/entry.jai", w);
        set_build_options_dc(.{do_output=false, write_added_strings=false});
    }
}

#run build();

#scope_file
#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";
#import "Process";
#import "Machine_X64";