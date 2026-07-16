# CompileProtobufToCpp

English | [中文](Doc/README_CN.md)

A simple tool for compiling Protocol Buffers files in batches on Windows.

The tool automatically invokes `protoc` from the current machine's `PATH`, recursively finds all `.proto` files in the `proto` directory, and saves the generated C++ files to the `Results` directory.

## Directory Structure

```text
CompileProtobufCpp/
├─ CompileProto.bat          # Double-click entry point
├─ proto/                    # Source .proto files
├─ Results/                  # Generated .pb.h and .pb.cc files
└─ Script/
   └─ CompileProto.ps1       # PowerShell compilation script
```

If `proto` contains subdirectories, the corresponding directory structure is preserved in `Results`.

## Requirements

- Windows 10 or later
- Windows PowerShell 5.1 or PowerShell 7
- The Protocol Buffers compiler, `protoc`
- The directory containing `protoc.exe` added to the system or user `PATH`

Run the following command in Command Prompt or PowerShell to verify that `protoc` is available:

```powershell
protoc --version
```

The script uses the `protoc` installation detected on the current machine, so the generated files correspond to the installed compiler version.

## Usage

1. Copy all `.proto` files to the `proto` directory. Any dependent `.proto` files must also be placed in this directory or one of its subdirectories.
2. Double-click `CompileProto.bat` in the project root.
3. Review the compilation results in the console window.
4. After compilation finishes, press any key to close the window.
5. Find the generated `.pb.h` and `.pb.cc` files in the `Results` directory.

During execution, the tool displays:

- The version and path of the active `protoc` compiler
- The input and output directories
- Each `.proto` file being compiled
- The number of successful and failed compilations

If an individual file fails to compile, the script continues processing the remaining files and lists all failed files at the end.

## PowerShell Command-Line Usage

Normally, you only need to run the batch file in the project root. To specify different directories or a custom `protoc.exe`, run the PowerShell script directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Script\CompileProto.ps1
```

Specify the input and output directories:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Script\CompileProto.ps1 `
  -ProtoDir "D:\Protos" `
  -OutputDir "D:\Generated"
```

Specify `protoc.exe`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Script\CompileProto.ps1 `
  -Protoc "D:\protobuf\bin\protoc.exe"
```

The batch-file entry point also forwards these arguments:

```bat
CompileProto.bat -Protoc "D:\protobuf\bin\protoc.exe"
```

## Troubleshooting

### Cannot find protoc

The system cannot locate `protoc.exe`. Install the Protocol Buffers compiler and add its directory to `PATH`, or use `-Protoc` to specify its full path.

### Import was not found or had errors

An imported `.proto` file is missing, or its import path does not match its relative path under the `proto` directory. Add the dependency and check the `import` statement.

For example:

```protobuf
import "common/types.proto";
```

The corresponding file must be located at:

```text
proto/common/types.proto
```

### Generated code cannot link against the current protobuf library

The version of `protoc` used to generate the code must be compatible with the protobuf library linked by the C++ project. Regenerate the code using the same `protoc` version as the project's protobuf library.