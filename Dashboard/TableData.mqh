//+------------------------------------------------------------------+
//|                                                    Dashboard.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- includes
#include <Canvas\Canvas.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Класс ячейки таблицы                                             |
//+------------------------------------------------------------------+
class CTableCell : public CObject
  {
private:
   int               m_row;                     // Строка
   int               m_col;                     // Столбец
   int               m_x;                       // Координата X
   int               m_y;                       // Координата Y
public:
//--- Методы установки значений
   void              SetRow(const uint row)     { this.m_row=(int)row;  }
   void              SetColumn(const uint col)  { this.m_col=(int)col;  }
   void              SetX(const uint x)         { this.m_x=(int)x;      }
   void              SetY(const uint y)         { this.m_y=(int)y;      }
   void              SetXY(const uint x,const uint y)
                       {
                        this.m_x=(int)x;
                        this.m_y=(int)y;
                       }
//--- Методы получения значений
   int               Row(void)            const { return this.m_row;    }
   int               Column(void)         const { return this.m_col;    }
   int               X(void)              const { return this.m_x;      }
   int               Y(void)              const { return this.m_y;      }
//--- Виртуальный метод сравнения двух объектов
   virtual int       Compare(const CObject *node,const int mode=0) const
                       {
                        const CTableCell *compared=node;
                        return(this.Column()>compared.Column() ? 1 : this.Column()<compared.Column() ? -1 : 0);
                       }
//--- Конструктор/деструктор
                     CTableCell(const int row,const int column) : m_row(row),m_col(column){}
                    ~CTableCell(void){}
  };
//+------------------------------------------------------------------+
//| Класс строк таблиц                                               |
//+------------------------------------------------------------------+
class CTableRow : public CObject
  {
private:
  CArrayObj          m_list_cell;               // Список ячеек
  int                m_row;                     // Номер строки
  int                m_y;                       // Координата Y
public:
//--- Возвращает список ячеек таблицы в строке
   CArrayObj        *GetListCell(void)       { return &this.m_list_cell;         }
//--- Возвращает (1) количество ячеек таблицы в строке (2) индекс строки в таблице
   int               CellsTotal(void)  const { return this.m_list_cell.Total();  }
   int               Row(void)         const { return this.m_row;                }
//--- (1) Устанавливает, (2) возвращает координату Y строки
   void              SetY(const int y)       { this.m_y=y;                       }
   int               Y(void)           const { return this.m_y;                  }
//--- Добавляет новую ячейку таблицы в строку
   bool              AddCell(CTableCell *cell)
                       {
                        this.m_list_cell.Sort();
                        if(this.m_list_cell.Search(cell)!=WRONG_VALUE)
                          {
                           ::PrintFormat("%s: Table cell with index %lu is already in the list",__FUNCTION__,cell.Column());
                           return false;
                          }
                        if(!this.m_list_cell.InsertSort(cell))
                          {
                           ::PrintFormat("%s: Failed to add table cell with index %lu to list",__FUNCTION__,cell.Column());
                           return false;
                          }
                        return true;
                       }
//--- Возвращает указатель на указанную ячейку в строке
   CTableCell       *GetCell(const int column)
                       {
                        const CTableCell *obj=new CTableCell(this.m_row,column);
                        int index=this.m_list_cell.Search(obj);
                        delete obj;
                        return this.m_list_cell.At(index);
                       }
//--- Виртуальный метод сравнения двух объектов
   virtual int       Compare(const CObject *node,const int mode=0) const
                       {
                        const CTableRow *compared=node;
                        return(this.Row()>compared.Row() ? 1 : this.Row()<compared.Row() ? -1 : 0);
                       }
//--- Конструктор/деструктор
                     CTableRow(const int row) : m_row(row)  { this.m_list_cell.Clear();   }
                    ~CTableRow(void)                        { this.m_list_cell.Clear();   }
  };
//+------------------------------------------------------------------+
//| Класс данных таблиц                                              |
//+------------------------------------------------------------------+
class CTableData : public CObject
  {
private:
   CArrayObj         m_list_rows;               // Список строк
public:
//--- Возвращает список строк таблицы
   CArrayObj        *GetListRows(void)       { return &this.m_list_rows;   }
//--- Добавляет новую строку в таблицу
   bool              AddRow(CTableRow *row)
                       {
                        //--- Устанавливаем флаг сортированного списка
                        this.m_list_rows.Sort();
                        //--- Если такой объект уже есть в списке (поиск вернул индекс объекта, а не -1),
                        //--- сообщаем об этом в журнал и возвращаем false
                        if(this.m_list_rows.Search(row)!=WRONG_VALUE)
                          {
                           ::PrintFormat("%s: Table row with index %lu is already in the list",__FUNCTION__,row.Row());
                           return false;
                          }
                        //--- Если не удалось добавить указатель в сортированный список - сообщаем об этом в журнал и возвращаем false
                        if(!this.m_list_rows.InsertSort(row))
                          {
                           ::PrintFormat("%s: Failed to add table cell with index %lu to list",__FUNCTION__,row.Row());
                           return false;
                          }
                        //--- Успешно - возвращаем true
                        return true;
                       }
//--- Возвращает указатель на (1) указанную строку, (2) указанную ячейку в указанной строке таблицы
   CTableRow        *GetRow(const int index) { return this.m_list_rows.At(index);   }
   CTableCell       *GetCell(const int row,const int column)
                       {
                        //--- Получаем указатель на объект-строку в списке строк
                        CTableRow *row_obj=this.GetRow(row);
                        //--- Если объект получить не удалось - возвращаем NULL
                        if(row_obj==NULL)
                           return NULL;
                        //--- Получаем указатель на объект-ячейку в строке по номеру столбца и
                        CTableCell *cell=row_obj.GetCell(column);
                        //--- возвращаем результат (указатель на объект, либо NULL)
                        return cell;
                       }
//--- Записывает в переданные в метод переменные координаты X и Y указанной ячейки таблицы
   void              CellXY(const uint row,const uint column, int &x, int &y)
                       {
                        x=WRONG_VALUE;
                        y=WRONG_VALUE;
                        CTableCell *cell=this.GetCell(row,column);
                        if(cell==NULL)
                           return;
                        x=cell.X();
                        y=cell.Y();
                       }
//--- Возвращает координату X указанной ячейки таблицы
   int               CellX(const uint row,const uint column)
                       {
                        CTableCell *cell=this.GetCell(row,column);
                        return(cell!=NULL ? cell.X() : WRONG_VALUE);
                       }
//--- Возвращает координату Y указанной ячейки таблицы
   int               CellY(const uint row,const uint column)
                       {
                        CTableCell *cell=this.GetCell(row,column);
                        return(cell!=NULL ? cell.Y() : WRONG_VALUE);
                       }
//--- Возвращает количество (1) строк, (2) столбцов в таблице
   int               RowsTotal(void)            { return this.m_list_rows.Total();  }
   int               ColumnsTotal(void)
                       {
                        //--- Если в списке нет ни одной строки - возвращаем 0
                        if(this.RowsTotal()==0)
                           return 0;
                        //--- Получаем указатель на первую строку и возвращаем количество ячеек в ней
                        CTableRow *row=this.GetRow(0);
                        return(row!=NULL ? row.CellsTotal() : 0);
                       }
//--- Возвращает общее количество ячеек таблицы
   int               CellsTotal(void){ return this.RowsTotal()*this.ColumnsTotal(); }
//--- Очищает списки строк и ячеек таблицы
   void              Clear(void)
                       {
                        //--- В цикле по количеству строк в списке строк таблицы
                        for(int i=0;i<this.m_list_rows.Total();i++)
                          {
                           //--- получаем указатель на очередную строку
                           CTableRow *row=this.m_list_rows.At(i);
                           if(row==NULL)
                              continue;
                           //--- из полученного объекта-строки получаем список ячеек,
                           CArrayObj *list_cell=row.GetListCell();
                           //--- очищаем список ячеек
                           if(list_cell!=NULL)
                              list_cell.Clear();
                          }
                        //--- Очищаем список строк
                        this.m_list_rows.Clear();
                       }                
//--- Распечатывает в журнал данные ячеек таблицы
   void              Print(const uint indent=0)
                       {
                        //--- Печатаем в журнал заголовок
                        ::PrintFormat("Table: Rows: %lu, Columns: %lu",this.RowsTotal(),this.ColumnsTotal());
                        //--- В цикле по строкам таблицы
                        for(int r=0;r<this.RowsTotal();r++)
                           //--- в цикле по ячейкам очередной строки
                           for(int c=0;c<this.ColumnsTotal();c++)
                             {
                              //--- получаем указатель на очередную ячейку и выводим в журнал её данные
                              CTableCell *cell=this.GetCell(r,c);
                              if(cell!=NULL)
                                 ::PrintFormat("%*s%-5s %-4lu %-8s %-6lu %-8s %-6lu %-8s %-4lu",indent,"","Row",r,"Column",c,"Cell X:",cell.X(),"Cell Y:",cell.Y());
                             }
                       }
//--- Конструктор/деструктор
                     CTableData(void)  { this.m_list_rows.Clear();   }
                    ~CTableData(void)  { this.m_list_rows.Clear();   }
  };
//+------------------------------------------------------------------+
//--- enums
enum ENUM_MOUSE_STATE
  {
   MOUSE_STATE_NOT_PRESSED,
   MOUSE_STATE_PRESSED_OUTSIDE_WINDOW,
   MOUSE_STATE_PRESSED_INSIDE_WINDOW,
   MOUSE_STATE_PRESSED_INSIDE_HEADER,
   MOUSE_STATE_PRESSED_INSIDE_CLOSE,
   MOUSE_STATE_PRESSED_INSIDE_MINIMIZE,
   MOUSE_STATE_PRESSED_INSIDE_PIN,
   MOUSE_STATE_OUTSIDE_WINDOW,
   MOUSE_STATE_INSIDE_WINDOW,
   MOUSE_STATE_INSIDE_HEADER,
   MOUSE_STATE_INSIDE_CLOSE,
   MOUSE_STATE_INSIDE_MINIMIZE,
   MOUSE_STATE_INSIDE_PIN
  };
