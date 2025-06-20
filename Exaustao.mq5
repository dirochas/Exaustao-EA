#property copyright "Diego MrBot © 2025"
#property link      ""
#property version   "2.12"
#property strict

//--- Arquivos incluídos
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Arrays\ArrayDouble.mqh>

#include "Include/PositionManagement.mqh"
#include "Include/RiskManagement.mqh"
#include "Include/SignalModule.mqh"
#include "Include/TradeExecution.mqh"
#include "Include/Utils.mqh"

//--- Enumerações
enum MAMethod_enum {
   SMA = MODE_SMA,
   SMMA = MODE_SMMA,
   EMA = MODE_EMA,
   LWMA = MODE_LWMA
};

//--- Parâmetros de entrada (inputs)
// Parâmetros gerais de negociação
input group "===== Configurações Gerais ====="
input double   Lotes                = 0.10;       // Volume de negociação
input double   TakeProfit           = 1.30;      // TakeProfit (x Stop)
input double   StopLossAddZZ        = 200;       // Pontos adicionais ao ZigZag
input string   Comentario           = "Bot";     // Comentário das ordens
input int      MagicNumber          = 201002035; // MagicNumber (ID do EA)
input int      MaxOrders            = 10;        // Máx ordens em aberto (todos pares)

// Parâmetros de breakeven
input group "===== Configurações de Breakeven ====="
input bool     AtivarBreakEven      = true;     // Usar função breakeven
input double   PercentAtivarBE      = 75;        // % do take para ativar breakeven
input double   PercentSalvarBE      = 60;        // % para salvar acima do breakeven

// Parâmetros de indicadores
input group "===== Configurações de Indicadores ====="
input bool     AtivarMedias         = true;      // Ativar médias móveis
input ENUM_TIMEFRAMES TimefMedias   = PERIOD_CURRENT; // Timeframe das médias
input bool     AtivarRSI            = true;      // Ativar RSI
input bool     AtivarForcaCandle    = true;      // Ativar candle de força

// Média rápida
input group "------- Média Rápida -------"
input int      PeriodoMediaR        = 4;         // Período
input ENUM_APPLIED_PRICE PrecoAplicadoMediaR = PRICE_CLOSE; // Aplicado a
input ENUM_MA_METHOD MetodoMediaR   = MODE_SMA;  // Método
input int      DeslocarMediaR       = 0;         // Deslocar

// Média lenta
input group "------- Média Lenta -------"
input int      PeriodoMediaL        = 10;        // Período
input ENUM_APPLIED_PRICE PrecoAplicadoMediaL = PRICE_CLOSE; // Aplicado a
input ENUM_MA_METHOD MetodoMediaL   = MODE_SMA;  // Método
input int      DeslocarMediaL       = 0;         // Deslocar

// RSI
input group "------- RSI -------"
input int      PeriodoRSI           = 10;        // Período
input ENUM_APPLIED_PRICE PrecoAplicadoRSI = PRICE_CLOSE; // Aplicado a
input double   SobrecompradoRSI     = 85;        // Sobrecomprado (venda)
input double   SobrevendidoRSI      = 20;        // Sobrevendido (compra)

// Candle de força
input group "------- Candle de Força -------"
input double   MultiplicadorTam     = 35;        // % a mais do tamanho

// ZigZag
input group "------- ZigZag -------"
input int      Depth                = 12;        // Profundidade
input int      Deviation            = 5;         // Desvio
input int      Backstep             = 3;         // Backstep

//--- Objetos globais
CTrade         trade;                // Operações de trade
CPositionInfo  positionInfo;         // Informações sobre posições
CSymbolInfo    symbolInfo;           // Informações sobre o símbolo
CAccountInfo   accountInfo;          // Informações sobre a conta

//--- Variáveis globais
int            SlippageMaximo = 999999;          // Slippage máximo
ulong          BuyTicket, SellTicket;            // Tickets de ordens
int            SinalMedias, SinalRSI, SinalCandle; // Sinais dos indicadores
datetime       LastTime, HoraRSI, HoraPivot, HoraFL, HoraVol, HoraCandle;
string         TextoAlerta;                      // Texto para alertas
bool           Flag, Foi;                        // Flags de controle

//--- Handles dos indicadores
int            handleMA_R = INVALID_HANDLE;      // Handle média móvel rápida
int            handleMA_L = INVALID_HANDLE;      // Handle média móvel lenta
int            handleRSI = INVALID_HANDLE;       // Handle RSI
int            handleZZ = INVALID_HANDLE;        // Handle ZigZag

