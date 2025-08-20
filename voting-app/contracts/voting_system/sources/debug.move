module voting_system::debug;

use std::debug;
use std::string::String;

public struct DebugMsg has copy, drop {
    msg: String,
}

public fun create_debug_msg(msg: String): DebugMsg {
    let debug_msg = DebugMsg { msg };
    debug::print(&debug_msg);
    debug_msg
}

public fun create_debug_obj<T>(obj: &T) {
    debug::print(obj)
}
