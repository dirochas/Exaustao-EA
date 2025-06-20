//+------------------------------------------------------------------+
//|                                          TradeExecution.mqh      |
//|                                          Diego MrBot © 2025      |
//+------------------------------------------------------------------+
#property copyright "Diego MrBot © 2025"
#property link      ""
#property version   "1.0"
#property strict

// Referências às variáveis globais do EA principal
extern ulong BuyTicket, SellTicket;            // Tickets de ordens

//+------------------------------------------------------------------+
//| Executar ordem de compra                                          |
//+------------------------------------------------------------------+
int Buy(double Lot, 
       double in_StopLossAddZZ, 
       double in_TakeProfit, 
       string in_Comentario,
       CTrade &in_trade, 
       CSymbolInfo &in_symbolInfo, 
       CAccountInfo &in_accountInfo)
{
   // Verificar margem livre
   double margin_needed = in_accountInfo.FreeMarginCheck(Symbol(), ORDER_TYPE_BUY, Lot, in_symbolInfo.Ask());
   if(in_accountInfo.FreeMargin() < margin_needed || margin_needed <= 0) {
      Alert("SEM MARGEM PARA ABRIR BUY " + DoubleToString(Lot, 2) + " EM " + Symbol() + 
            " (Margem livre: " + DoubleToString(in_accountInfo.FreeMargin(), 2) + 
            ", Necessário: " + DoubleToString(margin_needed, 2) + ")");
      return -1;
   }
   
   // Calcular níveis de stop e take profit
   double Stop = NormalizeDouble(GetLastZZ(2) - in_StopLossAddZZ * _Point, _Digits);
   double price = in_symbolInfo.Ask();
   double Take = NormalizeDouble(price + (price - Stop) * in_TakeProfit, _Digits);
   
   // Executar compra
   if(in_trade.Buy(Lot, Symbol(), 0, Stop, Take, in_Comentario)) {
      BuyTicket = in_trade.ResultOrder();
      return (int)BuyTicket;
   } else {
      Print("Erro ao abrir BUY: ", in_trade.ResultRetcode(), " - ", in_trade.ResultRetcodeDescription());
      return -1;
   }
}

//+------------------------------------------------------------------+
//| Executar ordem de venda                                          |
//+------------------------------------------------------------------+
int Sell(double Lot, 
        double in_StopLossAddZZ, 
        double in_TakeProfit, 
        string in_Comentario,
        CTrade &in_trade, 
        CSymbolInfo &in_symbolInfo, 
        CAccountInfo &in_accountInfo)
{
   // Verificar margem livre
   double margin_needed = in_accountInfo.FreeMarginCheck(Symbol(), ORDER_TYPE_SELL, Lot, in_symbolInfo.Bid());
   if(in_accountInfo.FreeMargin() < margin_needed || margin_needed <= 0) {
      Alert("SEM MARGEM PARA ABRIR SELL " + DoubleToString(Lot, 2) + " EM " + Symbol() + 
            " (Margem livre: " + DoubleToString(in_accountInfo.FreeMargin(), 2) + 
            ", Necessário: " + DoubleToString(margin_needed, 2) + ")");
      return -1;
   }
   
   // Calcular níveis de stop e take profit
   double Stop = NormalizeDouble(GetLastZZ(1) + in_StopLossAddZZ * _Point, _Digits);
   double price = in_symbolInfo.Bid();
   double Take = NormalizeDouble(price - (Stop - price) * in_TakeProfit, _Digits);
   
   // Executar venda
   if(in_trade.Sell(Lot, Symbol(), 0, Stop, Take, in_Comentario)) {
      SellTicket = in_trade.ResultOrder();
      return (int)SellTicket;
   } else {
      Print("Erro ao abrir SELL: ", in_trade.ResultRetcode(), " - ", in_trade.ResultRetcodeDescription());
      return -1;
   }
}

//+------------------------------------------------------------------+
//| Fecha todas as posições de compra deste EA                        |
//+------------------------------------------------------------------+
void FecharTodasCompras(int in_MagicNumber, 
                       CTrade &in_trade, 
                       CPositionInfo &in_positionInfo)
{
   // Percorrer todas as posições abertas
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(in_positionInfo.SelectByIndex(i)) {
         if(in_positionInfo.Magic() == in_MagicNumber && 
            in_positionInfo.Symbol() == Symbol() && 
            in_positionInfo.PositionType() == POSITION_TYPE_BUY) {
            
            // Fechar posição de compra
            if(in_trade.PositionClose(in_positionInfo.Ticket())) {
               Print("POSIÇÃO BUY " + DoubleToString(in_positionInfo.Volume(), 2) + " FECHADA COM SUCESSO!");
            } else {
               Print("ERRO AO FECHAR POSIÇÃO BUY " + DoubleToString(in_positionInfo.Volume(), 2) + 
                     ". Código: ", in_trade.ResultRetcode());
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Fecha todas as posições de venda deste EA                         |
//+------------------------------------------------------------------+
void FecharTodasVendas(int in_MagicNumber, 
                      CTrade &in_trade, 
                      CPositionInfo &in_positionInfo)
{
   // Percorrer todas as posições abertas
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(in_positionInfo.SelectByIndex(i)) {
         if(in_positionInfo.Magic() == in_MagicNumber && 
            in_positionInfo.Symbol() == Symbol() && 
            in_positionInfo.PositionType() == POSITION_TYPE_SELL) {
            
            // Fechar posição de venda
            if(in_trade.PositionClose(in_positionInfo.Ticket())) {
               Print("POSIÇÃO SELL " + DoubleToString(in_positionInfo.Volume(), 2) + " FECHADA COM SUCESSO!");
            } else {
               Print("ERRO AO FECHAR POSIÇÃO SELL " + DoubleToString(in_positionInfo.Volume(), 2) + 
                     ". Código: ", in_trade.ResultRetcode());
            }
         }
      }
   }
}
