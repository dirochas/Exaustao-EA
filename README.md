# Exaustão-EA - Sistema de Trading Modular 📈 

Um Expert Advisor (EA) avançado para MetaTrader 5 focado em análise de exaustão de movimentos e gerenciamento inteligente de posições.

## Estrutura do Projeto

```cpp
Exaustao.mq5 (Arquivo principal)
|
└── Include/
    ├── SignalModule.mqh (Análise técnica e sinais)
    ├── TradeExecution.mqh (Funções de execução de ordens)
    ├── RiskManagement.mqh (Gerenciamento de risco)
    ├── PositionManagement.mqh (Gerenciamento de posições)
    └── Utils.mqh (Funções utilitárias)
```

## Descrição dos Módulos

### Exaustao.mq5
Arquivo principal que coordena todos os módulos e contém:
- Declarações de inputs e variáveis globais
- Funções principais do EA (OnInit, OnDeinit, OnTick)
- Configurações gerais e inicialização dos módulos

### SignalModule.mqh
Responsável pela análise técnica e geração de sinais:
- Funções para análise de médias móveis
- Funções para análise de RSI
- Funções para análise de padrões de vela (força do candle)
- Função GetSinalEntrada para consolidar todos os sinais

### TradeExecution.mqh
Responsável pela execução de ordens:
- Funções para abrir posições (Buy/Sell)
- Funções para fechar posições
- Cálculos de níveis de Stop Loss e Take Profit baseados no ZigZag

### RiskManagement.mqh
Gerenciamento de risco:
- Cálculo de lotes baseado em percentual de risco
- Validações de margem e capital mínimo

### PositionManagement.mqh
Gerenciamento de posições abertas:
- Funções para verificar posições existentes
- Funções para movimentar stops (trailing stop) & BreakEven


### Utils.mqh
Funções utilitárias gerais:
- Formatação de strings
- Funções auxiliares para data/hora
- Outras funções de uso geral



## ✅ Funcionalidades e Recursos já Implementados:
- **Análise de Exaustão**: Identificação de movimentos exaustivos para entrada precisa
- **BreakEven Inteligente**: Sistema proporcional baseado em percentual do Take Profit
- **Controle de Operações**: Gerenciamento completo de posições com MagicNumber

## 🚀 Funcionalidades Futuras
- Contadores e limitadores de lucro e perdas diários
- Painel de visualização sofisticado para acompanhar visualmente o resultado.
- Cálculo de lote automático baseado no risco por trading.
- Sistema de múltiplas ordens por ciclo de risco.
- Melhorias nos parâmetros de controle de Stop (stop máximo e mínimo).
- Integração com API de calendário econômico.

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
