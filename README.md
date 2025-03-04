# Exaustão-EA 📈

Um Expert Advisor (EA) avançado para MetaTrader 5 focado em análise de exaustão de movimentos e gerenciamento inteligente de posições.

## ✅ Funcionalidades Implementadas
- **Análise de Exaustão**: Identificação de movimentos exaustivos para entrada precisa
- **BreakEven Inteligente**: Sistema proporcional baseado em percentual do Take Profit
- **Fechamento Parcial**: Baseado em níveis de Fibonacci para maximizar resultados
- **Controle de Operações**: Gerenciamento completo de posições com MagicNumber

## 🚀 Funcionalidades Futuras
- Contadores e limitadores de lucro e perdas diários
- Melhorias nos parâmetros de controle de Stop (stop máximo e mínimo)
- Cálculo de lote automático baseado no risco por trading
- Sistema de múltiplas ordens por ciclo de risco
- Integração com API de calendário econômico

## 📋 Requisitos
- MetaTrader 5 (Build 4000 ou superior)
- Conta com permissão para EA's
- Suporte a operações com Hedge (opcional)

## 📦 Bibliotecas Utilizadas
```cpp
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Arrays/ArrayDouble.mqh>
