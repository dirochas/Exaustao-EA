//+------------------------------------------------------------------+
//|                                         PositionManagement.mqh    |
//|                                             Diego MrBot © 2025    |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Diego MrBot © 2025"
#property link      ""
#property version   "1.0"
#property strict

//+------------------------------------------------------------------+
//| Otimização: Conta todas as posições em uma única iteração         |
//+------------------------------------------------------------------+
void ContarTodasPosicoes(int magicNumber, string simbolo, int &compras, int &vendas, int &total, CPositionInfo &posInfo)
{
   compras = 0;
   vendas = 0;
   total = 0;
   
   // Fazer apenas uma iteração pelas posições
   for(int i = 0; i < PositionsTotal(); i++) {
      if(posInfo.SelectByIndex(i)) {
         if(posInfo.Magic() == magicNumber) {
            total++;
            if(posInfo.Symbol() == simbolo) {
               if(posInfo.PositionType() == POSITION_TYPE_BUY) {
                  compras++;
               } else if(posInfo.PositionType() == POSITION_TYPE_SELL) {
                  vendas++;
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Conta ordens abertas de compra para um símbolo específico        |
//+------------------------------------------------------------------+
int ContarOrdensAbertasCompra(int magicNumber, string simbolo, CPositionInfo &posInfo)
{
   int contador = 0;
   
   for(int i = 0; i < PositionsTotal(); i++) {
      if(posInfo.SelectByIndex(i)) {
         if(posInfo.Magic() == magicNumber && posInfo.Symbol() == simbolo && posInfo.PositionType() == POSITION_TYPE_BUY) {
            contador++;
         }
      }
   }
   
   return contador;
}

//+------------------------------------------------------------------+
//| Conta ordens abertas de venda para um símbolo específico         |
//+------------------------------------------------------------------+
int ContarOrdensAbertasVenda(int magicNumber, string simbolo, CPositionInfo &posInfo)
{
   int contador = 0;
   
   for(int i = 0; i < PositionsTotal(); i++) {
      if(posInfo.SelectByIndex(i)) {
         if(posInfo.Magic() == magicNumber && posInfo.Symbol() == simbolo && posInfo.PositionType() == POSITION_TYPE_SELL) {
            contador++;
         }
      }
   }
   
   return contador;
}

//+------------------------------------------------------------------+
//| Conta todas as posições abertas com o magic number especificado  |
//+------------------------------------------------------------------+
int ContarTodasPosicoesAbertas(int magicNumber, CPositionInfo &posInfo)
{
   int contador = 0;
   
   for(int i = 0; i < PositionsTotal(); i++) {
      if(posInfo.SelectByIndex(i)) {
         if(posInfo.Magic() == magicNumber) {
            contador++;
         }
      }
   }
   
   return contador;
}

//+------------------------------------------------------------------+
//| Gerencia o breakeven das posições                                |
//+------------------------------------------------------------------+
void GerenciarBreakEven(int magicNumber, double percentAtivar, double percentSalvar, 
                        CTrade &tradeObj, CPositionInfo &posInfo, CSymbolInfo &symbInfo)
{
   // Verificar todas as posições abertas
   for(int i = 0; i < PositionsTotal(); i++) {
      if(posInfo.SelectByIndex(i)) {
         // Verificar se a posição pertence ao EA atual
         if(posInfo.Magic() == magicNumber) {
            // Obter dados da posição
            double precoEntrada = posInfo.PriceOpen();
            double stopLoss = posInfo.StopLoss();
            double takeProfit = posInfo.TakeProfit();
            ulong ticket = posInfo.Ticket();
            
            // Calcular distância do TP para o preço de entrada
            double distanciaTP = 0;
            
            // NÃO fazer RefreshRates() aqui - já foi feito no OnTick()
            
            // Calcular distância para o TP dependendo do tipo de posição
            if(posInfo.PositionType() == POSITION_TYPE_BUY) {
               distanciaTP = takeProfit - precoEntrada;
               double precoAtual = symbInfo.Bid();
               
               // Verificar se o preço atual está acima do ponto para ativar breakeven
               if(precoAtual >= precoEntrada + (distanciaTP * percentAtivar / 100)) {
                  // Calcular o novo stop loss (BE + % do TP)
                  double novoSL = precoEntrada + (distanciaTP * percentSalvar / 100);
                  
                  // Modificar apenas se o novo SL é melhor que o atual
                  if(stopLoss < novoSL || stopLoss == 0) {
                     tradeObj.PositionModify(ticket, novoSL, takeProfit);
                  }
               }
            }
            else if(posInfo.PositionType() == POSITION_TYPE_SELL) {
               distanciaTP = precoEntrada - takeProfit;
               double precoAtual = symbInfo.Ask();
               
               // Verificar se o preço atual está abaixo do ponto para ativar breakeven
               if(precoAtual <= precoEntrada - (distanciaTP * percentAtivar / 100)) {
                  // Calcular o novo stop loss (BE + % do TP)
                  double novoSL = precoEntrada - (distanciaTP * percentSalvar / 100);
                  
                  // Modificar apenas se o novo SL é melhor que o atual
                  if(stopLoss > novoSL || stopLoss == 0) {
                     tradeObj.PositionModify(ticket, novoSL, takeProfit);
                  }
               }
            }
         }
      }
   }
}
