// Loro Dart Bridge - 使用 flutter_rust_bridge
// 这个文件定义了暴露给 Dart 的 API

use loro::{
    ExportMode, LoroDoc as LoroDocCore, LoroList as LoroListCore,
    LoroMap as LoroMapCore, LoroText as LoroTextCore,
};
use std::sync::{Arc, Mutex};

/// Loro Document wrapper for Dart
///
/// This is a simplified API designed for Flutter/Dart usage
#[derive(Clone)]
pub struct LoroDoc {
    inner: Arc<Mutex<LoroDocCore>>,
}

impl LoroDoc {
    /// Create a new Loro document
    pub fn new() -> Self {
        Self {
            inner: Arc::new(Mutex::new(LoroDocCore::new())),
        }
    }

    /// Get the peer ID of this document
    pub fn peer_id(&self) -> u64 {
        self.inner.lock().unwrap().peer_id()
    }

    /// Set the peer ID
    pub fn set_peer_id(&self, peer: u64) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .set_peer_id(peer)
            .map_err(|e| e.to_string())
    }

    /// Get a text container by name
    pub fn get_text(&self, name: String) -> LoroText {
        let doc = self.inner.lock().unwrap();
        let text = doc.get_text(name);
        LoroText {
            inner: Arc::new(Mutex::new(text)),
        }
    }

    /// Get a list container by name
    pub fn get_list(&self, name: String) -> LoroList {
        let doc = self.inner.lock().unwrap();
        let list = doc.get_list(name);
        LoroList {
            inner: Arc::new(Mutex::new(list)),
        }
    }

    /// Get a map container by name
    pub fn get_map(&self, name: String) -> LoroMap {
        let doc = self.inner.lock().unwrap();
        let map = doc.get_map(name);
        LoroMap {
            inner: Arc::new(Mutex::new(map)),
        }
    }

    /// Commit current transaction
    pub fn commit(&self) {
        self.inner.lock().unwrap().commit();
    }

    /// Export document as update bytes
    pub fn export(&self) -> Result<Vec<u8>, String> {
        self.inner
            .lock()
            .unwrap()
            .export(ExportMode::Snapshot)
            .map_err(|e| e.to_string())
    }

    /// Export document as snapshot bytes (compatibility method)
    pub fn export_snapshot(&self) -> Result<Vec<u8>, String> {
        self.export()
    }

    /// Import updates from bytes
    pub fn import(&self, bytes: Vec<u8>) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .import(&bytes)
            .map(|_| ())
            .map_err(|e| e.to_string())
    }

    /// Get the JSON representation of the document
    pub fn to_json(&self) -> String {
        let doc = self.inner.lock().unwrap();
        serde_json::to_string(&doc.get_deep_value()).unwrap_or_default()
    }
}

/// Loro Text Container
#[derive(Clone)]
pub struct LoroText {
    inner: Arc<Mutex<LoroTextCore>>,
}

impl LoroText {
    /// Insert text at position
    pub fn insert(&self, pos: u32, text: String) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .insert(pos as usize, &text)
            .map_err(|e| e.to_string())
    }

    /// Delete text at position
    pub fn delete(&self, pos: u32, len: u32) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .delete(pos as usize, len as usize)
            .map_err(|e| e.to_string())
    }

    /// Get the text content as string
    pub fn text(&self) -> String {
        self.inner.lock().unwrap().to_string()
    }

    /// Get the length of the text
    pub fn len(&self) -> u32 {
        self.inner.lock().unwrap().len_unicode() as u32
    }

    /// Check if text is empty
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}

/// Loro List Container
#[derive(Clone)]
pub struct LoroList {
    inner: Arc<Mutex<LoroListCore>>,
}

impl LoroList {
    /// Insert a string value at position
    pub fn insert_string(&self, pos: u32, value: String) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .insert(pos as usize, value)
            .map_err(|e| e.to_string())
    }

    /// Delete item at position
    pub fn delete(&self, pos: u32, len: u32) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .delete(pos as usize, len as usize)
            .map_err(|e| e.to_string())
    }

    /// Get the length of the list
    pub fn len(&self) -> u32 {
        self.inner.lock().unwrap().len() as u32
    }

    /// Check if list is empty
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    /// Get value at index as JSON string
    pub fn get_json(&self, index: u32) -> Option<String> {
        let list = self.inner.lock().unwrap();
        list.get(index as usize).and_then(|v| {
            v.as_value().map(|val| serde_json::to_string(&val).unwrap_or_default())
        })
    }
}

/// Loro Map Container
#[derive(Clone)]
pub struct LoroMap {
    inner: Arc<Mutex<LoroMapCore>>,
}

impl LoroMap {
    /// Insert a string value with key
    pub fn insert_string(&self, key: String, value: String) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .insert(&key, value)
            .map_err(|e| e.to_string())
    }

    /// Delete a key from the map
    pub fn delete(&self, key: String) -> Result<(), String> {
        self.inner
            .lock()
            .unwrap()
            .delete(&key)
            .map_err(|e| e.to_string())
    }

    /// Get the size of the map
    pub fn len(&self) -> u32 {
        self.inner.lock().unwrap().len() as u32
    }

    /// Check if map is empty
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    /// Get value by key as JSON string
    pub fn get_json(&self, key: String) -> Option<String> {
        let map = self.inner.lock().unwrap();
        map.get(&key).and_then(|v| {
            v.as_value().map(|val| serde_json::to_string(&val).unwrap_or_default())
        })
    }

    /// Get all keys
    pub fn keys(&self) -> Vec<String> {
        self.inner
            .lock()
            .unwrap()
            .keys()
            .map(|s| s.to_string())
            .collect()
    }
}

// flutter_rust_bridge 会自动处理这些类型的转换
