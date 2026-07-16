# CompileProtobufToCpp

[English](../README.md) | 中文

一个用于在 Windows 上批量编译 Protocol Buffers 文件的简单工具。

工具会自动调用当前机器 `PATH` 中的 `protoc`，递归查找 `proto` 文件夹内的全部 `.proto` 文件，并将生成的 C++ 文件保存到 `Results` 文件夹。

## 目录结构

```text
CompileProtobufCpp/
├─ CompileProto.bat          # 双击运行入口
├─ proto/                    # 存放 .proto 源文件
├─ Results/                  # 存放生成的 .pb.h 和 .pb.cc
└─ Script/
   └─ CompileProto.ps1       # PowerShell 编译脚本
```

如果 `proto` 中包含子目录，生成结果会在 `Results` 中保留对应的子目录结构。

## 环境要求

- Windows 10 或更高版本
- Windows PowerShell 5.1 或 PowerShell 7
- 已安装 Protocol Buffers 编译器 `protoc`
- `protoc.exe` 所在目录已添加到系统或用户的 `PATH`

在命令提示符或 PowerShell 中运行以下命令，可以检查 `protoc` 是否可用：

```powershell
protoc --version
```

脚本直接使用当前机器上检测到的 `protoc`，因此生成文件的版本会与本机编译器版本对应。

## 使用方法

1. 将所有 `.proto` 文件复制到 `proto` 文件夹。依赖的 `.proto` 文件也需要放在该文件夹或其子目录中。
2. 双击根目录中的 `CompileProto.bat`。
3. 查看窗口中的编译结果。
4. 编译完成后按任意键关闭窗口。
5. 在 `Results` 文件夹中获取生成的 `.pb.h` 和 `.pb.cc` 文件。

运行时会显示：

- 当前使用的 `protoc` 版本和路径
- 输入、输出目录
- 每个正在编译的 `.proto` 文件
- 成功和失败的文件数量

单个文件编译失败时，脚本仍会继续尝试编译其他文件，并在最后列出失败文件。

## PowerShell 命令行用法

通常只需运行根目录的批处理文件。如果需要指定其他目录或 `protoc.exe`，可以直接运行 PowerShell 脚本：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Script\CompileProto.ps1
```

指定输入和输出目录：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Script\CompileProto.ps1 `
  -ProtoDir "D:\Protos" `
  -OutputDir "D:\Generated"
```

指定 `protoc.exe`：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Script\CompileProto.ps1 `
  -Protoc "D:\protobuf\bin\protoc.exe"
```

批处理入口也可以透传这些参数：

```bat
CompileProto.bat -Protoc "D:\protobuf\bin\protoc.exe"
```

## 常见问题

### Cannot find protoc

系统找不到 `protoc.exe`。请安装 Protocol Buffers 编译器并将其目录添加到 `PATH`，或者通过 `-Protoc` 指定完整路径。

### Import was not found or had errors

被 `import` 的 `.proto` 文件不存在，或者导入路径与 `proto` 文件夹中的相对路径不一致。请补充依赖文件并检查 `import` 语句。

例如：

```protobuf
import "common/types.proto";
```

对应文件应位于：

```text
proto/common/types.proto
```

### 生成的代码无法链接当前 protobuf 库

生成代码所使用的 `protoc` 版本应与 C++ 项目链接的 protobuf 库版本兼容。建议使用与项目 protobuf 库相同版本的 `protoc` 重新生成代码。

