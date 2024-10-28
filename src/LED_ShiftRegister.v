module LED_ShiftRegister(
    input RSTn,//active HIGH reset
    input clk,//27 MHz clock
    
    input SW1,//active HIGH Reset
    output [1:6]leds);
reg [1:6]shiftreg;
reg buttonPressed;
reg [1:0] synch;
reg delay_switch;
integer deboucePeriod =50000000;
integer counter;
reg debouncedSW;
//synchroniszer block for asychronous input
always@(posedge clk or posedge RSTn)begin
    if(RSTn==1'b1)
        synch<=2'b00;
    else begin
        synch[0]<=SW1;  
        synch[1]<=synch[0]; 
    end
end
//button detection procedure
always@(posedge clk or posedge RSTn)begin
    if(RSTn==1'b1)begin
        buttonPressed<=1'b0;
        delay_switch<=1'b0;
    end else begin
        delay_switch<=synch[1];
        if (synch[1] ==1'b1 && delay_switch==1'b0 ) begin
            buttonPressed<=1'b1;  
        end else
            buttonPressed<=1'b0; 
    end
end
//debounce input button procedure  
always@(posedge clk or posedge RSTn)begin
    if(RSTn==1'b1)begin
        counter<=0;
        debouncedSW<=1'b0;

    end else begin
        if (synch[1] ==1'b1) begin
            if (counter >0) 
                counter<=counter-1;
        end else begin
            
            if (counter <deboucePeriod) 
                counter<=counter+1;
        end
        if(counter==deboucePeriod) 
            debouncedSW<=1'b1;
        else if (counter ==0)
            debouncedSW<=1'b0;
    end
end
//shifting procedure
always@(posedge clk or posedge RSTn)begin
    if(RSTn==1'b1)
        shiftreg<=6'b011111;
    else if(buttonPressed)
        shiftreg<={shiftreg[6],shiftreg[1:5]};  
end
assign leds=shiftreg;
endmodule