//+------------------------------------------------------------------+
//| Função de inicialização do Expert                                |
//+------------------------------------------------------------------+
int OnInit()
{
   // Configuração do objeto de negociação
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(SlippageMaximo);
   trade.SetMarginMode();
   trade.LogLevel(LOG_LEVEL_ALL);
   trade.SetTypeFillingBySymbol(Symbol());
   
   // Inicializar objeto de símbolo
   symbolInfo.Name(Symbol());
   symbolInfo.RefreshRates();
   
   // Inicializar handles dos indicadores
   if(!InitializeIndicators(
                          AtivarMedias, TimefMedias, PeriodoMediaR, DeslocarMediaR, MetodoMediaR, PrecoAplicadoMediaR,
                          PeriodoMediaL, DeslocarMediaL, MetodoMediaL, PrecoAplicadoMediaL,
                          AtivarRSI, PeriodoRSI, PrecoAplicadoRSI,
                          Depth, Deviation, Backstep)) {
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Função de desinicialização do Expert                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Liberar handles de indicadores
   if(handleMA_R != INVALID_HANDLE)
      IndicatorRelease(handleMA_R);
   if(handleMA_L != INVALID_HANDLE)
      IndicatorRelease(handleMA_L);
   if(handleRSI != INVALID_HANDLE)
      IndicatorRelease(handleRSI);
   if(handleZZ != INVALID_HANDLE)
      IndicatorRelease(handleZZ);
}

//+------------------------------------------------------------------+
//| Função de tick do Expert                                         |
//+------------------------------------------------------------------+
void OnTick()
{
   // Atualizar informações do símbolo
   symbolInfo.RefreshRates();
   
   // Texto informativo
   TextoAlerta = "EA Mr Bot Exaustao 2.01 .";
   
   // Verificar se é um novo candle
   datetime currBarTime = iTime(Symbol(), Period(), 0);
   if(LastTime != currBarTime) {
      // Verificar condições para nova ordem
      if(ContarTodasOrdensAbertasC() + ContarTodasOrdensAbertasV() == 0 && ContarTodasGeral() < MaxOrders) {
         int sinal = GetSinalEntrada(AtivarMedias, AtivarRSI, AtivarForcaCandle);
         
         if(sinal == 1) 
            Sell(Lotes, StopLossAddZZ, TakeProfit, Comentario, trade, symbolInfo, accountInfo);
         else if(sinal == 2) 
            Buy(Lotes, StopLossAddZZ, TakeProfit, Comentario, trade, symbolInfo, accountInfo);
      }
      LastTime = currBarTime;
   }

   // Verificar breakeven se ativado
   if(AtivarBreakEven) {
      GerenciarBreakEven(MagicNumber, PercentAtivarBE, PercentSalvarBE, trade, positionInfo, symbolInfo);
   }
}


//+------------------------------------------------------------------+
//| Contar posições de compra abertas                                 |
//+------------------------------------------------------------------+
int ContarTodasOrdensAbertasC()
{
   int contador = 0;
   
   // Percorrer todas as posições abertas
   for(int i = 0; i < PositionsTotal(); i++) {
      if(positionInfo.SelectByIndex(i)) {
         if(positionInfo.Magic() == MagicNumber && 
            positionInfo.Symbol() == Symbol() && 
            positionInfo.PositionType() == POSITION_TYPE_BUY) {
            contador++;
         }
      }
   }
   
   return contador;
}

//+------------------------------------------------------------------+
//| Contar posições de venda abertas                                  |
//+------------------------------------------------------------------+
int ContarTodasOrdensAbertasV()
{
   int contador = 0;
   
   // Percorrer todas as posições abertas
   for(int i = 0; i < PositionsTotal(); i++) {
      if(positionInfo.SelectByIndex(i)) {
         if(positionInfo.Magic() == MagicNumber && 
            positionInfo.Symbol() == Symbol() && 
            positionInfo.PositionType() == POSITION_TYPE_SELL) {
            contador++;
         }
      }
   }
   
   return contador;
}

//+------------------------------------------------------------------+
//| Contar todas as posições abertas do EA                            |
//+------------------------------------------------------------------+
int ContarTodasGeral()
{
   int contador = 0;
   
   // Percorrer todas as posições abertas
   for(int i = 0; i < PositionsTotal(); i++) {
      if(positionInfo.SelectByIndex(i)) {
         if(positionInfo.Magic() == MagicNumber) {
            contador++;
         }
      }
   }
   
   return contador;
}
