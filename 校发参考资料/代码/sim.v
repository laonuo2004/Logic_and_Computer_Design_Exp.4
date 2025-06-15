`timescale 1ns / 1ps

module sim();
    reg clk, rst_n, key;    //ģ�������ź�����Ϊreg��
    
    wire [6:0] led;         //ģ������ź�����Ϊwire��
    wire [1:0] dx;
    
    parameter period = 20;  //һʱ������ʱ��
    //������Ҫ���з����ģ��
    key_light_control U_key_light_control
    (
        .I_clk              (clk),
        .I_rst_n            (rst_n),
        .I_key              (key),
        .O_led              (led),
        .O_dx               (dx)
    );
    //ģ��ʱ���ź�
    always begin
        clk = 1'b0;
        #(period/2); //��ʱ���period
        clk = 1'b1;
        #(period/2);
    end
    
    always begin
        rst_n = 1'b0;
        key = 1'b0;
        #(period/2);
        
        //����ȥ������
        rst_n = 1'b1;
        key = 1'b1;
        #(4*period);
        key = 1'b0;
        #period;
        
        //�������Ʋ���
        key = 1'b1;
        #(50*period);
        key = 1'b0;
        #(50*period);
        key = 1'b1;
        #(50*period);
        key = 1'b0;
        #(1000*period);
    end

endmodule