//+------------------------------------------------------------------+
//| Класс Dashboard                                                  |
//+------------------------------------------------------------------+
class CDashboard : public CObject
  {
private:
   CCanvas           m_canvas;                  // Канвас
   CCanvas           m_workspace;               // Рабочая область
   CTableData        m_table_data;              // Массив ячеек таблиц
   ENUM_PROGRAM_TYPE m_program_type;            // Тип программы
   ENUM_MOUSE_STATE  m_mouse_state;             // Состояние кнопок мышки
   uint              m_id;                      // Идентификатор объекта
   long              m_chart_id;                // ChartID
   int               m_chart_w;                 // Ширина графика
   int               m_chart_h;                 // Высота графика
   int               m_x;                       // Координата X
   int               m_y;                       // Координата Y
   int               m_w;                       // Ширина
   int               m_h;                       // Высота
   int               m_x_dock;                  // Координата X закреплённой свёрнутой панели
   int               m_y_dock;                  // Координата Y закреплённой свёрнутой панели
   
   bool              m_header;                  // Флаг наличия заголовка
   bool              m_butt_close;              // Флаг наличия кнопки закрытия
   bool              m_butt_minimize;           // Флаг наличия кнопки сворачивания/разворачивания
   bool              m_butt_pin;                // Флаг наличия кнопки закрепления
   bool              m_wider_wnd;               // Флаг превышения горизонтального размера панели ширины окна
   bool              m_higher_wnd;              // Флаг превышения вертикольного размера панели высоты окна
   bool              m_movable;                 // Флаг перемещаемости панели
   int               m_header_h;                // Высота заголовка
   int               m_wnd;                     // Номер подокна графика
   
   uchar             m_header_alpha;            // Прозрачность заголовка
   uchar             m_header_alpha_c;          // Текущая прозрачность заголовка
   color             m_header_back_color;       // Цвет фона заголовка
   color             m_header_back_color_c;     // Текущий цвет фона заголовка
   color             m_header_fore_color;       // Цвет текста заголовка
   color             m_header_fore_color_c;     // Текущий цвет текста заголовка
   color             m_header_border_color;     // Цвет рамки заголовка
   color             m_header_border_color_c;   // Текущий цвет рамки заголовка
   
   color             m_butt_close_back_color;   // Цвет фона кнопки закрытия
   color             m_butt_close_back_color_c; // Текущий цвет фона кнопки закрытия
   color             m_butt_close_fore_color;   // Цвет значка кнопки закрытия
   color             m_butt_close_fore_color_c; // Текущий цвет значка кнопки закрытия
   
   color             m_butt_min_back_color;     // Цвет фона кнопки сворачивания/разворачивания
   color             m_butt_min_back_color_c;   // Текущий цвет фона кнопки сворачивания/разворачивания
   color             m_butt_min_fore_color;     // Цвет значка кнопки сворачивания/разворачивания
   color             m_butt_min_fore_color_c;   // Текущий цвет значка кнопки сворачивания/разворачивания
   
   color             m_butt_pin_back_color;     // Цвет фона кнопки закрепления
   color             m_butt_pin_back_color_c;   // Текущий цвет фона кнопки закрепления
   color             m_butt_pin_fore_color;     // Цвет значка кнопки закрепления
   color             m_butt_pin_fore_color_c;   // Текущий цвет значка кнопки закрепления
   
   uchar             m_alpha;                   // Прозрачность панели
   uchar             m_alpha_c;                 // Текущая прозрачность панели
   uchar             m_fore_alpha;              // Прозрачность текста
   uchar             m_fore_alpha_c;            // Текущая прозрачность текста
   color             m_back_color;              // Цвет фона
   color             m_back_color_c;            // Текущий цвет фона
   color             m_fore_color;              // Цвет текста
   color             m_fore_color_c;            // Текущий цвет текста
   color             m_border_color;            // Цвет рамки
   color             m_border_color_c;          // Текущий цвет рамки
   
   string            m_title;                   // Текст заголовка
   string            m_title_font;              // Фонт заголовка
   int               m_title_font_size;         // Размер шрифта заголовка
   string            m_font;                    // Фонт
   int               m_font_size;               // Размер шрифта
   
   bool              m_minimized;               // Флаг свёрнутого окна панели
   string            m_program_name;            // Имя программы
   string            m_name_gv_x;               // Наименование глобальной переменной терминала, хранящей координату X
   string            m_name_gv_y;               // Наименование глобальной переменной терминала, хранящей координату Y
   string            m_name_gv_m;               // Наименование глобальной переменной терминала, хранящей флаг свёрнутости панели
   string            m_name_gv_u;               // Наименование глобальной переменной терминала, хранящей флаг закреплённой панели

   uint              m_array_wpx[];             // Массив пикселей для сохранения/восстановления рабочей области
   uint              m_array_ppx[];             // Массив пикселей для сохранения/восстановления фона панели

//--- Возвращает флаг превышения (1) высотой, (2) шириной панели соответствующих размеров графика
   bool              HigherWnd(void)      const { return(this.m_h+2>this.m_chart_h);   }
   bool              WiderWnd(void)       const { return(this.m_w+2>this.m_chart_w);   }
//--- Включает/выключает режимы работы с графиком
   void              SetChartsTool(const bool flag);
   
//--- Сохраняет (1) рабочую область, (2) фон панели в массив пикселей
   void              SaveWorkspace(void);
   void              SaveBackground(void);
//--- Восстанавливает (1) рабочую область, (2) фон панели из массива пикселей
   void              RestoreWorkspace(void);
   void              RestoreBackground(void);

//--- Сохраняет массив пикселей (1) рабочей области, (2) фона панели в файл
   bool              FileSaveWorkspace(void);
   bool              FileSaveBackground(void);
//--- Загружает массив пикселей (1) рабочей области, (2) фона панели из файла
   bool              FileLoadWorkspace(void);
   bool              FileLoadBackground(void);

//--- Возвращает номер подокна
   int               GetSubWindow(void) const
                       {
                        return(this.m_program_type==PROGRAM_EXPERT || this.m_program_type==PROGRAM_SCRIPT ? 0 : ::ChartWindowFind());
                       }
   
protected:
//--- (1) Скрывает, (2) показывает, (3) переносит на передний план панель
   void              Hide(const bool redraw=false);
   void              Show(const bool redraw=false);
   void              BringToTop(void);
//--- Возвращает идентификатор графика
   long              ChartID(void)        const { return this.m_chart_id;              }
//--- Рисует область заголовка
   void              DrawHeaderArea(const string title);
//--- Перерисовывает область заголовка с новыми значениями цвета и текста
   void              RedrawHeaderArea(const color new_color=clrNONE,const string title="",const color title_new_color=clrNONE,const ushort new_alpha=USHORT_MAX);
//--- Рисует рамку панели
   void              DrawFrame(void);
//--- (1) Рисует, (2) перерисовывает кнопку закрытия панели
   void              DrawButtonClose(void);
   void              RedrawButtonClose(const color new_back_color=clrNONE,const color new_fore_color=clrNONE,const ushort new_alpha=USHORT_MAX);
//--- (1) Рисует, (2) перерисовывает кнопку сворачивания/разворачивания панели
   void              DrawButtonMinimize(void);
   void              RedrawButtonMinimize(const color new_back_color=clrNONE,const color new_fore_color=clrNONE,const ushort new_alpha=USHORT_MAX);
//--- (1) Рисует, (2) перерисовывает кнопку закрепления панели
   void              DrawButtonPin(void);
   void              RedrawButtonPin(const color new_back_color=clrNONE,const color new_fore_color=clrNONE,const ushort new_alpha=USHORT_MAX);

//--- Возвращает флаг работы в визуальном тестере
   bool              IsVisualMode(void) const
                       { return (bool)::MQLInfoInteger(MQL_VISUAL_MODE);               }
//--- Возвращает описание таймфрейма
   string            TimeframeDescription(const ENUM_TIMEFRAMES timeframe) const
                       { return ::StringSubstr(EnumToString(timeframe),7);             }

//--- Возвращает состояние кнопок мышки
   ENUM_MOUSE_STATE  MouseButtonState(const int x,const int y,bool pressed);
//--- Смещает панель на новые координаты
   void              Move(int x,int y);

//--- Преобразует RGB в color
   color             RGBToColor(const double r,const double g,const double b) const;
//--- Записывает в переменные значения компонентов RGB
   void              ColorToRGB(const color clr,double &r,double &g,double &b);
//--- Возвращает составляющую цвета (1) Red, (2) Green, (3) Blue
   double            GetR(const color clr)      { return clr&0xff ;                    }
   double            GetG(const color clr)      { return(clr>>8)&0xff;                 }
   double            GetB(const color clr)      { return(clr>>16)&0xff;                }
//--- Возвращает новый цвет
   color             NewColor(color base_color, int shift_red, int shift_green, int shift_blue);

//--- Рисует панель
   void              Draw(const string title);
//--- (1) Сворачивает, (2) разворачивает панель
   void              Collapse(void);
   void              Expand(void);

//--- Устанавливает координату (1) X, (2) Y панели
   bool              SetCoordX(const int coord_x);
   bool              SetCoordY(const int coord_y);
//--- Устанавливает (1) ширину, (2) высоту панели
   bool              SetWidth(const int width,const bool redraw=false);
   bool              SetHeight(const int height,const bool redraw=false);

public:
//--- Отображает панель
   void              View(const string title)   { this.Draw(title);                    }
//--- Возвращает объект (1) CCanvas, (2) рабочую область, (3) идентификатор объекта
   CCanvas          *Canvas(void)               { return &this.m_canvas;               }
   CCanvas          *Workspace(void)            { return &this.m_workspace;            }
   uint              ID(void)                   { return this.m_id;                    }
   
//--- Возвращает координату (1) X, (2) Y панели
   int               CoordX(void)         const { return this.m_x;                     }
   int               CoordY(void)         const { return this.m_y;                     }
//--- Возвращает (1) ширину, (2) высоту панели
   int               Width(void)          const { return this.m_w;                     }
   int               Height(void)         const { return this.m_h;                     }

//--- Возвращает (1) ширину, (2) высоту, (3) размеры указанного текста
   int               TextWidth(const string text)
                       { return this.m_workspace.TextWidth(text);                      }
   int               TextHeight(const string text)
                       { return this.m_workspace.TextHeight(text);                     }
   void              TextSize(const string text,int &width,int &height)
                       { this.m_workspace.TextSize(text,width,height);                 }
   
//--- Устанавливает флаг (1) наличия, (2) отсутствия кнопки закрытия
   void              SetButtonCloseOn(void);
   void              SetButtonCloseOff(void);
//--- Устанавливает флаг (1) наличия, (2) отсутствия кнопки сворачивания/разворачивания
   void              SetButtonMinimizeOn(void);
   void              SetButtonMinimizeOff(void);
   
//--- Устанавливает координаты панели
   bool              SetCoords(const int x,const int y);
//--- Устанавливает размеры панели
   bool              SetSizes(const int w,const int h,const bool update=false);
//--- Устанавливает координаты и размеры панели
   bool              SetParams(const int x,const int y,const int w,const int h,const bool update=false);

//--- Устанавливает прозрачность (1) заголовка, (2) рабочей области панели
   void              SetHeaderTransparency(const uchar value);
   void              SetTransparency(const uchar value);
//--- Устанавливает параметры шрифта панели по умолчанию
   void              SetFontParams(const string name,const int size,const uint flags=0,const uint angle=0);
//--- Выводит текстовое сообщение в указанные координаты
   void              DrawText(const string text,const int x,const int y,const int width=WRONG_VALUE,const int height=WRONG_VALUE);
//--- Рисует (1) фоновую сетку, (2) с автоматическим размером ячеек
   void              DrawGrid(const uint x,const uint y,const uint rows,const uint columns,const uint row_size,const uint col_size,const color line_color=clrNONE,bool alternating_color=true);
   void              DrawGridAutoFill(const uint border,const uint rows,const uint columns,const color line_color=clrNONE,bool alternating_color=true);
//--- Распечатывает данные сетки (координаты пересечения линий)
   void              GridPrint(const uint indent=0)   { this.m_table_data.Print(indent);  }
//--- Записывает в переменные значения координат X и Y указанной ячейки таблицы
   void              CellXY(const uint row,const uint column, int &x, int &y) { this.m_table_data.CellXY(row,column,x,y);  }
//--- Возвращает координату (1) X, (2) Y указанной ячейки таблицы
   int               CellX(const uint row,const uint column)         { return this.m_table_data.CellX(row,column);         }
   int               CellY(const uint row,const uint column)         { return this.m_table_data.CellY(row,column);         }

//--- Обработчик событий
   void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
//--- Конструктор/Деструктор
                     CDashboard(const uint id,const int x,const int y, const int w,const int h,const int wnd=-1);
                    ~CDashboard();
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CDashboard::CDashboard(const uint id,const int x,const int y, const int w,const int h,const int wnd=-1) : 
                        m_id(id),
                        m_chart_id(::ChartID()),
                        m_program_type((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)),
                        m_program_name(::MQLInfoString(MQL_PROGRAM_NAME)),
                        m_wnd(wnd==-1 ? GetSubWindow() : wnd),
                        m_chart_w((int)::ChartGetInteger(m_chart_id,CHART_WIDTH_IN_PIXELS,m_wnd)),
                        m_chart_h((int)::ChartGetInteger(m_chart_id,CHART_HEIGHT_IN_PIXELS,m_wnd)),
                        m_mouse_state(MOUSE_STATE_NOT_PRESSED),
                        m_x(x),
                        m_y(::ChartGetInteger(m_chart_id,CHART_SHOW_ONE_CLICK) ? (y<79 ? 79 : y) : y),
                        m_w(w),
                        m_h(h),
                        m_x_dock(m_x),
                        m_y_dock(m_y),
                        m_header(true),
                        m_butt_close(true),
                        m_butt_minimize(true),
                        m_butt_pin(true),
                        m_header_h(18),
                        
                        //--- Оформление заголовка панели
                        m_header_alpha(128),
                        m_header_alpha_c(m_header_alpha),
                        m_header_back_color(C'0,153,188'),
                        m_header_back_color_c(m_header_back_color),
                        m_header_fore_color(C'182,255,244'),
                        m_header_fore_color_c(m_header_fore_color),
                        m_header_border_color(C'167,167,168'),
                        m_header_border_color_c(m_header_border_color),
                        m_title("Dashboard"),
                        m_title_font("Calibri"),
                        m_title_font_size(-100),
                        
                        //--- кнопка закрытия
                        m_butt_close_back_color(C'0,153,188'),
                        m_butt_close_back_color_c(m_butt_close_back_color),
                        m_butt_close_fore_color(clrWhite),
                        m_butt_close_fore_color_c(m_butt_close_fore_color),
                        
                        //--- кнопка сворачивания/разворачивания
                        m_butt_min_back_color(C'0,153,188'),
                        m_butt_min_back_color_c(m_butt_min_back_color),
                        m_butt_min_fore_color(clrWhite),
                        m_butt_min_fore_color_c(m_butt_min_fore_color),
                        
                        //--- кнопка закрепления
                        m_butt_pin_back_color(C'0,153,188'),
                        m_butt_pin_back_color_c(m_butt_min_back_color),
                        m_butt_pin_fore_color(clrWhite),
                        m_butt_pin_fore_color_c(m_butt_min_fore_color),
                        
                        //--- Оформление панели
                        m_alpha(240),
                        m_alpha_c(m_alpha),
                        m_fore_alpha(255),
                        m_fore_alpha_c(m_fore_alpha),
                        m_back_color(C'240,240,240'),
                        m_back_color_c(m_back_color),
                        m_fore_color(C'53,0,0'),
                        m_fore_color_c(m_fore_color),
                        m_border_color(C'167,167,168'),
                        m_border_color_c(m_border_color),
                        m_font("Calibri"),
                        m_font_size(-100),
                        
                        m_minimized(false),
                        m_movable(true)
  {
//--- Устанавливаем для графика разрешения на отправку сообщений о событиях перемещения и нажатия кнопок мышки,
//--- о событиях колёсика мышки и событиях создания и удаления графического объекта
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_MOUSE_MOVE,true);
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_MOUSE_WHEEL,true);
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_OBJECT_CREATE,true);
   ::ChartSetInteger(this.m_chart_id,CHART_EVENT_OBJECT_DELETE,true);
   
