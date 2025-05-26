//------------------------------------------------------------------------------
// Testbench 名称: tb_top_stopwatch
// 文件名称: tb_top_stopwatch.v
// 功能描述: 用于仿真验证 top_stopwatch 模块。
//------------------------------------------------------------------------------
`timescale 1ns / 1ps // 时间单位/精度

module tb_top_stopwatch;

    // Testbench 内部信号 (reg类型用于产生激励)
    reg tb_sys_clk_pin;
    reg tb_reset_n_pin;
    reg tb_key_a_pin;
    reg tb_key_b_pin;
    reg tb_key_c_pin;

    // 从被测模块 (DUT - Design Under Test) 输出的信号 (wire类型用于观察)
    wire [6:0] tb_seg_pins;
    wire [3:0] tb_an_pins;
    wire       tb_led_minute_pin;
    wire       tb_led_alarm_pin;

    // 实例化被测模块 (DUT)
    top_stopwatch uut (
        .sys_clk_pin    (tb_sys_clk_pin),
        .reset_n_pin    (tb_reset_n_pin),
        .key_a_pin      (tb_key_a_pin),
        .key_b_pin      (tb_key_b_pin),
        .key_c_pin      (tb_key_c_pin),

        .seg_pins       (tb_seg_pins),
        .an_pins        (tb_an_pins),
        .led_minute_pin (tb_led_minute_pin),
        .led_alarm_pin  (tb_led_alarm_pin)
    );

    // 时钟生成 (100MHz -> 周期 10ns)
    localparam CLK_PERIOD = 10; // ns
    always begin
        tb_sys_clk_pin = 1'b0;
        #(CLK_PERIOD / 2);
        tb_sys_clk_pin = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // 仿真激励序列
    initial begin
        // 0. 初始化输入
        tb_reset_n_pin = 1'b1; // 先不复位
        tb_key_a_pin   = 1'b0; // 按键初始状态为未按下 (假设高电平有效)
        tb_key_b_pin   = 1'b0;
        tb_key_c_pin   = 1'b0;
        $display("SIM_INFO: Simulation Started. Initializing inputs.");
        repeat(2) @(posedge tb_sys_clk_pin); // 等待几个时钟周期让信号稳定

        // 1. 系统复位 (低电平有效)
        $display("SIM_INFO: Applying system reset (active low).");
        tb_reset_n_pin = 1'b0;
        repeat(5) @(posedge tb_sys_clk_pin); // 复位持续一段时间
        tb_reset_n_pin = 1'b1; // 释放复位
        $display("SIM_INFO: System reset released. Timer should be in IDLE state (00:00:00).");
        repeat(10) @(posedge tb_sys_clk_pin);

        // 2. 正常启动计时 (按下按键A)
        $display("SIM_INFO: Pressing Key A to start timing.");
        press_key(tb_key_a_pin, 5); // 模拟按键A按下并保持一段时间 (确保消抖检测到)
        $display("SIM_INFO: Key A released. Timer should be RUNNING.");
        // 让时间走一小会儿，比如 250ms (25个10ms tick)
        // (25 * 1_000_000 * 10ns = 250 * 10^6 ns = 250ms)
        #(25 * 1_000_000 * CLK_PERIOD);
        $display("SIM_INFO: After approx 250ms, time should be 0:00:25.");

        // 3. 暂停计时 (按下按键B)
        $display("SIM_INFO: Pressing Key B to pause timing.");
        press_key(tb_key_b_pin, 5);
        $display("SIM_INFO: Key B released. Timer should be PAUSED.");
        // 暂停期间，时间不应该走动
        #(100 * 1_000_000 * CLK_PERIOD); // 暂停100ms
        $display("SIM_INFO: After 100ms pause, time should remain unchanged.");

        // 4. 继续计时 (再次按下按键A)
        $display("SIM_INFO: Pressing Key A to resume timing.");
        press_key(tb_key_a_pin, 5);
        $display("SIM_INFO: Key A released. Timer should be RUNNING again.");
        // 再让时间走一小会儿, 比如 740ms (74个10ms tick) -> 总共 250+740 = 990ms
        #(74 * 1_000_000 * CLK_PERIOD);
        $display("SIM_INFO: After approx 740ms more, time should be 0:00:99.");

        // 5. 测试毫秒进位到秒 (再走20ms -> 总共 1秒10ms)
        $display("SIM_INFO: Advancing time by 20ms to test ms to sec carry.");
        #(2 * 1_000_000 * CLK_PERIOD);
        $display("SIM_INFO: Time should be 0:01:01.");


        // 6. 计时中复位 (按下按键C)
        $display("SIM_INFO: Pressing Key C to reset timer while running.");
        press_key(tb_key_c_pin, 5);
        $display("SIM_INFO: Key C released. Timer should be reset to IDLE (00:00:00).");
        #(50 * 1_000_000 * CLK_PERIOD); // 等待一段时间观察复位效果

        // 7. 测试达到最大计时并报警
        // 为了快速达到最大时间，我们可以暂时修改计时器模块的参数或直接控制FSM
        // 但在标准Testbench中，我们会让它自然走到最大值
        // 最大时间: 1分59秒990毫秒 = (1*60 + 59)*100 + 99 = 119*100 + 99 = 11900 + 99 = 11999 个10ms tick
        // (11999 * 1_000_000 * 10ns = 119.99 seconds)
        $display("SIM_INFO: Starting timer to reach MAX_TIME (1:59:99). This will take a while in simulation.");
        press_key(tb_key_a_pin, 5); // 启动计时
        // (1分59秒990毫秒)
        // min_counter = 1, sec_counter = 59 (0x3B), ms_counter = 99 (0x63)
        // (1*60 + 59)*1000ms + 990ms = 119990ms
        // 需要 11999 个 10ms tick
        #(11998 * 1_000_000 * CLK_PERIOD); // 先走到最大时间前一个tick
        $display("SIM_INFO: Approaching max time...");
        #(1 * 1_000_000 * CLK_PERIOD);   // 最后一个tick，此时应该达到最大时间
        $display("SIM_INFO: Max time should be reached (1:59:99), alarm LED should start blinking.");
        // 观察报警LED是否闪烁
        #(200 * 1_000_000 * CLK_PERIOD); // 观察报警状态200ms
        $display("SIM_INFO: Observing alarm state for 200ms.");

        // 8. 报警状态下按C复位
        $display("SIM_INFO: Pressing Key C to reset from ALARM state.");
        press_key(tb_key_c_pin, 5);
        $display("SIM_INFO: Key C released. Timer should be reset to IDLE, alarm should stop.");
        #(50 * 1_000_000 * CLK_PERIOD);

        // 9. 更多测试场景 (例如，快速连续按键，不同状态下的按键忽略等)
        // ... (可以根据需要添加)

        $display("SIM_INFO: Simulation Finished.");
        $finish; // 结束仿真
    end

    // 辅助任务：模拟按键按下和释放
    // key_signal: 要操作的按键reg变量
    // duration_clk_cycles: 按键按下的持续时钟周期数
    task press_key (inout reg key_signal, input integer duration_clk_cycles);
        begin
            key_signal = 1'b1; // 按下
            repeat(duration_clk_cycles) @(posedge tb_sys_clk_pin);
            key_signal = 1'b0; // 释放
            repeat(2) @(posedge tb_sys_clk_pin); // 按键释放后再等待一下，确保边沿被正确处理
        end
    endtask

endmodule