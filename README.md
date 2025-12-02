A perfectly emulated SATA device

It's clear that some anti-cheat systems that only detect device drivers and simple TLP behavior are easily bypassed.

完美模拟的sata设备

很明显，一些只检测设备驱动和简单的tlp行为的反作弊是很好绕过的


It has been tested on the AMD platform, and DMA access remains effective even with VT-D enabled.


目前已经在amd平台测试，即使开启了vt-d ，Dma访问仍然有效

Current Firmware Functionality:

1. TLP Timing Jitter Protection (Preventing "Too Perfect" Responses)

Module: src/pcileech_tlps128_jitter_noise.sv Anti-cheating systems sometimes measure the round-trip time of TLPs. FPGAs typically process at extremely high speeds and with very consistent (deterministic) speeds, unlike real hardware (affected by bus contention and internal processing fluctuations).

- Existing Process: The pcileech_tlps128_jitter_noise module is already instantiated in the code.

- Principle: It uses a linear feedback shift register (LFSR) to generate pseudo-random numbers.

- Effect: It randomly delays the emitted TLP packets by 0 to 3 clock cycles (approximately a 6% probability of triggering jitter). This artificially introduces "noise," simulating the uncertainty of real hardware and preventing anti-cheating systems from identifying the FPGA through precise timing fingerprints.

### 2. Shadow Configuration Space (Hidden FPGA Identity)

Module: src/pcileech_tlps128_cfgspace_shadow.sv The anti-cheating system scans the PCIe configuration space, looking for FPGA characteristics (such as Xilinx's specific Capability ID, serial number rules, etc.).

- Existing Process: Your previously modified shadow module intercepts all configuration read/write requests (CfgRd / CfgWr).

- Principle: It no longer allows the underlying Xilinx PCIe core to respond directly, but instead redirects the response to a BRAM (Block RAM).

- Effect: This means that the host does not see the real Xilinx FPGA, but rather "masked data" that you pre-filled in the BRAM (which can be disguised as a network card, sound card, or any other device). This completely isolates the underlying hardware characteristics.

### 3. Sensitive TLP Filtering

Module: src/pcileech_pcie_tlp_a7.sv (integrates pcileech_tlps128_filter)

- Principle: This module allows enabling alltlp_filter or cfgtlp_filter via software commands.

- Effect: In extreme cases, it can discard specific probe packets, preventing the device from responding to abnormal requests.

现有固件实现的功能 

1. TLP 时序抖动防护 (防止“太完美”的响应)
模块： src/pcileech_tlps128_jitter_noise.sv 反作弊系统有时会测量 TLP 的往返时间。FPGA 通常处理速度极快且非常固定（确定性高），这与真实的硬件（受总线竞争、内部处理波动影响）不同。

- 现有处理： 代码中已经实例化了 pcileech_tlps128_jitter_noise 模块。
- 原理： 它使用一个线性反馈移位寄存器 (LFSR) 生成伪随机数。
- 效果： 它会随机地将发出的 TLP 数据包延迟 0 到 3 个时钟周期（大约 6% 的概率触发抖动）。这人为地引入了“噪声”，模拟真实硬件的不确定性，防止反作弊系统通过精确的时序指纹识别出 FPGA。
### 2. 影子配置空间 (隐藏 FPGA 真实身份)
模块： src/pcileech_tlps128_cfgspace_shadow.sv 反作弊系统会扫描 PCIe 配置空间，寻找 FPGA 的特征（如 Xilinx 的特定 Capability ID、序列号规则等）。

- 现有处理： 您之前修改过的 shadow 模块拦截了所有的配置读写请求（ CfgRd / CfgWr ）。
- 原理： 它不再让底层的 Xilinx PCIe 核直接响应，而是转向一个 BRAM（块存储器）进行响应。
- 效果： 这意味着主机看到的不是真实的 Xilinx FPGA，而是您在 BRAM 中预先填写的“伪装数据”（可以伪装成网卡、声卡等任何设备）。这彻底隔离了底层硬件特征。
### 3. 敏感 TLP 过滤
模块： src/pcileech_pcie_tlp_a7.sv (内部集成 pcileech_tlps128_filter )

- 原理： 该模块允许通过软件指令开启 alltlp_filter 或 cfgtlp_filter 。
- 效果： 在极端情况下，可以丢弃特定的探测包，防止设备对异常请求做出响应

I haven't provided the generated bin file yet.

Because I assume you at least know how to compile this source code (the most basic requirement is Vivado 2023.2).

I haven't set any traps; you can compile it simply by downloading the complete source code.

————————————————————————————————————————

I've only tested Battleye and PAC. Please test other anti-cheat measures yourself (VTD enabled shouldn't cause any problems; at least on my ASUS motherboard, it worked flawlessly).



目前我没有直接提供生成的bin文件

因为我想你至少会编译这个源码（最基本的条件 Vivado 2023.2）

我没有设置任何陷阱，完整下载源码就可以编译
————————————————————————————————————————

我只是测试过battleye  PAC 其他反作弊请自行测试（VTD开启不会有问题，至少我的华硕主板没有任何问题）

If you have any other suggestions or need help, you can find me here: Email: mytk199408@outlook.com
Telegram: @Rainbow199311


如果你有其他建议，或者一些帮助你可以在这里找到我
邮箱: mytk199408@outlook.com
tg : @Rainbow199311
