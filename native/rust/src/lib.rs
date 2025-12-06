use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::ptr::null_mut;
use loro::LoroDoc as InnerLoroDoc;
use loro::LoroResult;
use loro::{ExportMode, ImportStatus};

// FFI返回状态码
#[repr(C)]
pub enum LoroStatus {
    Ok = 0,
    Error = 1,
    NullPtr = 2,
}

// FFI接口

/// 创建新的Loro文档
#[no_mangle]
pub extern "C" fn loro_doc_new() -> *mut InnerLoroDoc {
    let doc = InnerLoroDoc::new();
    Box::into_raw(Box::new(doc))
}

/// 释放Loro文档资源
#[no_mangle]
pub extern "C" fn loro_doc_free(doc: *mut InnerLoroDoc) {
    if !doc.is_null() {
        unsafe {
            let _ = Box::from_raw(doc);
        }
    }
}

/// 插入文本到文档
#[no_mangle]
pub extern "C" fn loro_doc_insert_text(
    doc: *mut InnerLoroDoc, 
    text: *const c_char,
    pos: usize
) -> LoroStatus {
    if doc.is_null() || text.is_null() {
        return LoroStatus::NullPtr;
    }
    
    unsafe {
        let c_str = CStr::from_ptr(text);
        match c_str.to_str() {
            Ok(text_str) => {
                let doc_ref = &mut *doc;
                let text_handler = doc_ref.get_text("text");
                match text_handler.insert(pos, text_str) {
                    Ok(_) => LoroStatus::Ok,
                    Err(_) => LoroStatus::Error,
                }
            }
            Err(_) => LoroStatus::Error,
        }
    }
}

/// 删除文档中的文本
#[no_mangle]
pub extern "C" fn loro_doc_delete_text(
    doc: *mut InnerLoroDoc, 
    start: usize,
    len: usize
) -> LoroStatus {
    if doc.is_null() {
        return LoroStatus::NullPtr;
    }
    
    unsafe {
        let doc_ref = &mut *doc;
        let text_handler = doc_ref.get_text("text");
        match text_handler.delete(start, len) {
            Ok(_) => LoroStatus::Ok,
            Err(_) => LoroStatus::Error,
        }
    }
}

/// 获取文档文本内容
#[no_mangle]
pub extern "C" fn loro_doc_get_text(doc: *mut InnerLoroDoc) -> *mut c_char {
    if doc.is_null() {
        return null_mut();
    }
    
    unsafe {
        let doc_ref = &*doc;
        let text_handler = doc_ref.get_text("text");
        let text = text_handler.to_string();
        match CString::new(text) {
            Ok(c_string) => c_string.into_raw(),
            Err(_) => null_mut(),
        }
    }
}

/// 提交当前事务
#[no_mangle]
pub extern "C" fn loro_doc_commit(doc: *mut InnerLoroDoc) {
    if !doc.is_null() {
        unsafe {
            let doc_ref = &*doc;
            doc_ref.commit();
        }
    }
}

/// 导出文档更新
#[no_mangle]
pub extern "C" fn loro_doc_export_all_updates(
    doc: *mut InnerLoroDoc,
    out_len: *mut usize
) -> *mut u8 {
    if doc.is_null() || out_len.is_null() {
        return null_mut();
    }
    
    unsafe {
        let doc_ref = &*doc;
        match doc_ref.export(ExportMode::all_updates()) {
            Ok(updates) => {
                let len = updates.len();
                *out_len = len;
                let mut ptr = libc::malloc(len) as *mut u8;
                if ptr.is_null() {
                    return null_mut();
                }
                std::ptr::copy_nonoverlapping(updates.as_ptr(), ptr, len);
                ptr
            }
            Err(_) => null_mut(),
        }
    }
}

/// 导入文档更新
#[no_mangle]
pub extern "C" fn loro_doc_import(
    doc: *mut InnerLoroDoc,
    data: *const u8,
    len: usize
) -> LoroStatus {
    if doc.is_null() || data.is_null() {
        return LoroStatus::NullPtr;
    }
    
    unsafe {
        let doc_ref = &*doc;
        let data_slice = std::slice::from_raw_parts(data, len);
        match doc_ref.import(data_slice) {
            Ok(_) => LoroStatus::Ok,
            Err(_) => LoroStatus::Error,
        }
    }
}

/// 设置文档的PeerID
#[no_mangle]
pub extern "C" fn loro_doc_set_peer_id(
    doc: *mut InnerLoroDoc,
    peer_id: u64
) -> LoroStatus {
    if doc.is_null() {
        return LoroStatus::NullPtr;
    }
    
    unsafe {
        let doc_ref = &*doc;
        match doc_ref.set_peer_id(peer_id) {
            Ok(_) => LoroStatus::Ok,
            Err(_) => LoroStatus::Error,
        }
    }
}

/// 获取文档的PeerID
#[no_mangle]
pub extern "C" fn loro_doc_get_peer_id(doc: *mut InnerLoroDoc) -> u64 {
    if doc.is_null() {
        return 0;
    }
    
    unsafe {
        let doc_ref = &*doc;
        doc_ref.peer_id()
    }
}

/// 释放C字符串内存
#[no_mangle]
pub extern "C" fn loro_string_free(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

/// 释放字节数组内存
#[no_mangle]
pub extern "C" fn loro_bytes_free(ptr: *mut u8) {
    if !ptr.is_null() {
        unsafe {
            libc::free(ptr as *mut libc::c_void);
        }
    }
}