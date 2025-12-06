/* Loro FFI Bindings */

#ifndef LORO_FFI_H
#define LORO_FFI_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef enum loroLoroStatus {
  Ok = 0,
  Error = 1,
  NullPtr = 2,
} loroLoroStatus;

/**
 * 创建新的Loro文档
 */
loroInnerLoroDoc *loro_doc_new(void);

/**
 * 释放Loro文档资源
 */
void loro_doc_free(loroInnerLoroDoc *doc);

/**
 * 插入文本到文档
 */
enum loroLoroStatus loro_doc_insert_text(loroInnerLoroDoc *doc, const char *text, uintptr_t pos);

/**
 * 删除文档中的文本
 */
enum loroLoroStatus loro_doc_delete_text(loroInnerLoroDoc *doc, uintptr_t start, uintptr_t len);

/**
 * 获取文档文本内容
 */
char *loro_doc_get_text(loroInnerLoroDoc *doc);

/**
 * 提交当前事务
 */
void loro_doc_commit(loroInnerLoroDoc *doc);

/**
 * 导出文档更新
 */
uint8_t *loro_doc_export_all_updates(loroInnerLoroDoc *doc, uintptr_t *out_len);

/**
 * 导入文档更新
 */
enum loroLoroStatus loro_doc_import(loroInnerLoroDoc *doc, const uint8_t *data, uintptr_t len);

/**
 * 设置文档的PeerID
 */
enum loroLoroStatus loro_doc_set_peer_id(loroInnerLoroDoc *doc, uint64_t peer_id);

/**
 * 获取文档的PeerID
 */
uint64_t loro_doc_get_peer_id(loroInnerLoroDoc *doc);

/**
 * 释放C字符串内存
 */
void loro_string_free(char *s);

/**
 * 释放字节数组内存
 */
void loro_bytes_free(uint8_t *ptr);

#endif /* LORO_FFI_H */