//--- Задаём имена глобальным переменным терминала для хранения координат панели, состояния свёрнуто/развернуто и закрепления
   this.m_name_gv_x=this.m_program_name+"_id_"+(string)this.m_id+"_"+(string)this.m_chart_id+"_X";
   this.m_name_gv_y=this.m_program_name+"_id_"+(string)this.m_id+"_"+(string)this.m_chart_id+"_Y";
   this.m_name_gv_m=this.m_program_name+"_id_"+(string)this.m_id+"_"+(string)this.m_chart_id+"_Minimize";
   this.m_name_gv_u=this.m_program_name+"_id_"+(string)this.m_id+"_"+(string)this.m_chart_id+"_Unpin";
   
//--- Если глобальной переменной не существует - создаём её и записываем текущее значение,
//--- иначе - считываем в неё значение из глобальной переменной терминала
//--- Координата X
   if(!::GlobalVariableCheck(this.m_name_gv_x))
      ::GlobalVariableSet(this.m_name_gv_x,this.m_x);
   else
      this.m_x=(int)::GlobalVariableGet(this.m_name_gv_x);
//--- Координата Y
   if(!::GlobalVariableCheck(this.m_name_gv_y))
      ::GlobalVariableSet(this.m_name_gv_y,this.m_y);
   else
      this.m_y=(int)::GlobalVariableGet(this.m_name_gv_y);
//--- Свёрнуто/развёрнуто
   if(!::GlobalVariableCheck(this.m_name_gv_m))
      ::GlobalVariableSet(this.m_name_gv_m,this.m_minimized);
   else
      this.m_minimized=(int)::GlobalVariableGet(this.m_name_gv_m);
//--- Закреплено/не закреплено
   if(!::GlobalVariableCheck(this.m_name_gv_u))
      ::GlobalVariableSet(this.m_name_gv_u,this.m_movable);
   else
      this.m_movable=(int)::GlobalVariableGet(this.m_name_gv_u);

//--- Устанавливаем флаги превышения размерами панели размеров окна графика
   this.m_higher_wnd=this.HigherWnd();
   this.m_wider_wnd=this.WiderWnd();

//--- Если графический ресурс панели создан,
   if(this.m_canvas.CreateBitmapLabel(this.m_chart_id,this.m_wnd,"P"+(string)this.m_id,this.m_x,this.m_y,this.m_w,this.m_h,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      //--- устанавливаем для канваса шрифт и заполняем канвас прозрачным цветом
      this.m_canvas.FontSet(this.m_title_font,this.m_title_font_size,FW_BOLD);
      this.m_canvas.Erase(0x00FFFFFF);
     }
//--- иначе - сообщаем о неудачном создании объекта в журнал
   else
      ::PrintFormat("%s: Error. CreateBitmapLabel for canvas failed",(string)__FUNCTION__);

//--- Если графический ресурс рабочей области создан,
   if(this.m_workspace.CreateBitmapLabel(this.m_chart_id,this.m_wnd,"W"+(string)this.m_id,this.m_x+1,this.m_y+this.m_header_h,this.m_w-2,this.m_h-this.m_header_h-1,COLOR_FORMAT_ARGB_NORMALIZE))
     {
      //--- устанавливаем для рабочей области шрифт и заполняем рабочую область прозрачным цветом
      this.m_workspace.FontSet(this.m_font,this.m_font_size);
      this.m_workspace.Erase(0x00FFFFFF);
     }
//--- иначе - сообщаем о неудачном создании объекта в журнал
   else
      ::PrintFormat("%s: Error. CreateBitmapLabel for workspace failed",(string)__FUNCTION__);
  }
//+------------------------------------------------------------------+
//| Деструктор                                                       |
//+------------------------------------------------------------------+
CDashboard::~CDashboard()
  {
//--- Записываем текущие значения в глобальные переменные терминала
   ::GlobalVariableSet(this.m_name_gv_x,this.m_x);
   ::GlobalVariableSet(this.m_name_gv_y,this.m_y);
   ::GlobalVariableSet(this.m_name_gv_m,this.m_minimized);
   ::GlobalVariableSet(this.m_name_gv_u,this.m_movable);
//--- Удаляем объекты панели
   this.m_canvas.Destroy();
   this.m_workspace.Destroy();
  }
//+------------------------------------------------------------------+
//| Возвращает состояние курсора и кнопки мыши                       |
//+------------------------------------------------------------------+
ENUM_MOUSE_STATE CDashboard::MouseButtonState(const int x,const int y,bool pressed)
  {
//--- Если кнопка нажата
   if(pressed)
     {
      //--- Если уже зафиксировано состояние - уходим
      if(this.m_mouse_state!=MOUSE_STATE_NOT_PRESSED)
         return this.m_mouse_state;
      //--- Если нажата кнопка внутри окна
      if(x>this.m_x && x<this.m_x+this.m_w && y>this.m_y && y<this.m_y+this.m_h)
        {
         //--- Если нажата кнопка внутри заголовка
         if(y>this.m_y && y<=this.m_y+this.m_header_h)
           {
            //--- Выводим панель на передний план
            this.BringToTop();
            //--- Координаты кнопок закрытия, сворачивания/разворачивания и закрепления
            int wc=(this.m_butt_close ? this.m_header_h : 0);
            int wm=(this.m_butt_minimize ? this.m_header_h : 0);
            int wp=(this.m_butt_pin ? this.m_header_h : 0);
            //--- Если нажата кнопка закрытия - возвращаем это состояние
            if(x>this.m_x+this.m_w-wc)
               return MOUSE_STATE_PRESSED_INSIDE_CLOSE;
            //--- Если нажата кнопка сворачивания/разворачивания - возвращаем это состояние
            if(x>this.m_x+this.m_w-wc-wm)
               return MOUSE_STATE_PRESSED_INSIDE_MINIMIZE;
            //--- Если нажата кнопка закрепления - возвращаем это состояние
            if(x>this.m_x+this.m_w-wc-wm-wp)
               return MOUSE_STATE_PRESSED_INSIDE_PIN;
            //--- Если кнопка нажата не на управляющих кнопках панели - записываем и возвращаем состояние нажатия кнопки внутри заголовка
            this.m_mouse_state=MOUSE_STATE_PRESSED_INSIDE_HEADER;
            return this.m_mouse_state;
           }
         //--- Если нажата кнопка внутри окна - записываем состояние в переменную и возвращаем это состояние
         else if(y>this.m_y+this.m_header_h && y<this.m_y+this.m_h)
           {
            this.m_mouse_state=MOUSE_STATE_PRESSED_INSIDE_WINDOW;
            return this.m_mouse_state;
           }
        }
      //--- Кнопка нажата вне пределов окна - записываем состояние в переменную и возвращаем это состояние
      else
        {
         this.m_mouse_state=MOUSE_STATE_PRESSED_OUTSIDE_WINDOW;
         return this.m_mouse_state;
        }
     }
//--- Если кнопка не нажата
   else
     {
      //--- Записываем в переменную состояние не нажатой кнопки
      this.m_mouse_state=MOUSE_STATE_NOT_PRESSED;
      //--- Если курсор внутри панели
      if(x>this.m_x && x<this.m_x+this.m_w && y>this.m_y && y<this.m_y+this.m_h)
        {
         //--- Если курсор внутри заголовка
         if(y>this.m_y && y<=this.m_y+this.m_header_h)
           {
            //--- Указываем ширину кнопок закрытия, сворачивания/разворачивания и закрепления
            int wc=(this.m_butt_close ? this.m_header_h : 0);
            int wm=(this.m_butt_minimize ? this.m_header_h : 0);
            int wp=(this.m_butt_pin ? this.m_header_h : 0);
            //--- Если курсор внутри кнопки закрытия - возвращаем это состояние
            if(x>this.m_x+this.m_w-wc)
               return MOUSE_STATE_INSIDE_CLOSE;
            //--- Если курсор внутри кнопки сворачивания/разворачивания - возвращаем это состояние
            if(x>this.m_x+this.m_w-wc-wm)
               return MOUSE_STATE_INSIDE_MINIMIZE;
            //--- Если курсор внутри кнопки закрепления - возвращаем это состояние
            if(x>this.m_x+this.m_w-wc-wm-wp)
               return MOUSE_STATE_INSIDE_PIN;
            //--- Если курсор за пределами кнопок внутри области заголовка - возвращаем это состояние
            return MOUSE_STATE_INSIDE_HEADER;
           }
         //--- Иначе - Курсор внутри рабочей области - возвращаем это состояние
         else
            return MOUSE_STATE_INSIDE_WINDOW;
        }
     }
//--- В любом ином случае возвращаем состояние не нажатой кнопки мышки
   return MOUSE_STATE_NOT_PRESSED;
  }
