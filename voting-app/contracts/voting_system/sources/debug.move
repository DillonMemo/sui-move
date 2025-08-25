module voting_system::debug;

use std::debug;
use std::string::String;

public fun create_debug_msg(msg: String) {
    debug::print(&msg)
}

public fun create_debug_obj<T>(obj: &T) {
    debug::print(obj)
}
