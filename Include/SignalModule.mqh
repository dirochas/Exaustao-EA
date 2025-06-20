//+------------------------------------------------------------------+
//|                                              SignalModule.mqh     |
//|                                             Diego MrBot © 2025    |
//+------------------------------------------------------------------+
#property copyright "Diego MrBot © 2025"
#property link      ""
#property version   "1.0"
#property strict

// Não precisamos redeclarar variáveis que já existem no EA principal
// Apenas referenciamos que elas existem em algum lugar

// Referência às variáveis globais do EA principal
extern int SinalMedias, SinalRSI, SinalCandle;          
extern datetime HoraRSI, HoraPivot, HoraFL, HoraVol, HoraCandle; 
extern int handleMA_R, handleMA_L, handleRSI, handleZZ;
//extern double MultiplicadorTam;

//+------------------------------------------------------------------+
//| Inicializa os handles dos indicadores                            |
//+------------------------------------------------------------------+
bool InitializeIndicators(
   bool in_AtivarMedias, 
   ENUM_TIMEFRAMES in_TimefMedias,
   int in_PeriodoMediaR, 
   int in_DeslocarMediaR, 
   ENUM_MA_METHOD in_MetodoMediaR, 
   ENUM_APPLIED_PRICE in_PrecoAplicadoMediaR,
   int in_PeriodoMediaL, 
   int in_DeslocarMediaL, 
   ENUM_MA_METHOD in_MetodoMediaL, 
   ENUM_APPLIED_PRICE in_PrecoAplicadoMediaL,
   bool in_AtivarRSI, 
   int in_PeriodoRSI, 
   ENUM_APPLIED_PRICE in_PrecoAplicadoRSI,
   int in_Depth, 
   int in_Deviation, 
   int in_Backstep)
{
   // Inicializar handles dos indicadores
   if(in_AtivarMedias) {
      handleMA_R = iMA(Symbol(), in_TimefMedias, in_PeriodoMediaR, in_DeslocarMediaR, 
                       in_MetodoMediaR, in_PrecoAplicadoMediaR);
      handleMA_L = iMA(Symbol(), in_TimefMedias, in_PeriodoMediaL, in_DeslocarMediaL, 
                       in_MetodoMediaL, in_PrecoAplicadoMediaL);
      if(handleMA_R == INVALID_HANDLE || handleMA_L == INVALID_HANDLE) {
         Print("Erro ao inicializar handles das médias móveis");
         return(false);
      }
   }
   
   if(in_AtivarRSI) {
      handleRSI = iRSI(Symbol(), 0, in_PeriodoRSI, in_PrecoAplicadoRSI);
      if(handleRSI == INVALID_HANDLE) {
         Print("Erro ao inicializar handle do RSI");
         return(false);
      }
   }
   
   // Handle do ZigZag (necessário para cálculo dos stops)
   handleZZ = iCustom(Symbol(), 0, "Examples\\ZigZag", in_Depth, in_Deviation, in_Backstep);
   if(handleZZ == INVALID_HANDLE) {
      Print("Erro ao inicializar handle do ZigZag: ", GetLastError());
      // Tentar abordagem alternativa
      handleZZ = iCustom(Symbol(), 0, "ZigZag", in_Depth, in_Deviation, in_Backstep);
      if(handleZZ == INVALID_HANDLE) {
         Print("Erro na segunda tentativa de inicializar ZigZag: ", GetLastError());
         return(false);
      }
   }
   
   return(true);
}

//+------------------------------------------------------------------+
//| Retorna o sinal de entrada baseado nos indicadores ativados       |
//+------------------------------------------------------------------+
int GetSinalEntrada(bool in_AtivarMedias, bool in_AtivarRSI, bool in_AtivarForcaCandle)
{
   // Obter sinais dos indicadores ativados
   if(in_AtivarMedias) GetSinalMedias();
   if(in_AtivarRSI) GetSinalRSI();
   if(in_AtivarForcaCandle) GetSinalForcaCandle();

   // Verificar sinal de venda (1)
   if((in_AtivarMedias == false || SinalMedias == 1) && 
      (in_AtivarRSI == false || SinalRSI == 1) && 
      (in_AtivarForcaCandle == false || SinalCandle == 1)) {  
      SinalMedias = 0; SinalRSI = 0; SinalCandle = 0; 
      return 1; // Venda
   }

   // Verificar sinal de compra (2)
   if((in_AtivarMedias == false || SinalMedias == 2) && 
      (in_AtivarRSI == false || SinalRSI == 2) && 
      (in_AtivarForcaCandle == false || SinalCandle == 2)) {  
      SinalMedias = 0; SinalRSI = 0; SinalCandle = 0;
      return 2; // Compra
   }
   
   return 0; // Sem sinal
}

