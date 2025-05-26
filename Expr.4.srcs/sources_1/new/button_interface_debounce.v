//------------------------------------------------------------------------------
// 模块名称: button_interface_debounce
// 文件名称: button_interface_debounce.v
// 功能描述: 对按键输入进行消抖处理，并产生单周期脉冲信号。
//           按键按下（输入高电平）时，输出一个时钟周期的有效脉冲。
//------------------------------------------------------------------------------
module button_interface_debounce (
    input  wire clk,             // 系统时钟 (100MHz)
    input  wire reset_n,         // 异步复位信号 (低电平有效)
    input  wire key_raw_in,      // 原始按键输入 (高电平有效)
    output reg  key_pulse_out    // 消抖后的单周期按键脉冲 (高电平有效)
);

    // 参数定义
    parameter DEBOUNCE_TIME_MS = 10; // 消抖时间，单位ms
    // 100MHz时钟下，10ms 对应的计数值: DEBOUNCE_TIME_MS * 100_000
    localparam DEBOUNCE_COUNT_MAX = DEBOUNCE_TIME_MS * 100_000 -1; // 计数器从0数到MAX

    // 内部信号定义
    reg [19:0] debounce_counter;   // 消抖计数器 (最大支持约10.4ms @100MHz if DEBOUNCE_TIME_MS=10)
                                   // 20位计数器: 2^20 approx 1M. 10ms => 1M counts. OK.
    reg key_state_q0;          // 按键状态寄存器0 (用于同步和边沿检测)
    reg key_state_q1;          // 按键状态寄存器1 (稳定后的按键状态)
    reg key_state_q2;          // 按键状态寄存器2 (用于产生脉冲)

    // 主逻辑
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            debounce_counter <= 20'd0;
            key_state_q0     <= 1'b0; // 假设按键未按下时为低电平
            key_state_q1     <= 1'b0;
            key_state_q2     <= 1'b0;
            key_pulse_out    <= 1'b0;
        end else begin
            // 第一级同步，并检测原始输入变化
            key_state_q0 <= key_raw_in;

            if (key_state_q0 != key_raw_in) begin // 如果原始输入有变化，或者和第一级同步器不同（通常是 key_raw_in 变化了）
                debounce_counter <= 20'd0; // 复位消抖计数器
            end else if (debounce_counter < DEBOUNCE_COUNT_MAX) begin
                debounce_counter <= debounce_counter + 1'b1; // 稳定则计数
            end else begin // 计数器达到最大值，认为状态稳定
                key_state_q1 <= key_raw_in; // 更新稳定后的按键状态
            end

            // 使用稳定后的状态产生单周期脉冲
            // key_state_q1 是当前稳定状态，key_state_q2 是上一拍的稳定状态
            key_state_q2  <= key_state_q1;
            if (key_state_q1 == 1'b1 && key_state_q2 == 1'b0) begin // 检测到上升沿 (按键按下)
                key_pulse_out <= 1'b1;
            end else begin
                key_pulse_out <= 1'b0;
            end
        end
    end

endmodule