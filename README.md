# ODM Device Runner

**无状态的 Android 测试执行容器 (Stateless Execution Container)**

> 此组件是 [ODM Distributed Test System](https://github.com/MaxDr05/ODM_Infrastructure.git) 的执行单元。

## 1. 核心设计决策 (Architecture Decisions)

### 1.1 为什么选择“宿主机 ADB 代理模式”？
在容器化方案选型中，我们评估了两种路径：
* **方案 A（USB 直通）**：将 `/dev/bus/usb` 挂载至容器，每个容器运行独立的 ADB Server。
* **方案 B（远程代理）**：容器复用宿主机的 ADB Server，仅通过 Socket 通信。

经过实际压测，我们发现**方案 A** 在高并发场景下存在严重的 USB 抢占（Race Condition）问题，且对宿主机 Linux 内核版本有强依赖。
因此，本项目最终采用**方案 B**。

**我们定义的“隔离”是指：**
* ✅ **依赖隔离**：Python 环境、测试工具链（Monkey/Appium）、测试数据完全隔离。
* ✅ **进程隔离**：Monkey/Instrumentation 进程在容器内运行，互不干扰。
* ⚠️ **IO 共享**：底层 USB 通信交由宿主机统一调度，换取最高的连接稳定性。

## 2. 关键实现 (Implementation Details)

### 2.1 智能预检 (Pre-flight Checks)
为了避免在“设备掉线”或“环境异常”时产生无效测试报告，我们在容器启动阶段 (`entrypoint.sh`) 实现了严格的**防御性编程**：

* **设备状态强校验**: 不仅检查 ADB 连接，还通过 `grep device` 过滤 offline/unauthorized 状态。
* **包名预检**: 运行前检查目标 App (`com.android.calculator2`) 是否存在，不存在则快速失败 (Fast Fail)，节省集群资源。

### 2.2 模拟测试负载
作为架构验证 (PoC)，当前集成了 Android Monkey 作为标准负载，支持通过环境变量 `SERIAL` 区分真机或 Mock 模式。

## 3. 快速使用

### 3.1 启动容器 (Socket Proxy Mode)
由于采用 ADB 代理模式，无需挂载 USB 设备，但需要注入 ADB Server 的 Socket 地址：

```bash
# 单机调试模式
docker run --rm \
  -e SERIAL=你的设备序列号 \
  -e ADB_SERVER_SOCKET=tcp:host.docker.internal:5037 \
  odm_device_runner