//+------------------------------------------------------------------+
//| Obter sinal baseado nas médias móveis                             |
//+------------------------------------------------------------------+
void GetSinalMedias()
{
   // Arrays para armazenar valores dos indicadores
   double bufferMA_R[], bufferMA_L[];
   
   // Copiar dados dos indicadores
   if(CopyBuffer(handleMA_R, 0, 1, 1, bufferMA_R) <= 0 ||
      CopyBuffer(handleMA_L, 0, 1, 1, bufferMA_L) <= 0) {
      Print("Erro ao copiar dados das médias móveis");
      return;
   }
   
   // Comparar médias para determinar sinal
   if(bufferMA_R[0] < bufferMA_L[0]) 
      SinalMedias = 1; // Venda
   else if(bufferMA_R[0] > bufferMA_L[0]) 
      SinalMedias = 2; // Compra
}

//+------------------------------------------------------------------+
//| Obter sinal baseado no RSI                                        |
//+------------------------------------------------------------------+
void GetSinalRSI()
{
   // Array para armazenar valores do RSI
   double bufferRSI[];
   
   // Copiar dados do RSI
   if(CopyBuffer(handleRSI, 0, 1, 1, bufferRSI) <= 0) {
      Print("Erro ao copiar dados do RSI");
      return;
   }
   
   double rsi = bufferRSI[0];
   
   // Determinar sinal baseado nos níveis do RSI
   if(rsi >= 85) { // Valor fixo para teste
      SinalRSI = 1; // Sobrecomprado - sinal de venda
      HoraRSI = iTime(Symbol(), Period(), 1); // Horário do candle anterior
   } else if(rsi <= 20) { // Valor fixo para teste
      SinalRSI = 2; // Sobrevendido - sinal de compra
      HoraRSI = iTime(Symbol(), Period(), 1);
   }
}

//+------------------------------------------------------------------+
//| Obter sinal baseado na força do candle                           |
//+------------------------------------------------------------------+
void GetSinalForcaCandle()
{
   double close1 = iClose(Symbol(), Period(), 1);
   double open1 = iOpen(Symbol(), Period(), 1);
   double close2 = iClose(Symbol(), Period(), 2);
   double open2 = iOpen(Symbol(), Period(), 2);
   double high2 = iHigh(Symbol(), Period(), 2);
   double low2 = iLow(Symbol(), Period(), 2);
   
   // Calcular tamanho do corpo e range
   double corpo1 = MathAbs(close1 - open1);
   double range2 = high2 - low2;
   
   // Determinar sinal baseado na força do candle
   if(close1 < open1 && corpo1 >= range2 * (1 + MultiplicadorTam / 100)) {
      SinalCandle = 1; // Venda
      HoraCandle = iTime(Symbol(), Period(), 1);
   } else if(close1 > open1 && corpo1 >= range2 * (1 + MultiplicadorTam / 100)) {
      SinalCandle = 2; // Compra
      HoraCandle = iTime(Symbol(), Period(), 1);
   }
   
   // Verificar condições adicionais com RSI
   if(((handleRSI != INVALID_HANDLE) && SinalRSI > 0 && HoraCandle < HoraRSI))
      SinalCandle = 0;
}

//+------------------------------------------------------------------+
//| Obter último valor do ZigZag (modo: 1=High, 2=Low)                |
//+------------------------------------------------------------------+
double GetLastZZ(int modo)
{
   double bufferZZ[];
   
   // Alocar memória para o buffer
   ArraySetAsSeries(bufferZZ, true);
   
   // Copiar dados do ZigZag (buffer 0 contém os pontos de ZigZag)
   if(CopyBuffer(handleZZ, 0, 0, 100, bufferZZ) <= 0) {
      Print("Erro ao copiar dados do ZigZag: ", GetLastError());
      return 0;
   }
   
   // ZigZag marca com valor diferente de zero os pontos extremos
   for(int i = 0; i < 100; i++) {
      // Se encontramos um valor válido de ZigZag
      if(bufferZZ[i] != 0) {
         // Verificar se é um topo ou fundo conforme solicitado
         if(modo == 1) { // Topo (High)
            double high = iHigh(Symbol(), 0, i);
            // Verificar se o valor do ZZ está no high (topo)
            if(MathAbs(bufferZZ[i] - high) < Point()) {
               return bufferZZ[i]; // Retorna o valor do ZigZag no topo
            }
         }
         else if(modo == 2) { // Fundo (Low)
            double low = iLow(Symbol(), 0, i);
            // Verificar se o valor do ZZ está no low (fundo)
            if(MathAbs(bufferZZ[i] - low) < Point()) {
               return bufferZZ[i]; // Retorna o valor do ZigZag no fundo
            }
         }
      }
   }
   
   return 0; // Retornar 0 se nada for encontrado
}