//+------------------------------------------------------------------+
//| Обработчик событий                                               |
//+------------------------------------------------------------------+
void CDashboard::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Если создан графический  объект
   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      this.BringToTop();
      ::ObjectSetInteger(this.m_chart_id,sparam,OBJPROP_SELECTED,true);
     }
//--- Если график изменён
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      //--- Получаем номер подокна графика (он может измениться при удалении окна какого-либо индикатора)
      this.m_wnd=this.GetSubWindow();
      //--- Получаем новые размеры графика
      int w=(int)::ChartGetInteger(this.m_chart_id,CHART_WIDTH_IN_PIXELS,this.m_wnd);
      int h=(int)::ChartGetInteger(this.m_chart_id,CHART_HEIGHT_IN_PIXELS,this.m_wnd);
      //--- Определяем выход размеров панели за пределы окна графика
      this.m_higher_wnd=this.HigherWnd();
      this.m_wider_wnd=this.WiderWnd();
      //--- Если высота графика изменилась - корректируем расположение панели по вертикали
      if(this.m_chart_h!=h)
        {
         this.m_chart_h=h;
         int y=this.m_y;
         if(this.m_y+this.m_h>h-1)
            y=h-this.m_h-1;
         if(y<1)
            y=1;
         this.Move(this.m_x,y);
        }
      //--- Если ширина графика изменилась - корректируем расположение панели по горизонтали
      if(this.m_chart_w!=w)
        {
         this.m_chart_w=w;
         int x=this.m_x;
         if(this.m_x+this.m_w>w-1)
            x=w-this.m_w-1;
         if(x<1)
            x=1;
         this.Move(x,this.m_y);
        }
     }

//--- Объявляем переменные для хранения текущего смещения курсора относительно начальных координат панели
   static int diff_x=0;
   static int diff_y=0;
   
//--- Получаем флаг удерживаемой кнопки мышки. Для визуального тестера правую кнопку тоже учитываем (sparam=="2")
   bool pressed=(!this.IsVisualMode() ? (sparam=="1" || sparam=="" ? true : false) : sparam=="1" || sparam=="2" ? true : false);
//--- Получаем координаты X и Y курсора. Для координаты Y учитываем смещение при работе в подокне графика
   int  mouse_x=(int)lparam;
   int  mouse_y=(int)dparam-(int)::ChartGetInteger(this.m_chart_id,CHART_WINDOW_YDISTANCE,this.m_wnd);
//--- Получаем состояние курсора и кнопок мышки относительно панели
   ENUM_MOUSE_STATE state=this.MouseButtonState(mouse_x,mouse_y,pressed);
//--- Если курсор перемещается
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Если нажата кнопка внутри рабочей области панели
      if(state==MOUSE_STATE_PRESSED_INSIDE_WINDOW)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки мышки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем область заголовка с цветом фона по умолчанию
         if(this.m_header_back_color_c!=this.m_header_back_color)
           {
            this.RedrawHeaderArea(this.m_header_back_color);
            this.m_canvas.Update();
           }
         return;
        }
      //--- Если нажата кнопка внутри области заголовка панели
      else if(state==MOUSE_STATE_PRESSED_INSIDE_HEADER)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки мышки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем область заголовка с новым цветом фона
         color new_color=this.NewColor(this.m_header_back_color,-10,-10,-10);
         if(this.m_header_back_color_c!=new_color)
           {
            this.RedrawHeaderArea(new_color);
            this.m_canvas.Update();
           }
         //--- Смещаем панель вслед за курсором с учётом величины смещения курсора относительно начальных координат панели
         if(this.m_movable)
            this.Move(mouse_x-diff_x,mouse_y-diff_y);
         return;
        }
        
      //--- Если нажата кнопка закрытия
      else if(state==MOUSE_STATE_PRESSED_INSIDE_CLOSE)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем кнопку закрытия с новым цветом фона
         color new_color=this.NewColor(clrRed,0,40,40);
         if(this.m_butt_close_back_color_c!=new_color)
           {
            this.RedrawButtonClose(new_color);
            this.m_canvas.Update();
           }
         //--- Обработка нажатия кнопки закрытия должна определяться в программе.
         //--- Отправим в её обработчик OnChartEvent событие нажатия этой кнопки.
         //--- Идентификатор события 1001,
         //--- lparam=идентификатор панели (m_id),
         //--- dparam=0
         //--- sparam="Close button pressed"
         ushort event=CHARTEVENT_CUSTOM+1;
         ::EventChartCustom(this.m_chart_id,ushort(event-CHARTEVENT_CUSTOM),this.m_id,0,"Close button pressed");
        }
      //--- Если нажата кнопка сворачивания/разворачивания панели
      else if(state==MOUSE_STATE_PRESSED_INSIDE_MINIMIZE)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- "переворачиваем" флаг свёрнутости панели,
         this.m_minimized=!this.m_minimized;
         //--- перерисовываем панель с учётом нового состояния флага,
         this.Draw(this.m_title);
         //--- перерисовываем область заголовка панели
         this.RedrawHeaderArea();
         //--- Если панель закреплена и развёрнута - переместим её в запомненные координаты расположения
         if(this.m_minimized && !this.m_movable)
            this.Move(this.m_x_dock,this.m_y_dock);
         //--- Обновляем канвас с перерисовкой графика и
         this.m_canvas.Update();
         //--- записываем в глобальную переменную терминала состояние флага свёрнутости панели
         ::GlobalVariableSet(this.m_name_gv_m,this.m_minimized);
        }
      //--- Если нажата кнопка закрепления панели
      else if(state==MOUSE_STATE_PRESSED_INSIDE_PIN)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- "переворачиваем" флаг свёрнутости панели,
         this.m_movable=!this.m_movable;
         //--- Перерисовываем кнопку закрепления с новым цветом фона
         color new_color=this.NewColor(this.m_butt_pin_back_color,30,30,30);
         if(this.m_butt_pin_back_color_c!=new_color)
            this.RedrawButtonPin(new_color);
         //--- Если панель свёрнута и закреплена - запомним её координаты
         //--- При разворачивании и повторном сворачивании панель вернётся на эти координаты
         //--- Актуально для закрепления свёрнутой панели внизу экрана
         if(this.m_minimized && !this.m_movable)
           {
            this.m_x_dock=this.m_x;
            this.m_y_dock=this.m_y;
           }
         //--- Обновляем канвас с перерисовкой графика и
         this.m_canvas.Update();
         //--- записываем в глобальную переменную терминала состояние флага перемещаемости панели
         ::GlobalVariableSet(this.m_name_gv_u,this.m_movable);
        }
        
      //--- Если курсор находится внутри области заголовка панели
      else if(state==MOUSE_STATE_INSIDE_HEADER)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем область заголовка с новым цветом фона
         color new_color=this.NewColor(this.m_header_back_color,20,20,20);
         if(this.m_header_back_color_c!=new_color)
           {
            this.RedrawHeaderArea(new_color);
            this.m_canvas.Update();
           }
        }
        
      //--- Если курсор находится внутри кнопки закрытия
      else if(state==MOUSE_STATE_INSIDE_CLOSE)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем область заголовка с минимальным изменением цвета фона
         color new_color=this.NewColor(this.m_header_back_color,0,0,1);
         if(this.m_header_back_color_c!=new_color)
            this.RedrawHeaderArea(new_color);
         //--- Перерисовываем кнопку сворачивания/разворачивания с цветом фона по умолчанию
         if(this.m_butt_min_back_color_c!=this.m_butt_min_back_color)
            this.RedrawButtonMinimize(this.m_butt_min_back_color);
         //--- Перерисовываем кнопку закрепления с цветом фона по умолчанию
         if(this.m_butt_pin_back_color_c!=this.m_butt_pin_back_color)
            this.RedrawButtonPin(this.m_butt_pin_back_color);
         //--- Перерисовываем кнопку закрытия с красным цветом фона
         if(this.m_butt_close_back_color_c!=clrRed)
           {
            this.RedrawButtonClose(clrRed);
            this.m_canvas.Update();
           }
        }
        
      //--- Если курсор находится внутри кнопки сворачивания/разворачивания
      else if(state==MOUSE_STATE_INSIDE_MINIMIZE)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем область заголовка с минимальным изменением цвета фона
         color new_color=this.NewColor(this.m_header_back_color,0,0,1);
         if(this.m_header_back_color_c!=new_color)
            this.RedrawHeaderArea(new_color);
         //--- Перерисовываем кнопку закрытия с цветом фона по умолчанию
         if(this.m_butt_close_back_color_c!=this.m_butt_close_back_color)
            this.RedrawButtonClose(this.m_butt_close_back_color);
         //--- Перерисовываем кнопку закрепления с цветом фона по умолчанию
         if(this.m_butt_pin_back_color_c!=this.m_butt_pin_back_color)
            this.RedrawButtonPin(this.m_butt_pin_back_color);
         //--- Перерисовываем кнопку сворачивания/разворачивания с новым цветом фона
         new_color=this.NewColor(this.m_butt_min_back_color,20,20,20);
         if(this.m_butt_min_back_color_c!=new_color)
           {
            this.RedrawButtonMinimize(new_color);
            this.m_canvas.Update();
           }
        }
        
      //--- Если курсор находится внутри кнопки закрепления
      else if(state==MOUSE_STATE_INSIDE_PIN)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем область заголовка с минимальным изменением цвета фона
         color new_color=this.NewColor(this.m_header_back_color,0,0,1);
         if(this.m_header_back_color_c!=new_color)
            this.RedrawHeaderArea(new_color);
         //--- Перерисовываем кнопку закрытия с цветом фона по умолчанию
         if(this.m_butt_close_back_color_c!=this.m_butt_close_back_color)
            this.RedrawButtonClose(this.m_butt_close_back_color);
         //--- Перерисовываем кнопку сворачивания/разворачивания с цветом фона по умолчанию
         if(this.m_butt_min_back_color_c!=this.m_butt_min_back_color)
            this.RedrawButtonMinimize(this.m_butt_min_back_color);
         //--- Перерисовываем кнопку закрепления с новым цветом фона
         new_color=this.NewColor(this.m_butt_pin_back_color,20,20,20);
         if(this.m_butt_pin_back_color_c!=new_color)
           {
            this.RedrawButtonPin(new_color);
            this.m_canvas.Update();
           }
        }
        
      //--- Если курсор находится внутри рабочей области
      else if(state==MOUSE_STATE_INSIDE_WINDOW)
        {
         //--- Отключаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(false);
         //--- Перерисовываем область заголовка с цветом фона по умолчанию
         if(this.m_header_back_color_c!=this.m_header_back_color)
           {
            this.RedrawHeaderArea(this.m_header_back_color);
            this.m_canvas.Update();
           }
        }
      //--- Иначе (курсор за пределами панели, и нужно восстановить параметры графика)
      else
        {
         //--- Включаем прокрутку графика, меню правой кнопки и перекрестие
         this.SetChartsTool(true);
         //--- Перерисовываем область заголовка с цветом фона по умолчанию
         if(this.m_header_back_color_c!=this.m_header_back_color)
           {
            this.RedrawHeaderArea(this.m_header_back_color);
            this.m_canvas.Update();
           }
        }
      //--- Записываем смещение курсора по X и Y относительно начальных координат панели
      diff_x=mouse_x-this.m_x;
      diff_y=mouse_y-this.m_y;
     }
  }
