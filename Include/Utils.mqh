//+------------------------------------------------------------------+
//|                                                     Utils.mqh     |
//|                                             Diego MrBot © 2025    |
//|                                                                   |
//+------------------------------------------------------------------+
#property copyright "Diego MrBot © 2025"
#property link      ""
#property version   "1.0"
#property strict

//+------------------------------------------------------------------+
//| SEÇÃO: FUNÇÕES UTILITÁRIAS                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Define o comentário do Expert                                     |
//+------------------------------------------------------------------+
void SetExpertComment(string texto)
{
   Comment(texto);
}

//+------------------------------------------------------------------+
//| Converte o número de posições para texto                          |
//+------------------------------------------------------------------+
string PosicoesToText(int compras, int vendas, int maxOrdens)
{
   return "  Compras: " + IntegerToString(compras) + 
          " | Vendas: " + IntegerToString(vendas) + 
          " | Máx: " + IntegerToString(maxOrdens);
}

//+------------------------------------------------------------------+
//| Formata o valor monetário com 2 casas decimais                    |
//+------------------------------------------------------------------+
string FormatarMoeda(double valor)
{
   return DoubleToString(valor, 2);
}

//+------------------------------------------------------------------+
//| Informa tempo decorrido em formato legível                        |
//+------------------------------------------------------------------+
string TempoDecorrido(datetime inicio)
{
   int segundos = (int)(TimeCurrent() - inicio);
   int minutos = segundos / 60;
   int horas = minutos / 60;
   int dias = horas / 24;
   
   segundos %= 60;
   minutos %= 60;
   horas %= 24;
   
   string resultado = "";
   if(dias > 0) resultado += IntegerToString(dias) + "d ";
   if(horas > 0) resultado += IntegerToString(horas) + "h ";
   if(minutos > 0) resultado += IntegerToString(minutos) + "m ";
   resultado += IntegerToString(segundos) + "s";
   
   return resultado;
}
