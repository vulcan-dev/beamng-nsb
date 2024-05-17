message_box :: (type: u32, caption: string, format: string, args: ..Any) {
    message := tprint(format, ..args);
    MessageBoxA(null, message.data, caption.data, type);
}

#scope_file
#import "Windows";
#import "Windows_Utf8";