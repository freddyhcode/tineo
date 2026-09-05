# Package

version       = "0.1.2"
author        = "freddyhcode"
description   = "A native CLI tool written in Nim for analyzing SQL DDL schema definitions and generating documentation."
license       = "MIT"
srcDir        = "src"
bin           = @["tineo"]


# Dependencies

requires "nim >= 2.2.10"

# Tasks

task release, "Build release":
  exec "nim c --hints:off --out:bin/release/tineo.exe src/tineo.nim"
  
task playground, "Run playground":
  exec "nim c -r --hints:off --out:bin/playground/playground.exe src/playground/playground.nim"