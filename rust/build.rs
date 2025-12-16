// flutter_rust_bridge 的构建配置会自动处理
fn main() {
    // flutter_rust_bridge 将自动生成必要的代码
    println!("cargo:rerun-if-changed=src/api.rs");
}
