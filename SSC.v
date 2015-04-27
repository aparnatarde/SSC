 
module ssc (clk,rst,addr,Wdata,write,Rdata,read,ADC,pushADC);
input clk,rst;
input [31:0]addr;
input pushADC;
input [15:0] ADC;
input [31:0] Wdata;
input write;
output [31:0] Rdata;
input read;

reg [31:0] Global_Run,Global_1,Global_2,Global_3,Global_4,
	   SampleCount,Sample_1,Sample_2,Sample_3,Sample_4,
	   CorrelationSeen, Correlation00Cnt,Correlation00High, Correlation00Low, Correlation00Status,Status_1,Status_reg,correlation_seen_reg,
	   Freq00_DDS_Add, Freq00_DDS_Phase, Freq00_DDS_Phase_adj,Freq00_DDS_control,Freq_1, Control_1,Control_2,Control_3,Control_4,
	   Chip00_DDS_Freq, Chip00_DDS_Phase, Chip00_DDS_Phase_adjust, PRN00, Chip_1,Chip_2, Holdprn, Holdprn_2, PRN00_1, PRN00_corr,PRN00_corr4;


reg [31:0] Readcode;

reg hob,hob_1,hob_2, Holdhob,/* Holdhob_2, */push1,push2,push3;//pushADC

reg [12:0] phasesine;

reg [15:0] phaseadj, ADC_1,ADC_2,ADC_3 ,Final_sine_phase;// ADC

//integer sine_function;

reg signed [31:0] sinecalc,sinecalc_1,sinecalc_2,sinecalc_3,sinecalc_new,ADCcalc_3, ADCcalc;

reg signed [63:0] corr_calc_final,corr_product,corr_product_4,corr_calc_final_1;

sine SIN(.v(phasesine),.sv(phaseadj));
assign Rdata = Readcode;

//Starting of posedge block 

always @(posedge clk or posedge rst)
begin

if (rst == 1)
  begin
  Global_Run<= #1 0;Global_1 <=#1 0; Global_2 <= #1 0;Global_3 <= #1 0;Global_4 <= #1 0;			SampleCount <= #1 0;Sample_1 <= #1 0;Sample_2 <= #1 0;Sample_3 <= #1 0;Sample_4 <= #1 0;	
  
  //CorrelationSeen<= #1 0; 
  Correlation00Cnt<= #1 0;Correlation00High<= #1 0;  Correlation00Low<= #1 0; Correlation00Status<= #1 0;
  
  Freq00_DDS_Add<= #1 0; Freq00_DDS_Phase<= #1 0; Freq00_DDS_Phase_adj<= #1 0;Freq00_DDS_control<= #1 0; Freq_1 <= #1 0;
  Control_1 <= #1 0; Control_2 <= #1 0; Control_3 <= #1 0;Control_4 <= #1 0;
  
  
  Chip00_DDS_Freq<= #1 0; Chip00_DDS_Phase<= #1 0; Chip00_DDS_Phase_adjust<= #1 0; PRN00<= #1 0;
  Chip_1 <= #1 0; Chip_2 <= #1 0;Holdprn_2 <= #1 0;PRN00_1 <= #1 0;PRN00_corr <= #1 0;PRN00_corr4 <= #1 0;
  
  hob<= #1 0;hob_1<= #1 0;hob_2 <= #1 0;push1<= #1 0;push2<= #1 0;push3 <= #1 0;
  
    ADC_1<= #1 0; ADC_2<= #1 0;ADC_3 <= #1 0;
   
   sinecalc_1<= #1 0;sinecalc_2<= #1 0;sinecalc_3<= #1 0;ADCcalc_3<= #1 0;
   
   corr_calc_final <= #1 0;corr_product_4<= #1 0;corr_calc_final_1 <= #1 0;Status_1 <= #1 0;
  
  end
  
  else begin
     // Freq Chip Sample --------------------------------------------------------------
     if ((Global_Run[0]==1) && (Freq00_DDS_control[0] == 1) && (pushADC))
     begin
     Freq00_DDS_Phase 		<=#1 Freq00_DDS_Phase + (Freq00_DDS_Add+ Freq00_DDS_Phase_adj);
     Freq00_DDS_Phase_adj 	<=#1 0;
     Chip00_DDS_Phase 		<=#1 Chip00_DDS_Phase + (Chip00_DDS_Phase_adjust + Chip00_DDS_Freq);
     SampleCount 		<=#1 SampleCount + 1;
     end
     
     //-----------------------------------------------------------------------------------
     
     // Flopping of registers ----------register numbers are according to the number of stage in which it is created ----------------------------------------------------------------------------------------
     
     // stage 1
     Freq_1 	<= #1 Freq00_DDS_Phase;
     Chip_1	<= #1 Chip00_DDS_Phase;
     Sample_1	<= #1 SampleCount;
     push1	<= #1 pushADC;
     Global_1	<= #1 Global_Run;
     Control_1	<= #1 Freq00_DDS_control;
     hob_1	<= #1 hob;
     ADC_1	<= #1 ADC;
     PRN00_1	<= #1 PRN00;
     
     //---------------------------------------------------------------
     
     // stage 2
     
    // sinecalc_2	<= #1 sinecalc;
     //Holdhob_2	<= #1 Holdhob;
     Holdprn_2	<= #1 Holdprn;
     ADC_2	<= #1 ADC_1;       // to be used ahead
     push2	<= #1 push1;
     Global_2	<= #1 Global_1;
     Control_2	<= #1 Control_1;
     Sample_2	<= #1 Sample_1;
     Chip_2	<= #1 Chip_1;
     hob_2	<= #1 hob_1;
     
     //----------------------------------------------------------------
     
     //stage 3
     
     sinecalc_3	<= #1 sinecalc_new;
     ADC_3	<= #1 ADC_2;	//to be used ahead
     //