//+------------------------------------------------------------------+
//| Перемещает панель                                                |
//+------------------------------------------------------------------+
void CDashboard::Move(int x,int y)
  {
   int h=this.m_canvas.Height();
   int w=this.m_canvas.Width();
   if(!this.m_wider_wnd)
     {
      if(x+w>this.m_chart_w-1)
         x=this.m_chart_w-w-1;
      if(x<1)
         x=1;
     }
   else
     {
      if(x>1)
         x=1;
      if(x<this.m_chart_w-w-1)
         x=this.m_chart_w-w-1;
     }
   if(!this.m_higher_wnd)
     {
      if(y+h>this.m_chart_h-2)
         y=this.m_chart_h-h-2;
      if(y<1)
         y=1;
     }
   else
     {
      if(y>1)
         y=1;
      if(y<this.m_chart_h-h-2)
         y=this.m_chart_h-h-2;
     }
   if(this.SetCoords(x,y))
      this.m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Устанавливает координату X панели                                |
//+------------------------------------------------------------------+
bool CDashboard::SetCoordX(const int coord_x)
  {
   int x=(int)::ObjectGetInteger(this.m_chart_id,this.m_canvas.ChartObjectName(),OBJPROP_XDISTANCE);
   if(x==coord_x)
      return true;
   if(!::ObjectSetInteger(this.m_chart_id,this.m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,coord_x))
      return false;
   if(!::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_XDISTANCE,coord_x+1))
      return false;
   this.m_x=coord_x;
   return true;
  }
//+------------------------------------------------------------------+
//| Устанавливает координату Y панели                                |
//+------------------------------------------------------------------+
bool CDashboard::SetCoordY(const int coord_y)
  {
   int y=(int)::ObjectGetInteger(this.m_chart_id,this.m_canvas.ChartObjectName(),OBJPROP_YDISTANCE);
   if(y==coord_y)
      return true;
   if(!::ObjectSetInteger(this.m_chart_id,this.m_canvas.ChartObjectName(),OBJPROP_YDISTANCE,coord_y))
      return false;
   if(!::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_YDISTANCE,coord_y+this.m_header_h))
      return false;
   this.m_y=coord_y;
   return true;
  }
//+------------------------------------------------------------------+
//| Устанавливает ширину панели                                      |
//+------------------------------------------------------------------+
bool CDashboard::SetWidth(const int width,const bool redraw=false)
  {
   if(width<4)
     {
      ::PrintFormat("%s: Error. Width cannot be less than 4px",(string)__FUNCTION__);
      return false;
     }
   if(width==this.m_canvas.Width())
      return true;
   if(!this.m_canvas.Resize(width,this.m_canvas.Height()))
      return false;
   if(width-2<1)
      ::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   else
     {
      ::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
      if(!this.m_workspace.Resize(width-2,this.m_workspace.Height()))
         return false;
     }
   this.m_w=width;
   return true;
  }
//+------------------------------------------------------------------+
//| Устанавливает высоту панели                                      |
//+------------------------------------------------------------------+
bool CDashboard::SetHeight(const int height,const bool redraw=false)
  {
   if(height<::fmax(this.m_header_h,1))
     {
      ::PrintFormat("%s: Error. Width cannot be less than %lupx",(string)__FUNCTION__,::fmax(this.m_header_h,1));
      return false;
     }
   if(height==this.m_canvas.Height())
      return true;
   if(!this.m_canvas.Resize(this.m_canvas.Width(),height))
      return false;
   if(height-this.m_header_h-2<1)
      ::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   else
     {
      ::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
      if(!this.m_workspace.Resize(this.m_workspace.Width(),height-this.m_header_h-2))
         return false;
     }
   this.m_h=height;
   return true;
  }
//+------------------------------------------------------------------+
//| Устанавливает координаты панели                                  |
//+------------------------------------------------------------------+
bool CDashboard::SetCoords(const int x,const int y)
  {
   bool res=true;
   res &=this.SetCoordX(x);
   res &=this.SetCoordY(y);
   return res;
  }
//+------------------------------+
//| Устанавливает размеры панели |
//+------------------------------+
bool CDashboard::SetSizes(const int w,const int h,const bool update=false)
  {
   bool res=true;
   res &=this.SetWidth(w);
   res &=this.SetHeight(h);
   if(res && update)
      this.Expand();
   return res;
  }
//+-------------------------------------------+
//| Устанавливает координаты и размеры панели |
//+-------------------------------------------+
bool CDashboard::SetParams(const int x,const int y,const int w,const int h,const bool update=false)
  {
   bool res=true;
   res &=this.SetCoords(x,y);
   res &=this.SetSizes(w,h);
   if(res && update)
      this.Expand();
   return res;
  }
//+--------------------------+
//| Рисует область заголовка |
//+--------------------------+
void CDashboard::DrawHeaderArea(const string title)
  {
//--- Если заголовок не используется - уходим
   if(!this.m_header)
      return;
//--- Устанавливаем текст заголовка
   this.m_title=title;
//--- Координата Y текста расположена по вертикали по центру области заголовка
   int y=this.m_header_h/2;
//--- Заполняем область цветом
   this.m_canvas.FillRectangle(0,0,this.m_w-1,this.m_header_h-1,::ColorToARGB(this.m_header_back_color,this.m_header_alpha));
//--- Выводим текст заголовка
   this.m_canvas.TextOut(2,y,this.m_title,::ColorToARGB(this.m_header_fore_color,this.m_header_alpha),TA_LEFT|TA_VCENTER);
//--- Запоминаем текущий цвет фона заголовка
   this.m_header_back_color_c=this.m_header_back_color;
//--- Рисуем управляющие элементы (кнопки закрытия, сворачивания/разворачивания и закрепления) и
   this.DrawButtonClose();
   this.DrawButtonMinimize();
   this.DrawButtonPin();
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(false);
  }
//+---------------------------------+
//| Перерисовывает область заголовка|
//+---------------------------------+
void CDashboard::RedrawHeaderArea(const color new_color=clrNONE,const string title="",const color title_new_color=clrNONE,const ushort new_alpha=USHORT_MAX)
  {
//--- Если заголовок не используется или все переданные параметры имеют значения по умолчанию - уходим
   if(!this.m_header || (new_color==clrNONE && title=="" && title_new_color==clrNONE && new_alpha==USHORT_MAX))
      return;
//--- Если все переданные параметры равны уже установленным - уходим
   if(new_color==this.m_header_back_color && title==this.m_title && title_new_color==this.m_header_fore_color && new_alpha==this.m_header_alpha)
      return;
//--- Если заголовок не равен значению по умолчанию - устанавливаем новый заголовок
   if(title!="")
      this.m_title=title;
//--- Определяем новые цвета фона и текста и прозрачность
   color back_clr=(new_color!=clrNONE ? new_color : this.m_header_back_color);
   color fore_clr=(title_new_color!=clrNONE ? title_new_color : this.m_header_fore_color);  
   uchar alpha=uchar(new_alpha==USHORT_MAX ? this.m_header_alpha : new_alpha>255 ? 255 : new_alpha);
//--- Координата Y текста расположена по вертикали по центру области заголовка
   int y=this.m_header_h/2;
//--- Заполняем область цветом
   this.m_canvas.FillRectangle(0,0,this.m_w-1,this.m_header_h-1,::ColorToARGB(back_clr,alpha));
//--- Выводим текст заголовка
   this.m_canvas.TextOut(2,y,this.m_title,::ColorToARGB(fore_clr,alpha),TA_LEFT|TA_VCENTER);
//--- Запоминаем текущий цвет фона заголовка, текста и прозрачность
   this.m_header_back_color_c=back_clr;
   this.m_header_fore_color_c=fore_clr;
   this.m_header_alpha_c=alpha;
//--- Рисуем управляющие элементы (кнопки закрытия, сворачивания/разворачивания и закрепления) и
   this.RedrawButtonClose(back_clr,clrNONE,alpha);
   this.RedrawButtonMinimize(back_clr,clrNONE,alpha);
   this.RedrawButtonPin(back_clr,clrNONE,alpha);
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(true);
  }
//+---------------------+
//| Рисует рамку панели |
//+---------------------+
void CDashboard::DrawFrame(void)
  {
   this.m_canvas.Rectangle(0,0,this.m_w-1,this.m_h-1,::ColorToARGB(this.m_border_color,this.m_alpha));
   this.m_border_color_c=this.m_border_color;
   this.m_canvas.Update(false);
  }
//+-------------------------------+
//| Рисует кнопку закрытия панели |
//+-------------------------------+
void CDashboard::DrawButtonClose(void)
  {
//--- Если кнопка не используется - уходим
   if(!this.m_butt_close)
      return;
//--- Ширина кнопки равна высоте области заголовка
   int w=this.m_header_h;
//--- Координаты и размеры кнопки
   int x1=this.m_w-w;
   int x2=this.m_w-1;
   int y1=0;
   int y2=w-1;
//--- Смещение левого верхнего угла прямоугольной области рисунка от левого верхнего угла кнопки
   int shift=4;
//--- Рисуем фон кнопки
   this.m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(this.m_butt_close_back_color,this.m_header_alpha));
//--- Рисуем "Крестик" закрытия
   this.m_canvas.LineThick(x1+shift+1,y1+shift+1,x2-shift,y2-shift,::ColorToARGB(this.m_butt_close_fore_color,255),3,STYLE_SOLID,LINE_END_ROUND);
   this.m_canvas.LineThick(x1+shift+1,y2-shift-1,x2-shift,y1+shift,::ColorToARGB(this.m_butt_close_fore_color,255),3,STYLE_SOLID,LINE_END_ROUND);
//--- Запоминаем текущий цвет фона и рисунка кнопки
   this.m_butt_close_back_color_c=this.m_butt_close_back_color;
   this.m_butt_close_fore_color_c=this.m_butt_close_fore_color;
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(false);
  }
//+---------------------------------------+
//| Перерисовывает кнопку закрытия панели |
//+----------------------------------------+
void CDashboard::RedrawButtonClose(const color new_back_color=clrNONE,const color new_fore_color=clrNONE,const ushort new_alpha=USHORT_MAX)
  {
//--- Если кнопка не используется или все переданные параметры имеют значения по умолчанию - уходим
   if(!this.m_butt_close || (new_back_color==clrNONE && new_fore_color==clrNONE && new_alpha==USHORT_MAX))
      return;
//--- Ширина кнопки равна высоте области заголовка
   int w=this.m_header_h;
//--- Координаты и размеры кнопки
   int x1=this.m_w-w;
   int x2=this.m_w-1;
   int y1=0;
   int y2=w-1;
//--- Смещение левого верхнего угла прямоугольной области рисунка от левого верхнего угла кнопки
   int shift=4;
//--- Определяем новые цвета фона и текста и прозрачность
   color back_color=(new_back_color!=clrNONE ? new_back_color : this.m_butt_close_back_color);
   color fore_color=(new_fore_color!=clrNONE ? new_fore_color : this.m_butt_close_fore_color);
   uchar alpha=uchar(new_alpha==USHORT_MAX ? this.m_header_alpha : new_alpha>255 ? 255 : new_alpha);
//--- Рисуем фон кнопки
   this.m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(back_color,alpha));
//--- Рисуем "Крестик" закрытия
   this.m_canvas.LineThick(x1+shift+1,y1+shift+1,x2-shift,y2-shift,::ColorToARGB(fore_color,255),3,STYLE_SOLID,LINE_END_ROUND);
   this.m_canvas.LineThick(x1+shift+1,y2-shift-1,x2-shift,y1+shift,::ColorToARGB(fore_color,255),3,STYLE_SOLID,LINE_END_ROUND);
//--- Запоминаем текущий цвет фона и рисунка кнопки
   this.m_butt_close_back_color_c=back_color;
   this.m_butt_close_fore_color_c=fore_color;
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(false);
  }
