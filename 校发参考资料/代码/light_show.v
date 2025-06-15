`timescale 1ns / 1ps               //����ʱ�䵥λ�ͷ��澫��

module light_show(                  //������������˿�
    input       I_clk,              //ϵͳʱ��
    input       I_rst_n,            //��λ�ź�
    input       [7:0] I_show_num,   //����8-bit����
    output      [6:0] O_led,        //�߶������LED�ź�
    output      [1:0] O_dx          //�߶�����ܶ�ѡ�ź�
    );
    
    parameter   C_COUNTER_NUM = 1000000;    
    //parameter   C_COUNTER_NUM = 10; //��������ֵ
    
    reg  [3:0]  R_temp;             //��ǰ��ʾ��4-bit���ݼĴ���                
    reg  [1:0]  R_dx_temp;          //��ѡ�źżĴ���
    reg  [32:0] R_counter;          //�������Ĵ���
    
    always@(posedge I_clk or negedge I_rst_n)
    begin
        if(!I_rst_n)          
        begin       //��λ����
            R_dx_temp <= 2'b01;
            R_temp <= I_show_num[3:0];
            R_counter <= 0;
        end
        else if(R_dx_temp == 2'b01 && R_counter >= C_COUNTER_NUM)
        begin       //��ʾ��4-bit����
            R_temp <= I_show_num[7:4];
            R_dx_temp <= 2'b10;
            R_counter <= 0;
        end
        else if(R_dx_temp == 2'b10 && R_counter >= C_COUNTER_NUM)
        begin       //��ʾ��4-bit����
            R_temp <= I_show_num[3:0];
            R_dx_temp <= 2'b01;
            R_counter <= 0;
        end
        else
        begin       //����������
            R_counter <= R_counter + 1;
        end
    end
    
    //led���ź�
    assign O_led[0] = (R_temp == 4'b0000||R_temp == 4'b0001||R_temp == 4'b0111
                            ||R_temp == 4'b1100)?0:1;
    assign O_led[1] = (R_temp == 4'b0001||R_temp == 4'b0010||R_temp == 4'b0011
                            ||R_temp == 4'b0111||R_temp == 4'b1101)?0:1;
    assign O_led[2] = (R_temp == 4'b0001||R_temp == 4'b0011||R_temp == 4'b0100
                            ||R_temp == 4'b0101||R_temp == 4'b0111||R_temp == 4'b1001)?0:1;
    assign O_led[3] = (R_temp == 4'b0001||R_temp == 4'b0100||R_temp == 4'b0111
                            ||R_temp == 4'b1010||R_temp == 4'b1111)?0:1;
    assign O_led[4] = (R_temp == 4'b0010||R_temp == 4'b1100||R_temp == 4'b1110
                            ||R_temp == 4'b1111)?0:1;
    assign O_led[5] = (R_temp == 4'b0101||R_temp == 4'b0110||R_temp == 4'b1011
                            ||R_temp == 4'b1100||R_temp == 4'b1110||R_temp == 4'b1111)?0:1;
    assign O_led[6] = (R_temp == 4'b0001||R_temp == 4'b0100||R_temp == 4'b1011
                            ||R_temp == 4'b1101)?0:1;
    //��ѡ�ź�
    assign O_dx = R_dx_temp;   
endmodule
