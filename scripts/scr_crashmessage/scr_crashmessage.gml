exception_unhandled_handler(function(_exception) {
    // Log the original exception before invoking any UI. Never call a platform SDK here.
    var _report = string(_exception);
    show_debug_message(_report);
    try {
        // The save root always exists, including on a first mobile launch.
        var _file = file_text_open_append(game_save_id + "crash.txt");
        if (_file >= 0) {
            file_text_write_string(_file, date_datetime_string(date_current_datetime()) + "\n" + _report + "\n");
            file_text_close(_file);
        }
    } catch (_logging_error) {
        show_debug_message("Could not save crash log: " + string(_logging_error));
    }
    return 1;
});