//+--------------------------------------------------+
//| Рисует кнопку сворачивания/разворачивания панели |
//+-------------------------------------------------+
void CDashboard::DrawButtonMinimize(void)
  {
//--- Если кнопка не используется - уходим
   if(!this.m_butt_minimize)
      return;
//--- Ширина кнопки равна высоте области заголовка
   int w=this.m_header_h;
//--- Ширина кнопки закрытия равна нулю, если кнопка не используется
   int wc=(this.m_butt_close ? w : 0);
//--- Координаты и размеры кнопки
   int x1=this.m_w-wc-w;
   int x2=this.m_w-wc-1;
   int y1=0;
   int y2=w-1;
//--- Смещение левого верхнего угла прямоугольной области рисунка от левого верхнего угла кнопки
   int shift=4;
//--- Рисуем фон кнопки
   this.m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(this.m_butt_min_back_color,this.m_header_alpha));
//--- Если панель свёрнута - рисуем прямоугольник
   if(this.m_minimized)
      this.m_canvas.Rectangle(x1+shift,y1+shift,x2-shift,y2-shift,::ColorToARGB(this.m_butt_min_fore_color,255));
//--- Иначе - панель развёрнута - рисуем отрезок линии
   else
      this.m_canvas.LineThick(x1+shift,y2-shift,x2-shift,y2-shift,::ColorToARGB(this.m_butt_min_fore_color,255),3,STYLE_SOLID,LINE_END_ROUND);
//--- Запоминаем текущий цвет фона и рисунка кнопки
   this.m_butt_min_back_color_c=this.m_butt_min_back_color;
   this.m_butt_min_fore_color_c=this.m_butt_min_fore_color;
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(false);
  }
//+------------------------------------------------------------------+
//| Перерисовывает кнопку сворачивания/разворачивания панели         |
//+------------------------------------------------------------------+
void CDashboard::RedrawButtonMinimize(const color new_back_color=clrNONE,const color new_fore_color=clrNONE,const ushort new_alpha=USHORT_MAX)
  {
//--- Если кнопка не используется или все переданные параметры имеют значения по умолчанию - уходим
   if(!this.m_butt_minimize || (new_back_color==clrNONE && new_fore_color==clrNONE && new_alpha==USHORT_MAX))
      return;
//--- Ширина кнопки равна высоте области заголовка
   int w=this.m_header_h;
//--- Ширина кнопки закрытия равна нулю, если кнопка не используется
   int wc=(this.m_butt_close ? w : 0);
//--- Координаты и размеры кнопки
   int x1=this.m_w-wc-w;
   int x2=this.m_w-wc-1;
   int y1=0;
   int y2=w-1;
//--- Смещение левого верхнего угла прямоугольной области рисунка от левого верхнего угла кнопки
   int shift=4;
//--- Определяем новые цвета фона и текста и прозрачность
   color back_color=(new_back_color!=clrNONE ? new_back_color : this.m_butt_min_back_color);
   color fore_color=(new_fore_color!=clrNONE ? new_fore_color : this.m_butt_min_fore_color);
   uchar alpha=uchar(new_alpha==USHORT_MAX ? this.m_header_alpha : new_alpha>255 ? 255 : new_alpha);
//--- Рисуем фон кнопки
   this.m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(back_color,alpha));
//--- Если панель свёрнута - рисуем прямоугольник
   if(this.m_minimized)
      this.m_canvas.Rectangle(x1+shift,y1+shift,x2-shift,y2-shift,::ColorToARGB(fore_color,255));
//--- Иначе - панель развёрнута - рисуем отрезок линии
   else
      this.m_canvas.LineThick(x1+shift,y2-shift,x2-shift,y2-shift,::ColorToARGB(fore_color,255),3,STYLE_SOLID,LINE_END_ROUND);
//--- Запоминаем текущий цвет фона и рисунка кнопки
   this.m_butt_min_back_color_c=back_color;
   this.m_butt_min_fore_color_c=fore_color;
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(false);
  }
//+----------------------------------+
//| Рисует кнопку закрепления панели |
//+----------------------------------+
void CDashboard::DrawButtonPin(void)
  {
//--- Если кнопка не используется - уходим
   if(!this.m_butt_pin)
      return;
//--- Ширина кнопки равна высоте области заголовка
   int w=this.m_header_h;
//--- Ширина кнопки закрытия и кнопки сворачивания равна нулю, если кнопка не используется
   int wc=(this.m_butt_close ? w : 0);
   int wm=(this.m_butt_minimize ? w : 0);
//--- Координаты и размеры кнопки
   int x1=this.m_w-wc-wm-w;
   int x2=this.m_w-wc-wm-1;
   int y1=0;
   int y2=w-1;
//--- Рисуем фон кнопки
   this.m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(this.m_butt_pin_back_color,this.m_header_alpha));
//--- Координаты точек ломаной линии
   int x[]={x1+3, x1+6, x1+3,x1+4,x1+6,x1+9,x1+9,x1+10,x1+15,x1+14,x1+13,x1+10,x1+10,x1+9,x1+6};
   int y[]={y1+14,y1+11,y1+8,y1+7,y1+7,y1+4,y1+3,y1+2, y1+7, y1+8, y1+8, y1+11,y1+13,y1+14,y1+11};
//--- Рисуем фигурку "кнопки" 
   this.m_canvas.Polygon(x,y,::ColorToARGB(this.m_butt_pin_fore_color,255));
//--- Если флаг перемещаемости сброшен (закреплено) - перечёркиваем нарисованную кнопку
   if(!this.m_movable)
      this.m_canvas.Line(x1+3,y1+2,x1+15,y1+14,::ColorToARGB(this.m_butt_pin_fore_color,255));
//--- Запоминаем текущий цвет фона и рисунка кнопки
   this.m_butt_pin_back_color_c=this.m_butt_pin_back_color;
   this.m_butt_pin_fore_color_c=this.m_butt_pin_fore_color;
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(false);
  }
//+------------------------------------------+
//| Перерисовывает кнопку закрепления панели |
//+-----------------------------------------+
void CDashboard::RedrawButtonPin(const color new_back_color=clrNONE,const color new_fore_color=clrNONE,const ushort new_alpha=USHORT_MAX)
  {
//--- Если кнопка не используется или все переданные параметры имеют значения по умолчанию - уходим
   if(!this.m_butt_pin || (new_back_color==clrNONE && new_fore_color==clrNONE && new_alpha==USHORT_MAX))
      return;
//--- Ширина кнопки равна высоте области заголовка
   int w=this.m_header_h;
//--- Ширина кнопки закрытия и кнопки сворачивания равна нулю, если кнопка не используется
   int wc=(this.m_butt_close ? w : 0);
   int wm=(this.m_butt_minimize ? w : 0);
//--- Координаты и размеры кнопки
   int x1=this.m_w-wc-wm-w;
   int x2=this.m_w-wc-wm-1;
   int y1=0;
   int y2=w-1;
//--- Определяем новые цвета фона и текста и прозрачность
   color back_color=(new_back_color!=clrNONE ? new_back_color : this.m_butt_pin_back_color);
   color fore_color=(new_fore_color!=clrNONE ? new_fore_color : this.m_butt_pin_fore_color);
   uchar alpha=uchar(new_alpha==USHORT_MAX ? this.m_header_alpha : new_alpha>255 ? 255 : new_alpha);
//--- Рисуем фон кнопки
   this.m_canvas.FillRectangle(x1,y1,x2,y2,::ColorToARGB(back_color,alpha));
//--- Координаты точек ломаной линии
   int x[]={x1+3, x1+6, x1+3,x1+4,x1+6,x1+9,x1+9,x1+10,x1+15,x1+14,x1+13,x1+10,x1+10,x1+9,x1+6};
   int y[]={y1+14,y1+11,y1+8,y1+7,y1+7,y1+4,y1+3,y1+2, y1+7, y1+8, y1+8, y1+11,y1+13,y1+14,y1+11};
//--- Рисуем фигурку "кнопки" 
   this.m_canvas.Polygon(x,y,::ColorToARGB(this.m_butt_pin_fore_color,255));
//--- Если флаг перемещаемости сброшен (закреплено) - перечёркиваем нарисованную кнопку
   if(!this.m_movable)
      this.m_canvas.Line(x1+3,y1+2,x1+15,y1+14,::ColorToARGB(this.m_butt_pin_fore_color,255));
//--- Запоминаем текущий цвет фона и рисунка кнопки
   this.m_butt_pin_back_color_c=back_color;
   this.m_butt_pin_fore_color_c=fore_color;
//--- обновляем канвас без перерисовки экрана
   this.m_canvas.Update(false);
  }
//+----------------+
//| Рисует панель  |
//+----------------+
void CDashboard::Draw(const string title)
  {
//--- Устанавливаем текст заголовка
   this.m_title=title;
//--- Если флаг свёрнутости не установлен - разворачиваем панель
   if(!this.m_minimized)
      this.Expand();
//--- Иначе - сворачиваем панель
   else
      this.Collapse();
//--- Обновляем канвас без перерисовки чарта
   this.m_canvas.Update(false);
//--- Обновляем рабочую область с перерисовкой графика
   this.m_workspace.Update();
  }
//+--------------------+
//| Сворачивает панель |
//+--------------------+
void CDashboard::Collapse(void)
  {
//--- Сохраняем в массивы пиксели рабочей области и фона панели
   this.SaveWorkspace();
   this.SaveBackground();
//--- Запоминаем текущую высоту панели
   int h=this.m_h;
//--- Изменяем размеры (высоту) канваса и рабочей области
   if(!this.SetSizes(this.m_canvas.Width(),this.m_header_h))
      return;
//--- Рисуем область заголовка
   this.DrawHeaderArea(this.m_title);
//--- Возвращаем в переменную запомненную высоту панели
   this.m_h=h;
  }
//+---------------------+
//| Разворачивает панель |
//+----------------------+
void CDashboard::Expand(void)
  {
//--- Изменяем размеры панели
   if(!this.SetSizes(this.m_canvas.Width(),this.m_h))
      return;
//--- Если ещё ни разу пиксели фона панели не сохранялись в массив
   if(this.m_array_ppx.Size()==0)
     {
      //--- Рисуем панель и
      this.m_canvas.Erase(::ColorToARGB(this.m_back_color,this.m_alpha));
      this.DrawFrame();
      this.DrawHeaderArea(this.m_title);
      //--- сохраняем пиксели фона панели и рабочей области в массивы
      this.SaveWorkspace();
      this.SaveBackground();
     }
//--- Если пиксели фона панели и рабочей области сохранялись ранее,
   else
     {
      //--- восстанавливаем пиксели фона панели и рабочей области из массивов
      this.RestoreBackground();
      if(this.m_array_wpx.Size()>0)
         this.RestoreWorkspace();
     }
//--- Если после разворачивания панель выходит за пределы окна графика - корректируем расположение панели
   if(this.m_y+this.m_canvas.Height()>this.m_chart_h-1)
      this.Move(this.m_x,this.m_chart_h-1-this.m_canvas.Height());
  }
//+-----------------------------------------------+
//| Возвращает цвет с новой цветовой составляющей |
//+-----------------------------------------------+
color CDashboard::NewColor(color base_color, int shift_red, int shift_green, int shift_blue)
  {
   double clR=0, clG=0, clB=0;
   this.ColorToRGB(base_color,clR,clG,clB);
   double clRn=(clR+shift_red  < 0 ? 0 : clR+shift_red  > 255 ? 255 : clR+shift_red);
   double clGn=(clG+shift_green< 0 ? 0 : clG+shift_green> 255 ? 255 : clG+shift_green);
   double clBn=(clB+shift_blue < 0 ? 0 : clB+shift_blue > 255 ? 255 : clB+shift_blue);
   return this.RGBToColor(clRn,clGn,clBn);
  }
