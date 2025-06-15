`timescale 1ns / 1ps               //����ʱ�䵥λ�ͷ��澫��

module key_light_control(           //������������˿�
    input       I_clk,              //ϵͳʱ��
    input       I_rst_n,            //��λ�ź�
    input       I_key,              //���������ź�
    output      [6:0] O_led,        //�߶������LED�ź�
    output      [1:0] O_dx          //�߶�����ܶ�ѡ�ź�
    );
    
    wire        W_add_able;         //����ȥ�����ź�
    key_rebounce U_key_rebounce     //���ð���ȥ��ģ��
    (
        .I_clk          (I_clk),           
        .I_rst_n        (I_rst_n),          
        .I_key_in       (I_key),   
        .O_key_out      (W_add_able)
    );
    
    reg [7:0]   R_num;              //��ʾ���ּĴ���
    reg         R_added;            //ȷ��һ�ΰ�����Ӧһ����������
    
    always @(posedge I_clk or negedge I_rst_n)
    begin
        if(!I_rst_n)
        begin//��λ����
            R_num <= 0;
            R_added <= 0;
        end
        else if(W_add_able == 1)
        begin//�����ź�Ϊ�ߵ�ƽ
            if(R_added == 0)
            begin//�˴ΰ���û��ִ���������������������ź���Ϊ1����ͣ������Ϊ
                R_num <= R_num + 1;
                R_added <= 1;
            end
        end
        else
        begin//�����ź�Ϊ�͵�ƽ�����ź���Ϊ0�����Լ�������
            R_added <= 0;
        end
    end

    light_show U_light_show     //�����������ʾģ��
    (
        .I_clk              (I_clk),
        .I_rst_n            (I_rst_n),
        .I_show_num         (R_num),
        .O_led              (O_led),
        .O_dx               (O_dx)
    );

endmodule

