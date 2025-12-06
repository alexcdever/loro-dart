use std::env;
use std::path::PathBuf;

fn main() {
    // 获取输出目录
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let root_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let include_dir = root_dir.join("../..").join("include");
    
    // 创建include目录（如果不存在）
    std::fs::create_dir_all(&include_dir).unwrap();
    
    // 设置cbindgen配置
    let config = cbindgen::Config::from_file("cbindgen.toml").unwrap();
    
    // 生成C头文件
    cbindgen::Builder::new()
        .with_crate(env::var("CARGO_MANIFEST_DIR").unwrap())
        .with_config(config)
        .generate()
        .expect("无法生成绑定")
        .write_to_file(include_dir.join("loro_ffi.h"));
    
    // 通知Cargo在这些文件更改时重新运行
    println!("cargo:rerun-if-changed=src/");
    println!("cargo:rerun-if-changed=cbindgen.toml");
}