//+-------------------------+
//| Преобразует RGB в color |
//+-------------------------+
color CDashboard::RGBToColor(const double r,const double g,const double b) const
  {
   int int_r=(int)::round(r);
   int int_g=(int)::round(g);
   int int_b=(int)::round(b);
   int clr=0;
   clr=int_b;
   clr<<=8;
   clr|=int_g;
   clr<<=8;
   clr|=int_r;
//---
   return (color)clr;
  }
//+------------------------------------+
//| Получение значений компонентов RGB |
//+------------------------------------+
void CDashboard::ColorToRGB(const color clr,double &r,double &g,double &b)
  {
   r=GetR(clr);
   g=GetG(clr);
   b=GetB(clr);
  }
//+--------------------------------------+
//| Устанавливает прозрачность заголовка |
//+--------------------------------------+
void CDashboard::SetHeaderTransparency(const uchar value)
  {
   this.m_header_alpha=value;
   if(this.m_header_alpha_c!=this.m_header_alpha)
      this.RedrawHeaderArea(clrNONE,NULL,clrNONE,value);
   this.m_header_alpha_c=value;
  }
//+-----------------------------------+
//| Устанавливает прозрачность панели |
//+-----------------------------------+
void CDashboard::SetTransparency(const uchar value)
  {
   this.m_alpha=value;
   if(this.m_alpha_c!=this.m_alpha)
     {
      this.m_canvas.Erase(::ColorToARGB(this.m_back_color,value));
      this.DrawFrame();
      this.RedrawHeaderArea(clrNONE,NULL,clrNONE,value);
      this.m_canvas.Update(false);
     }
   this.m_alpha_c=value;
  }
//+------------------------------------------------------------------+
//| Устанавливает параметры шрифта рабочей области по умолчанию      |
//+------------------------------------------------------------------+
void CDashboard::SetFontParams(const string name,const int size,const uint flags=0,const uint angle=0)
  {
   if(!this.m_workspace.FontSet(name,size*-10,flags,angle))
     {
      ::PrintFormat("%s: Failed to set font options. Error %lu",(string)__FUNCTION__,::GetLastError());
      return;
     }
   this.m_font=name;
   this.m_font_size=size*-10;
  }
//+---------------------------------------------+
//| Включает/выключает режимы работы с графиком |
//+---------------------------------------------+
void CDashboard::SetChartsTool(const bool flag)
  {
//--- Если передан флаг true и если прокрутка графика отключена
   if(flag && !::ChartGetInteger(this.m_chart_id,CHART_MOUSE_SCROLL))
     {
      //--- включаем прокрутку графика, меню правой кнопки мышки и перекрестие
      ::ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
      ::ChartSetInteger(0,CHART_CONTEXT_MENU,true);
      ::ChartSetInteger(0,CHART_CROSSHAIR_TOOL,true);
     }
//--- иначе, если передан флаг false и если прокрутка графика включена
   else if(!flag && ::ChartGetInteger(this.m_chart_id,CHART_MOUSE_SCROLL))
     {
      //--- отключаем прокрутку графика, меню правой кнопки мышки и перекрестие
      ::ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
      ::ChartSetInteger(0,CHART_CONTEXT_MENU,false);
      ::ChartSetInteger(0,CHART_CROSSHAIR_TOOL,false);
     }
  }
//+----------------------------------------------------+
//| Выводит текстовое сообщение в указанные координаты |
//+----------------------------------------------------+
void CDashboard::DrawText(const string text,const int x,const int y,const int width=WRONG_VALUE,const int height=WRONG_VALUE)
  {
//--- Объявим переменные для записи в них ширины и высоты текста
   int w=width;
   int h=height;
//--- Если ширина и высота текста, переданные в метод, имеют нулевые значения,
//--- то полностью очищается всё паространство рабочей области прозрачным цветом
   if(width==0 && height==0)
      this.m_workspace.Erase(0x00FFFFFF);
//--- Иначе
   else
     {
      //--- Если переданные ширина и высота имеют значения по умолчанию (-1) - получаем из текста его ширину и высоту
      if(width==WRONG_VALUE && height==WRONG_VALUE)
         this.m_workspace.TextSize(text,w,h);
      //--- иначе,
      else
        {
         //--- если ширина, переданная в метод, имеет значение по умолчанию (-1) - получаем ширину из текста, либо
         //--- если ширина, переданная в метод, имеет значение больше нуля - используем переданную в метод ширину, либо
         //--- если ширина, переданная в метод, имеет нулевое значение, используем значение 1 для ширины
         w=(width ==WRONG_VALUE ? this.m_workspace.TextWidth(text)  : width>0  ? width  : 1);
         //--- если высота, переданная в метод, имеет значение по умолчанию (-1) - получаем высоту из текста, либо
         //--- если высота, переданная в метод, имеет значение больше нуля - используем переданную в метод высоту, либо
         //--- если высота, переданная в метод, имеет нулевое значение, используем значение 1 для высоты
         h=(height==WRONG_VALUE ? this.m_workspace.TextHeight(text) : height>0 ? height : 1);
        }
      //--- Заполняем пространство по указанным координатам и полученной шириной и высотой прозрачным цветом (стираем прошлую запись)
      this.m_workspace.FillRectangle(x,y,x+w,y+h,0x00FFFFFF);
     }
//--- Выводим текст на очищенное от прошлого текста места и обновляем рабочую область без перерисовки экрана
   this.m_workspace.TextOut(x,y,text,::ColorToARGB(this.m_fore_color));
   this.m_workspace.Update(false);
  }
//+-----------------------+
//| Рисует фоновую сетку  |
//+-----------------------+
void CDashboard::DrawGrid(const uint x,const uint y,const uint rows,const uint columns,const uint row_size,const uint col_size,
                          const color line_color=clrNONE,bool alternating_color=true)
  {
//--- Если панель свёрнута - уходим
   if(this.m_minimized)
      return;
//--- Очищаем все списки объекта табличных данных (удаляем ячейки из строк и все строки)
   this.m_table_data.Clear();
//--- Высота строки не может быть меньше 2
   int row_h=int(row_size<2 ? 2 : row_size);
//--- Ширина столбца не может быть меньше 2
   int col_w=int(col_size<2 ? 2 : col_size);
   
//--- Координата X1 (слева) таблицы не может быть меньше 1 (чтобы оставить один пиксель по периметру панели для рамки)
   int x1=int(x<1 ? 1 : x);
//--- Рассчитываем координату X2 (справа) в зависимости от количества столбцов и их ширины
   int x2=x1+col_w*int(columns>0 ? columns : 1);
//--- Координата Y1 находится под областью заголовка панели
   int y1=this.m_header_h+(int)y;
//--- Рассчитываем координату Y2 (снизу) в зависимости от количества строк и их высоты
   int y2=y1+row_h*int(rows>0 ? rows : 1);
   
//--- Получаем цвет линий сетки таблицы, либо по умолчанию, либо переданный в метод
   color clr=(line_color==clrNONE ? C'200,200,200' : line_color);
//--- Если начальная координата X больше 1 - рисуем рамку таблицы
//--- (при координате 1 рамкой таблицы выступает рамка панели)
   if(x1>1)
      this.m_canvas.Rectangle(x1,y1,x2,y2,::ColorToARGB(clr,this.m_alpha));
//--- В цикле во строкам таблицы
   for(int i=0;i<(int)rows;i++)
     {
      //--- рассчитываем координату Y очередной горизонтальной линии сетки (координата Y очередной строки таблицы)
      int row_y=y1+row_h*i;
      //--- если передан флаг "чередующихся" цветов строк и строка чётная
      if(alternating_color && i%2==0)
        {
         //--- осветляем цвет фона таблицы и рисуем фоновый прямоугольник
         color new_color=this.NewColor(clr,45,45,45);
         this.m_canvas.FillRectangle(x1+1,row_y+1,x2-1,row_y+row_h-1,::ColorToARGB(new_color,this.m_alpha));
        }
      //--- Рисуем горизонтальную линию сетки таблицы
      this.m_canvas.Line(x1,row_y,x2,row_y,::ColorToARGB(clr,this.m_alpha));
      
      //--- Создаём новый объект строки таблицы
      CTableRow *row_obj=new CTableRow(i);
      if(row_obj==NULL)
        {
         ::PrintFormat("%s: Failed to create table row object at index %lu",(string)__FUNCTION__,i);
         continue;
        }
      //--- Добавляем его в список строк объекта табличных данных
      //--- (если добавить объект не удалось - удаляем созданный объект)
      if(!this.m_table_data.AddRow(row_obj))
         delete row_obj;
      //--- Устанавливаем в созданном объекте-строке его координату Y с учётом смещения от заголовка панели
      row_obj.SetY(row_y-this.m_header_h);
     }
     
//--- В цикле по столбцам таблицы
   for(int i=0;i<(int)columns;i++)
     {
      //--- рассчитываем координату X очередной вертикальной линии сетки (координата X очередного столбца таблицы)
      int col_x=x1+col_w*i;
      //--- Если линия сетки вышла за пределы панели - прерываем цикл
      if(x1==1 && col_x>=x1+m_canvas.Width()-2)
         break;
      //--- Рисуем вертикальную линию сетки таблицы
      this.m_canvas.Line(col_x,y1,col_x,y2,::ColorToARGB(clr,this.m_alpha));
      
      //--- Получаем из объекта табличных данных количество созданных строк
      int total=this.m_table_data.RowsTotal();
      //--- В цикле по строкам таблицы
      for(int j=0;j<total;j++)
        {
         //--- получаем очередную строку
         CTableRow *row=m_table_data.GetRow(j);
         if(row==NULL)
            continue;
         //--- Создаём новую ячейку таблицы
         CTableCell *cell=new CTableCell(row.Row(),i);
         if(cell==NULL)
           {
            ::PrintFormat("%s: Failed to create table cell object at index %lu",(string)__FUNCTION__,i);
            continue;
           }
         //--- Добавляем созданную ячейку в строку
         //--- (если добавить объект не удалось - удаляем созданный объект)
         if(!row.AddCell(cell))
           {
            delete cell;
            continue;
           }
         //--- Устанавливаем в созданном объекте-ячейке его координату X и координату Y из объекта-строки
         cell.SetXY(col_x,row.Y());
        }
     }
//--- Обновляем канвас без перерисовки графика
   this.m_canvas.Update(false);
  }
