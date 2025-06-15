`timescale 1ns / 1ps               //����ʱ�䵥λ�ͷ��澫��

module key_rebounce(                //������������˿�
    input       I_clk,              //ϵͳʱ��
    input       I_rst_n,            //��λ�ź�
    input       I_key_in,           //���������ź�
    output reg  O_key_out           //����ȥ������ź�
    );
    
    reg R_key_in0;          //��¼�ϸ�ʱ�����ڵİ��������ź�
    reg [19:0] R_count;     //�����Ĵ���
    
    wire W_change;          //��������ı��ź�
    
    //parameter   C_COUNTER_NUM = 5;
    parameter   C_COUNTER_NUM = 180000;
    
    always@(posedge I_clk or negedge I_rst_n)
        if(!I_rst_n)//��λ����
            R_key_in0 <= 0;
        else        //��¼��������
            R_key_in0 <= I_key_in;
    //���ǰ������ʱ�Ӱ����������ݲ�ͬ�������ź���Ϊ1        
    assign W_change=(I_key_in & !R_key_in0)|(!I_key_in & R_key_in0);
    
    always@(posedge I_clk or negedge I_rst_n)
        if(!I_rst_n)    //��λ����
            R_count <= 0;
        else if(W_change)//�������뷢���ı䣬���¿�ʼ����   
            R_count <= 0;
        else 
            R_count <= R_count + 1;
    
    always@(posedge I_clk or negedge I_rst_n)
        if(!I_rst_n)    //��λ����
            O_key_out <= 0;  
        else if(R_count >= C_COUNTER_NUM - 1)//��������ź�
            O_key_out <= I_key_in;

endmodule

