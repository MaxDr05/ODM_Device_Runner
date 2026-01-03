# ODM Device Runner

**无状态的 Android 测试执行容器 (Stateless Execution Container)**

> 此组件是 [ODM Distributed Test System](https://github.com/MaxDr05/ODM_Infrastructure.git) 的执行单元。

## 1. 核心职责 (Core Responsibilities)
* **ADB 环境隔离**: 每个容器内置独立的 ADB Server，彻底解决物理机上多设备 ADB 冲突的问题。
* **设备守护 (Device Guard)**: 负责设备连接状态的生命周期管理。
* **测试注入**: 动态执行 Monkey 或 UI Automator 测试用例。

## 2. 关键实现 (Implementation Details)

### 2.1 智能预检 (Pre-flight Checks)
为了避免在“设备掉线”或“环境异常”时产生无效测试报告，我们在容器启动阶段 (`entrypoint.sh`) 实现了严格的**防御性编程**：

* **设备状态强校验**: 不仅检查 ADB 连接，还通过 `grep device` 过滤 offline/unauthorized 状态。
* **包名预检**: 运行前检查目标 App (`com.android.calculator2`) 是否存在，不存在则快速失败 (Fast Fail)，节省集群资源。

### 2.2 模拟测试负载
作为架构验证 (PoC)，当前集成了 Android Monkey 作为标准负载，支持通过环境变量 `SERIAL` 区分真机或 Mock 模式。

## 3. 快速使用

```bash
# 单机调试模式
docker run --rm \
  -e SERIAL=你的设备序列号 \
  -v /dev/bus/usb:/dev/bus/usb \
  --privileged \
  odm_device_runner