//+-------------------------------------------------------+
//| Рисует фоновую сетку с автоматическим размером ячеек  |
//+-------------------------------------------------------+
void CDashboard::DrawGridAutoFill(const uint border,const uint rows,const uint columns,const color line_color=clrNONE,bool alternating_color=true)
  {
//--- Если панель свёрнута - уходим
   if(this.m_minimized)
      return;
//--- Координата X1 (левая) таблицы
   int x1=(int)border;
//--- Координата X2 (правая) таблицы
   int x2=this.m_canvas.Width()-(int)border-1;
//--- Координата Y1 (верхняя) таблицы
   int y1=this.m_header_h+(int)border;
//--- Координата Y2 (нижняя) таблицы
   int y2=this.m_canvas.Height()-(int)border-1;

//--- Получаем цвет линий сетки таблицы, либо по умолчанию, либо переданный в метод
   color clr=(line_color==clrNONE ? C'200,200,200' : line_color);
//--- Если отступ от края панели больше нуля - рисуем рамку таблицы
//--- иначе - рамкой таблицы выступает рамка панели
   if(border>0)
      this.m_canvas.Rectangle(x1,y1,x2,y2,::ColorToARGB(clr,this.m_alpha));

//--- Высота всей сетки таблицы
   int greed_h=y2-y1;
//--- Рассчитываем высоту строки в зависимости от высоты таблицы и количества строк
   int row_h=(int)::round((double)greed_h/(double)rows);
//--- В цикле по количеству строк
   for(int i=0;i<(int)rows;i++)
     {
      //--- рассчитываем координату Y очередной горизонтальной линии сетки (координата Y очередной строки таблицы)
      int row_y=y1+row_h*i;
      //--- если передан флаг "чередующихся" цветов строк и строка чётная
      if(alternating_color && i%2==0)
        {
         //--- осветляем цвет фона таблицы и рисуем фоновый прямоугольник
         color new_color=this.NewColor(clr,45,45,45);
         this.m_canvas.FillRectangle(x1+1,row_y+1,x2-1,row_y+row_h-1,::ColorToARGB(new_color,this.m_alpha));
        }
      //--- Рисуем горизонтальную линию сетки таблицы
      this.m_canvas.Line(x1,row_y,x2,row_y,::ColorToARGB(clr,this.m_alpha));
      
      //--- Создаём новый объект строки таблицы
      CTableRow *row_obj=new CTableRow(i);
      if(row_obj==NULL)
        {
         ::PrintFormat("%s: Failed to create table row object at index %lu",(string)__FUNCTION__,i);
         continue;
        }
      //--- Добавляем его в список строк объекта табличных данных
      //--- (если добавить объект не удалось - удаляем созданный объект)
      if(!this.m_table_data.AddRow(row_obj))
         delete row_obj;
      //--- Устанавливаем в созданном объекте-строке его координату Y с учётом смещения от заголовка панели
      row_obj.SetY(row_y-this.m_header_h);
     }
     
//--- Ширина сетки таблицы
   int greed_w=x2-x1;
//--- Рассчитываем ширину столбца в зависимости от ширины таблицы и количества столбцов
   int col_w=(int)::round((double)greed_w/(double)columns);
//--- В цикле по столбцам таблицы
   for(int i=0;i<(int)columns;i++)
     {
      //--- рассчитываем координату X очередной вертикальной линии сетки (координата X очередного столбца таблицы)
      int col_x=x1+col_w*i;
      //--- Если это не самая первая вертикальная линия - рисуем её
      //--- (первой вертикальной линией выступает либо рамка таблицы, либо рамка панели)
      if(i>0)
         this.m_canvas.Line(col_x,y1,col_x,y2,::ColorToARGB(clr,this.m_alpha));
      
      //--- Получаем из объекта табличных данных количество созданных строк
      int total=this.m_table_data.RowsTotal();
      //--- В цикле по строкам таблицы
      for(int j=0;j<total;j++)
        {
         //--- получаем очередную строку
         CTableRow *row=this.m_table_data.GetRow(j);
         if(row==NULL)
            continue;
         //--- Создаём новую ячейку таблицы
         CTableCell *cell=new CTableCell(row.Row(),i);
         if(cell==NULL)
           {
            ::PrintFormat("%s: Failed to create table cell object at index %lu",(string)__FUNCTION__,i);
            continue;
           }
         //--- Добавляем созданную ячейку в строку
         //--- (если добавить объект не удалось - удаляем созданный объект)
         if(!row.AddCell(cell))
           {
            delete cell;
            continue;
           }
         //--- Устанавливаем в созданном объекте-ячейке его координату X и координату Y из объекта-строки
         cell.SetXY(col_x,row.Y());
        }
     }
//--- Обновляем канвас без перерисовки графика
   this.m_canvas.Update(false);
  }
//+---------------------------------------------+
//| Сохраняет рабочую область в массив пикселей |
//+---------------------------------------------+
void CDashboard::SaveWorkspace(void)
  {
//--- Рассчитываем необходимый размер массива (ширина * высота рабочей области)
   uint size=this.m_workspace.Width()*this.m_workspace.Height();
//--- Если размер массива не равен рассчитанному - изменяем его
   if(this.m_array_wpx.Size()!=size)
     {
      ::ResetLastError();
      if(::ArrayResize(this.m_array_wpx,size)!=size)
        {
         ::PrintFormat("%s: ArrayResize failed. Error %lu",(string)__FUNCTION__,::GetLastError());
         return;
        }
     }
   uint n=0;
//--- В цикле по высоте рабочей области (координата Y пикселя)
   for(int y=0;y<this.m_workspace.Height();y++)
      //--- в цикле по ширине рабочей области (координата X пикселя)
      for(int x=0;x<this.m_workspace.Width();x++)
        {
         //--- рассчитываем индекс пикселя в приёмном массиве
         n=this.m_workspace.Width()*y+x;
         if(n>this.m_array_wpx.Size()-1)
            break;
         //--- копируем пиксель в приёмный массив из X и Y рабочей области
         this.m_array_wpx[n]=this.m_workspace.PixelGet(x,y);
        }
  }
//+-----------------------------------------------------+
//| Восстанавливает рабочую область из массива пикселей |
//+---------------------------------------------------- +
void CDashboard::RestoreWorkspace(void)
  {
//--- Если массив пустой - уходим
   if(this.m_array_wpx.Size()==0)
      return;
   uint n=0;
//--- В цикле по высоте рабочей области (координата Y пикселя)
   for(int y=0;y<this.m_workspace.Height();y++)
      //--- в цикле по ширине рабочей области (координата X пикселя)
      for(int x=0;x<this.m_workspace.Width();x++)
        {
         //--- рассчитываем индекс пикселя в массиве
         n=this.m_workspace.Width()*y+x;
         if(n>this.m_array_wpx.Size()-1)
            break;
         //--- копируем пиксель из массива в координаты X и Y рабочей области
         this.m_workspace.PixelSet(x,y,this.m_array_wpx[n]);
        }
  }
//+----------------------------------------+
//| Сохраняет фон панели в массив пикселей |
//+----------------------------------------+
void CDashboard::SaveBackground(void)
  {
//--- Рассчитываем необходимый размер массива (ширина * высота панели)
   uint size=this.m_canvas.Width()*this.m_canvas.Height();
//--- Если размер массива не равен рассчитанному - изменяем его
   if(this.m_array_ppx.Size()!=size)
     {
      ::ResetLastError();
      if(::ArrayResize(this.m_array_ppx,size)!=size)
        {
         ::PrintFormat("%s: ArrayResize failed. Error %lu",(string)__FUNCTION__,::GetLastError());
         return;
        }
     }
   uint n=0;
//--- В цикле по высоте панели (координата Y пикселя)
   for(int y=0;y<this.m_canvas.Height();y++)
      //--- в цикле по ширине панели (координата X пикселя)
      for(int x=0;x<this.m_canvas.Width();x++)
        {
         //--- рассчитываем индекс пикселя в приёмном массиве
         n=this.m_canvas.Width()*y+x;
         if(n>this.m_array_ppx.Size()-1)
            break;
         //--- копируем пиксель в приёмный массив из X и Y панели
         this.m_array_ppx[n]=this.m_canvas.PixelGet(x,y);
        }
  }
//+-------------------------------------------------+
//| Восстанавливает фон панели из массива пикселей  |
//+-------------------------------------------------+
void CDashboard::RestoreBackground(void)
  {
//--- Если массив пустой - уходим
   if(this.m_array_ppx.Size()==0)
      return;
   uint n=0;
//--- В цикле по высоте панели (координата Y пикселя)
   for(int y=0;y<this.m_canvas.Height();y++)
      //--- в цикле по ширине панели (координата X пикселя)
      for(int x=0;x<this.m_canvas.Width();x++)
        {
         //--- рассчитываем индекс пикселя в массиве
         n=this.m_canvas.Width()*y+x;
         if(n>this.m_array_ppx.Size()-1)
            break;
         //--- копируем пиксель из массива в координаты X и Y панели
         this.m_canvas.PixelSet(x,y,this.m_array_ppx[n]);
        }
  }
//+------------------+
//| Скрывает панель  |
//+------------------+
void CDashboard::Hide(const bool redraw=false)
  {
   ::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   ::ObjectSetInteger(this.m_chart_id,this.m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
   if(redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+--------------------+
//| Показывает панель  |
//+--------------------+
void CDashboard::Show(const bool redraw=false)
  {
   ::ObjectSetInteger(this.m_chart_id,this.m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   if(!this.m_minimized)
      ::ObjectSetInteger(this.m_chart_id,this.m_workspace.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   if(redraw)
      ::ChartRedraw(this.m_chart_id);
  }
//+-----------------------------------+
//| Переносит панель на передний план |
//+-----------------------------------+
void CDashboard::BringToTop(void)
  {
   this.Hide(false);
   this.Show(true);
  }
//+--------------------------------------------------+
//| Сохраняет массив пикселей рабочей области в файл |
//+--------------------------------------------------+
bool CDashboard::FileSaveWorkspace(void)
  {
//--- Определяем папку и имя файла
   string filename=this.m_program_name+"\\Dashboard"+(string)this.m_id+"\\workspace.bin";
//--- Если сохраняемый массив пустой - сообщаем об этом и возвращаем false
   if(this.m_array_wpx.Size()==0)
     {
      ::PrintFormat("%s: Error. The workspace pixel array is empty.",__FUNCTION__);
      return false;
     }
//--- Если массив не удалось сохранить в файл - сообщаем об этом и возвращаем false
   if(!::FileSave(filename,this.m_array_wpx))
     {
      ::PrintFormat("%s: FileSave '%s' failed. Error %lu",__FUNCTION__,filename,::GetLastError());
      return false;
     }
//--- Успешно, возвращаем true
   return true;
  }
//+----------------------------------------------+
//| Сохраняет массив пикселей фона панели в файл |
//+----------------------------------------------+
bool CDashboard::FileSaveBackground(void)
  {
//--- Определяем папку и имя файла
   string filename=this.m_program_name+"\\Dashboard"+(string)this.m_id+"\\background.bin";
//--- Если сохраняемый массив пустой - сообщаем об этом и возвращаем false
   if(this.m_array_ppx.Size()==0)
     {
      ::PrintFormat("%s: Error. The background pixel array is empty.",__FUNCTION__);
      return false;
     }
//--- Если массив не удалось сохранить в файл - сообщаем об этом и возвращаем false
   if(!::FileSave(filename,this.m_array_ppx))
     {
      ::PrintFormat("%s: FileSave '%s' failed. Error %lu",__FUNCTION__,filename,::GetLastError());
      return false;
     }
//--- Успешно, возвращаем true
   return true;
  }
//+-----------------------------------------------------+
//| Загружает массив пикселей рабочей области из файла  |
//+---------------------------------------------------- +
bool CDashboard::FileLoadWorkspace(void)
  {
//--- Определяем папку и имя файла
   string filename=this.m_program_name+"\\Dashboard"+(string)this.m_id+"\\workspace.bin";
//--- Если не удалось загрузить данные из файла в массив, сообщаем об этом и возвращаем false
   if(::FileLoad(filename,this.m_array_wpx)==WRONG_VALUE)
     {
      ::PrintFormat("%s: FileLoad '%s' failed. Error %lu",__FUNCTION__,filename,::GetLastError());
      return false;
     }
//--- Успешно, возвращаем true
   return true;
  }
//+------------------------------------+
//| Загружает массив пикселей фона панели из файла   |
//+------------------------------------+
bool CDashboard::FileLoadBackground(void)
  {
//--- Определяем папку и имя файла
   string filename=this.m_program_name+"\\Dashboard"+(string)this.m_id+"\\background.bin";
//--- Если не удалось загрузить данные из файла в массив, сообщаем об этом и возвращаем false
   if(::FileLoad(filename,this.m_array_ppx)==WRONG_VALUE)
     {
      ::PrintFormat("%s: FileLoad '%s' failed. Error %lu",__FUNCTION__,filename,::GetLastError());
      return false;
     }
//--- Успешно, возвращаем true
   return true;
  }
//+----------------+