///Holdprn_3	<= #1 Holdprn_2;//to be used ahead
     push3	<= #1 push2;
     Global_3	<= #1 Global_2;
     Control_3	<= #1 Control_2;
     Sample_3	<= #1 Sample_2; // to be used ahead
     
     //trial
     ADCcalc_3	<= #1 ADCcalc;
     //corr_calc_final_1	<= #1 corr_calc_final;
     Correlation00Status	<=	#1 Status_1;
     
     PRN00_corr	<= #1 PRN00;
     
     // ----------------------------------------------------------------
     
     //stage 4
     
     corr_product_4	<= #1 corr_product;
    // push4		<= #1 push3;
     Global_4		<= #1 Global_3;
     Control_4		<= #1 Control_3;
     Sample_4		<= #1 Sample_3;
     //Holdprn_4		<= #1 Holdprn_3;
     PRN00_corr4	<= #1 PRN00_corr;
     
     //------ go to corr_calc_final--------
     
     
     
     
     
     
  
  
  
  //write registers -----------------------------------------------------------------------------------------------------------
  
  if ((addr == 32'hFE000100) && (write == 1))
     begin Global_Run <=#1 Wdata;end
     else if ((addr == 32'hFE000104) && (write == 1))
     begin SampleCount <=#1 Wdata; end
     /*else if ((addr == 32'hFE000108) && (write == 1))
     begin 
     //$display ("%d ",Wdata);
     CorrelationSeen <= Wdata;
          end*/
     else if ((addr == 32'hFE000200) && (write == 1))
     begin Freq00_DDS_Add <=#1 Wdata; end
     else if ((addr ==32'hFE000204) && (write == 1))
     begin Freq00_DDS_Phase <=#1 Wdata; end
     else if ((addr == 32'hFE000208) && (write == 1))
     begin Freq00_DDS_Phase_adj <=#1 Wdata; end
     else if ((addr == 32'hFE00020C) && (write == 1))
     begin Freq00_DDS_control <=#1 {31'b0, Wdata[0]}; end
     else if ((addr == 32'hFE000400) && (write == 1))
     begin Chip00_DDS_Freq <=#1 Wdata; end
     else if ((addr == 32'hFE000404) && (write == 1))
     begin Chip00_DDS_Phase <=#1 Wdata; end
     else if ((addr == 32'hFE000408) && (write == 1))
     begin Chip00_DDS_Phase_adjust <=#1 Wdata; end
     else if ((addr == 32'hFE00040C) && (write == 1))
     begin PRN00 <=#1 Wdata;  end
     else if ((addr == 32'hFE000600) && (write == 1))
     begin Correlation00Cnt <=#1 Wdata; end
     else if ((addr == 32'hFE000604) && (write == 1))
     begin Correlation00Low <=#1 Wdata; end
     else if ((addr == 32'hFE000608) && (write == 1))
     begin Correlation00High <=#1 Wdata; end
     else if ((addr == 32'hFE00060C) && (write == 1))
     begin Correlation00Status <=#1 Wdata;
     end
    // else begin Freq00_DDS_control	<= #1 {31'b0,Wdata[0]}; end
     
     //----------------------------------------------------------------------------------------------------------------------------
  
  // taking hob1 for prn condition
  
    hob		<= #1 Chip00_DDS_Phase[31];
 // -------------------------------------------------------------------------------------------------------------------------------   
  
  
  // transfer holdprn value 
  
    if((Chip_2[31] == 1) && (hob_2 == 0) && (push3 == 1))
      begin
      PRN00 	<= #1 Holdprn_2;
      end
  //----------- ------------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------------------------------------------------
   
  
  // correlation sum and correlation transfer ----------------------------------------------------------------------------------
  
   if((push2 == 1) && (Global_2[0] == 1) && (Control_2[0] == 1))
    begin
    corr_calc_final <= #1 corr_calc_final + corr_product;
  // i HAVE DONE corr calc and corr product on push2, and corr seen is after 1 push..however it can create problem in future...in that case change corr final to push 3, holdprn to prn00 to push 4 ...  
    end
    //-------------------go to correlation values pick up ---------------------------------------------------------------
    // doubt regarding correlation final...whether one push should be extra or not----------
    // pick up correlation ---------------------------------------------------------------------------------------------
   
    
   
   
    if ((Holdprn_2[13:0] == 1) && (PRN00[13:0] != 1))
    begin
      Correlation00Cnt 		<= #1 Sample_3;// - 1'b1;
      Correlation00Low 		<= #1 corr_calc_final[31:0];
      Correlation00High		<= #1 corr_calc_final[63:32];
      CorrelationSeen 		<= #1 1;
      Status_1			<= #1 1;
      //CorrelationSeen 		<= #1 1;
      corr_calc_final		<= #1 64'b0 ;
      corr_calc_final		<= #1 (push2)? corr_product : 64'b0;  /* if (push2) corr_calc_final <= #1 corr_product;
			    else corr_calc_final <= #1 0; */
    
    end
    
   if (correlation_seen_reg == 0)
   begin CorrelationSeen <= #1 0;
   end// else begin CorrelationSeen <= #1 CorrelationSeen; end // simulation changes with this condition
   
   if ((addr == 32'hFE00060C) && (read == 1))
   begin
   Status_1 <= #1 Status_reg;
   end// else begin Status_1 <= #1 Status_1; end 
       
       
      // think to add pipe for prn00, after that immediately check correlation // simulation changes with this condition 
       
  end     
end

//sinewave generation ------------------------------------------------------------------------------------------------------------

always @(*)
begin
if (rst == 1)
  begin
  phasesine = 0; sinecalc = 0;Final_sine_phase = 0;//ADCcalc = 0;sinecalc_new = 0;
  end
else 
  begin
  phasesine = phasesine;
  sinecalc = sinecalc;
  //ADCcalc = ADCcalc;
  //sinecalc_new = sinecalc_new;
  if((push1) && (Global_1[0] == 1) && (Control_1[0] == 1))
    begin
    Final_sine_phase = 0;
    if (Freq_1[31:30] == 2'b00)
      begin
      phasesine = Freq_1[29:17];
      Final_sine_phase = phaseadj;
      sinecalc = {{16{Final_sine_phase[15]}},Final_sine_phase};
      end
    else if (Freq_1[31:30] == 2'b01 )
      begin
      phasesine = ~(Freq_1[29:17]);
      Final_sine_phase = phaseadj;
      sinecalc = {{16{Final_sine_phase[15]}},Final_sine_phase};
      end
  
    else if (Freq_1[31:30] == 2'b10)
      begin
      phasesine = Freq_1[29:17];
      Final_sine_phase = ~phaseadj + 1'b1;
      sinecalc = {{16{Final_sine_phase[15]}},Final_sine_phase};
      end
  
    else if (Freq_1[31:30] == 2'b11)
      begin
      phasesine = ~(Freq_1[29:17]);
      Final_sine_phase = ~phaseadj + 1'b1;
      sinecalc = {{16{Final_sine_phase[15]}},Final_sine_phase};
      end
      
	/*if(Holdhob)
	  begin
	  sinecalc_new = ~sinecalc + 1'b1;
	  end
	else 
	  begin
	  sinecalc_new = sinecalc;
	  end
	
	ADCcalc = {{16{ADC_1[15]}}, ADC_1};*/
  end
end
end
// sinecalc ready... flop it for use in next cycle... name sinecalc_2-------------------------------------------------------------

// PRN generation --- Sample_3------------------------------------------------------------------------------------------------------------

always @(*)
begin
  if(rst == 1)
    begin
    Holdprn = 0 ; Holdhob = 0;
    end
  else 
    begin
    Holdhob = Holdhob;
    Holdprn = Holdprn;
    if (hob_1 == 0 && Chip_1[31] == 1)
    begin
    Holdprn = PRN00_1;
    Holdhob = Holdprn[Holdprn[31:28]];
    Holdprn[Holdprn[31:28]] = 0;
    Holdprn[13:0] = Holdprn[13:0] << 1 ;
      
    Holdprn[13:0] = (Holdhob) ?  Holdprn[13:0] ^ Holdprn[27:14] : Holdprn[13:0];
	
	/*if(Holdhob)
	begin
	Holdprn[13:0] = Holdprn[13:0] ^ Holdprn[27:14];
	end*/
   Holdhob= Holdprn[Holdprn[31:28]];
     end
     /*else begin 
	  Holdprn = Holdprn;
	  Holdhob = Holdhob;*/// as it didnt affect latches m putting it up

end
end

// holdhob and holdprn ready...to be flopped for use in next cycle.... name Holdhob_2...Holdprn_2----------------------------------

// final sinewave with inversion---------------------------------------------------------------------------------------------------

always @(*)
begin
  if (rst == 1)
    begin
    ADCcalc = 0;sinecalc_new = 0;
    end
    
  else 
    begin
    sinecalc_new = sinecalc_new;
    ADCcalc = ADCcalc;
      if ((push1) && (Global_1[0] == 1) && (Control_1[0] == 1))
      begin
	 sinecalc_new	= (Holdhob)? ~sinecalc+ 1'b1 : sinecalc; 
      end
	 /*if(Holdhob)
	  begin
	  sinecalc_new = ~sinecalc+ 1'b1;
	  end
	else
	  begin
	  sinecalc_new = sinecalc;
	  end*/
	 ADCcalc = {{16{ADC_1[15]}}, ADC_1};
      
    end
end

// final sinewave ready....to be flopped to use in next cycle.... name sinecalc_3 --------------------------------------------------

always @(*)
begin
  if(rst == 1)
    begin
    corr_product = 0;
    end
  else 
    begin
    if((push2 == 1) && (Global_2[0] ==1) && (Control_2[0] == 1))
    begin
   // ADCcalc_3 = {{16{ADC_2[15]}}, ADC_2};
    
    corr_product = sinecalc_3 * ADCcalc_3;
    end
    else begin corr_product = 0; end
    end

end

//corr_product ready......to be flopped to use in next cycle... name ...corr_product_4--------------------------------------------

// Read registers -----------------------------------------------------------------------------------------------------------------

always @(*)
begin

if (rst == 1)
  begin
Readcode = 0;correlation_seen_reg = 0; Status_reg = 0;
  end

else begin
     correlation_seen_reg = 1;
     Readcode = Readcode;
     Status_reg = Status_reg;
     if ((addr == 32'hFE000100) && (read == 1))
     begin Readcode =  Global_Run;end
     else if ((addr == 32'hFE000104) && (read == 1))
     begin Readcode = SampleCount;end
     else if ((addr == 32'hFE000108) && (read == 1))
     begin Readcode = CorrelationSeen; end
     else if ((addr == 32'hFE000200) && (read == 1))
     begin Readcode = Freq00_DDS_Add; end
     else if ((addr == 32'hFE000204) && (read == 1))
     begin Readcode = Freq00_DDS_Phase; end
     else if ((addr == 32'hFE000208) && (read == 1))
     begin Readcode = Freq00_DDS_Phase_adj;
     end
     else if ((addr == 32'hFE00020C) && (read == 1))
     begin 
     
     Readcode = Freq00_DDS_control; end//set upper 30 bitsto zero and append and compre
     else if ((addr == 32'hFE000400) && (read == 1))
     begin Readcode = Chip00_DDS_Freq; end
     else if ((addr == 32'hFE000404) && (read == 1))
     begin Readcode = Chip00_DDS_Phase; end
     else if ((addr == 32'hFE000408) && (read == 1))
     begin Readcode = Chip00_DDS_Phase_adjust; end
     else if ((addr == 32'hFE00040C) && (read == 1))
     begin 
     Readcode = PRN00;  
     end
     else if ((addr == 32'hFE000600) && (read == 1))
     begin Readcode = Correlation00Cnt; end
     else if ((addr == 32'hFE000604) && (read == 1))
     begin Readcode = Correlation00Low; 
     //$display ("low value = %h", Correlation00Low);
     end
     else if ((addr == 32'hFE000608) && (read == 1))
     begin Readcode = Correlation00High;
     //CorrelationSeen[0] = 
     correlation_seen_reg = 0;
     //$display ("correlationseen");
     end
     else if ((addr == 32'hFE00060C) && (read == 1))
     begin Readcode = Correlation00Status;
     Status_reg = 0;
     end
     end
end

endmodule

// --------------------------------------------------------------------------------------------------------------------------------