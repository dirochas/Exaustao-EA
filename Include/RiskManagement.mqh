#property copyright "Diego MrBot © 2025"
#property link      ""
#property version   "1.0"
#property strict

//+------------------------------------------------------------------+
//| Calcula o tamanho de lote baseado no risco percentual            |
//+------------------------------------------------------------------+
double CalcularLotePorRisco(string simbolo, double stopLoss, double riscoPct, 
                           CAccountInfo &accInfo, CSymbolInfo &symbInfo)
{
   // Verificar se os parâmetros são válidos
   if(stopLoss <= 0 || riscoPct <= 0)
      return 0;
      
   // Não chamar RefreshRates() aqui - Já foi chamado no OnTick()
   
   // Obter o saldo da conta
   double saldo = accInfo.Balance();
   
   // Calcular o valor monetário do risco
   double valorRisco = saldo * (riscoPct / 100);
   
   // Calcular o valor do pip
   double tickSize = symbInfo.TickSize();
   double tickValue = symbInfo.TickValue();
   double pontoValue = tickValue / tickSize;
   
   // Calcular o valor do stop loss em pontos
   double stopEmPontos = stopLoss / symbInfo.Point();
   
   // Calcular o tamanho do lote
   double lote = valorRisco / (stopEmPontos * pontoValue);
   
   // Normalizar o tamanho do lote de acordo com as restrições do símbolo
   double loteStep = symbInfo.LotsStep();
   double loteMin = symbInfo.LotsMin();
   double loteMax = symbInfo.LotsMax();
   
   lote = NormalizeDouble(MathFloor(lote / loteStep) * loteStep, 2);
   
   // Verificar limites
   if(lote < loteMin)
      lote = loteMin;
   if(lote > loteMax)
      lote = loteMax;
      
   return lote;
}

//+------------------------------------------------------------------+
//| Verifica se há margem suficiente para abrir uma posição          |
//+------------------------------------------------------------------+
bool VerificarMargemSuficiente(string simbolo, ENUM_ORDER_TYPE tipoOrdem, double volume, 
                              CAccountInfo &accInfo)
{
   // Calcular a margem necessária para a operação
   double precoAtual = (tipoOrdem == ORDER_TYPE_BUY) ? SymbolInfoDouble(simbolo, SYMBOL_ASK) : SymbolInfoDouble(simbolo, SYMBOL_BID);
   double margemNecessaria = accInfo.MarginCheck(simbolo, tipoOrdem, volume, precoAtual);
   
   // Verificar se a margem livre é suficiente
   if(accInfo.FreeMargin() < margemNecessaria || margemNecessaria <= 0)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Calcula o drawdown atual da conta em percentual                  |
//+------------------------------------------------------------------+
double CalcularDrawdownAtual()
{
   double balanceAtual = AccountInfoDouble(ACCOUNT_BALANCE);
   double equityAtual = AccountInfoDouble(ACCOUNT_EQUITY);
   
   if(balanceAtual == 0)
      return 0;
      
   return ((balanceAtual - equityAtual) / balanceAtual) * 100;
}
